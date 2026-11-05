#lang scribble/manual
@(require (for-label racket/base racket/contract
                     fhir/conformance/validate fhir/conformance/operations fhir/terminology/service))

@title{fhir-validation: validating FHIR resources}

A validator for FHIR resources against their base type and profiles, over FHIR NPM packages: a
profile resolves through @racket[current-sd-packages], so an IG's resources validate in the context
of its dependencies and core, and required bindings go through the fhir-tx terminology service when
one is given. It is fail-open: it never reports what it cannot decide. Held to published IGs as
oracles (US Core, IPS and mCODE examples all clean against the profiles they claim, no false
positive) and to the HL7 validator test cases. Part of the
@hyperlink["https://github.com/oloveluck/fhir"]{fhir} family.

@table-of-contents[]

@section{Quick start}

@bold{1. Install.} The packages are not on the Racket package server yet; clone the repositories
side by side and install from source:

@verbatim{
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx fhir/fhir-validation
}

@bold{2. Validate a resource}, against its base type, or against profiles given as files:

@verbatim{
$ raco fhir-validate patient.json --format text
patient.json: error invalid at Patient.birthDate: '1974-13-40' is not a valid date
$ raco fhir-validate observation.json us-core-blood-pressure.json
{"resourceType": "OperationOutcome", "issue": [{"severity": "error", "code": "required",
  "expression": ["Observation.component"], "diagnostics": "minimum required = 2, but found 1"}]}
}

The OperationOutcome is on stdout by default; @litchar{--format text} is one line per issue on
stderr. Exit 1 on any error issue, 2 on usage. Duplicate JSON keys and malformed JSON are reported
with their position.

@section{Using it}

@subsection{As an operation}

@tt{$validate} is an operation (@tt{fhir/operation}); loading @racket[fhir/conformance/operations]
registers it. The resource is FHIR JSON; the answer is an OperationOutcome. Profiles come from
@racket[current-data-source] (StructureDefinitions you hold, such as an FSH project's output) and
@racket[current-sd-packages] (an IG's package, its dependencies, then core; unset means the R5
core).

@racketblock[
(require fhir/operation fhir/data-source fhir/sd/sd-index fhir/conformance/operations)
(apply-operation "$validate" patient)                                (code:comment "against its base type")
(parameterize ([current-sd-packages (list "hl7.fhir.us.core-6.1.0.tgz" "hl7.fhir.r4.core.tgz")])
  (apply-operation "$validate" patient
                   #:profile "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"))
(code:comment "an FSH project's profiles")
(parameterize ([current-data-source (resources->data-source (project-artifacts ig))]
               [current-sd-packages (project-sd-packages ig)])
  (ensure-valid observation #:profile url))                         (code:comment "the resource, or exn:fail:operation")
]

@racket[ensure-valid] is the pipeline form: @racket[(~> qr (transform #:srcMap fml) (ensure-valid
#:profile url))] stops with the outcome when a step produces an invalid resource. Each issue carries
the element path (@tt{expression}) and a message naming the rule and the profile.

@subsection{The validator directly}

@racket[validate-issues] takes the raw JSON and the profile StructureDefinitions and returns
@racket[issue] structs (severity, code, path, message). A @racket[tx-service] from fhir-tx enables
required-binding checks against value sets defined by filters; FHIRPath invariants run by default.

@racketblock[
(require fhir/conformance/validate fhir/terminology/service fhir/r4/schemas)
(parameterize ([current-sd-packages (list ig-tgz core-tgz)])
  (validate-issues resource #:profiles (list sd)
                   #:terminology (make-terminology/packages (list ig-tgz core-tgz))))
]

@tt{$validate} builds a terminology service over the data source and the packages; the command line
passes none, so there only bindings whose value set enumerates its codes are checked. The service
and its limits are documented with @hyperlink["../fhir-tx/index.html"]{fhir-tx}.

@section{Limits}

@itemlist[
@item{@bold{What the validator does not check.} Slicing with an @tt{exists}, @tt{type},
@tt{profile} or @tt{position} discriminator (the whole slicing fails open), @tt{closed} slicing
rules and slice @tt{max}; extensions beyond their slice (an extension's url, context and its own
profile's constraints are never checked: @tt{Extension} is opaque and not recursed into); references
(target profiles, resolvability, @tt{#id} into @tt{contained}); XHTML beyond non-empty; the
@tt{meta.profile} of a contained or Bundle-entry resource (entries are walked against their base
type only); extensible and preferred bindings, @tt{maxValueSet} and additional bindings (only
required bindings are checked); mustSupport, by design. Invariants are off by default; even on, the
base element and domain invariants are skipped. Against the HL7 validator test cases the recall is
17 of 26 dirty cases with no false positive; the remaining misses need @tt{resolve()}, embedded
FHIRPath validation or canonical resolution into contained resources.}]

@section{Reference}

@subsection[#:style 'unnumbered]{@tt{fhir/conformance/validate}}
@defmodule[fhir/conformance/validate]

@defproc[(validate-issues [resource hash?]
                          [#:profiles profiles (listof hash?) '()]
                          [#:terminology terminology any/c #f]
                          [#:invariants? invariants? boolean? #t]
                          [#:duplicates duplicates (listof string?) '()]) (listof issue?)]{
Validates raw FHIR JSON against its base type, the profiles in @tt{meta.profile}, and the
StructureDefinitions given (those whose type matches), their snapshots generated on demand. The
checks: cardinality; unknown elements (lenient on choice variants); the choice variant narrowed to its
type; primitive lexemes (decimals on their lexeme, the id grammar, canonicals); @tt{fixed[x]} and
@tt{pattern[x]}; required bindings, through a @racket[tx-service] when one is given and the value
set expands offline; value and pattern discriminator slicing, with an entry matched to exactly one
slice held to the slice's own children; and, unless @racket[invariants?] is false, FHIRPath
constraints — each at its element with @tt{%resource} and @tt{%context} bound, a violation only on
a singleton false, the universal base keys (ele-1, dom-*) and constraints on slices left unchecked
(slice membership is not decided here). Over the whole R5 core package, invariants report nothing the
package does not itself break (ten logical models without @tt{derivation}, sdf-27; the fhir-types
code system against the Shareable profile, scs-1). @racket[duplicates] are the paths of duplicate JSON keys from
@racket[read-fhir-json/duplicates], each an error. Anything undecidable (an unresolvable type,
profile or value set, an unparseable expression) is not reported.}
@defstruct*[issue ([severity string?] [code string?] [path (or/c string? #f)] [msg string?])]
@defproc[(validate-json [resource hash?]
                        [#:profiles profiles (listof hash?) '()]
                        [#:terminology terminology any/c #f]
                        [#:invariants? invariants? boolean? #t]
                        [#:duplicates duplicates (listof string?) '()]) any/c]{The same as an OperationOutcome node.}

@subsection[#:style 'unnumbered]{@tt{fhir/conformance/operations}}
@defmodule[fhir/conformance/operations]

@defthing[$validate procedure?]{
@tt{Resource/$validate} as a @tt{fhir/operation} value: @racket[($validate resource #:profile canonical)]
returns an OperationOutcome (one informational "All OK" issue when clean). The profile resolves
from @racket[current-data-source], then @racket[current-sd-packages]; terminology comes from the same
places.}
@defproc[(ensure-valid [resource hash?] [#:profile profile (or/c string? #f) #f]) hash?]{
The resource when it is valid, else @racket[exn:fail:operation] with the outcome.}
