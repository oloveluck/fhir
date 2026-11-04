#lang scribble/manual
@(require (for-label racket/base racket/contract
                     fhir/conformance/validate fhir/conformance/operations
                     fhir/terminology/service fhir/terminology/operations))

@title{fhir-validation: validating FHIR resources}

A validator for FHIR resources against their base type and profiles, and the terminology service it
uses for bindings. Both work over FHIR NPM packages: a profile resolves through
@racket[current-sd-packages], so an IG's resources validate in the context of its dependencies and
core. The validator is fail-open: it never reports what it cannot decide. It is held to published
IGs as oracles (US Core, IPS and mCODE examples all clean against the profiles they claim, with no
false positive) and to the HL7 validator test cases.

Part of the @hyperlink["https://github.com/oloveluck/fhir"]{fhir} family, in the @tt{fhir}
collection; depends on @tt{fhir}, @tt{fhir-spec}, @tt{fhirpath} and @tt{vcl}.

@table-of-contents[]

@section{Install}

@verbatim{
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-validation
    # from source
}

@section{Using it}

@bold{Validate a resource.} @tt{$validate} is an operation (@tt{fhir/operation}); loading
@racket[fhir/conformance/operations] registers it. The resource is FHIR JSON; the answer is an
OperationOutcome. Profiles come from @racket[current-data-source] (StructureDefinitions you hold,
such as an FSH project's output) and @racket[current-sd-packages] (an IG's package, its
dependencies, then core; @racket[#f] means the R5 core).

@racketblock[
(require fhir/operation fhir/data-source fhir/sd/sd-index fhir/conformance/operations)
(code:comment "against its base type")
(apply-operation "$validate" patient)
(parameterize ([current-sd-packages (list "hl7.fhir.us.core-6.1.0.tgz" "hl7.fhir.r4.core.tgz")])
  (apply-operation "$validate" patient
                   #:profile "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"))
(code:comment "an FSH project")
(parameterize ([current-data-source (resources->data-source (project-artifacts ig))]
               [current-sd-packages (project-sd-packages ig)])
  (code:comment "the resource, or exn:fail:operation")
  (ensure-valid observation #:profile url))
]

@racket[ensure-valid] is the pipeline form: @racket[(~> qr (transform #:srcMap fml) (ensure-valid #:profile url))]
stops with the outcome when a step produces an invalid resource. The outcome's issues carry the
element path (@tt{expression}) and a message naming the rule and the profile; a missing required
pattern says which pattern.

@bold{The validator directly.} @racket[validate-issues] takes the raw JSON and the profile
StructureDefinitions, and returns @racket[issue] structs (severity, code, path, message). A
@racket[tx-service] enables required-binding checks; invariants are off unless asked.

@racketblock[
(require fhir/conformance/validate fhir/terminology/service fhir/r4/schemas)
(parameterize ([current-sd-packages (list ig-tgz core-tgz)])
  (validate-issues resource #:profiles (list sd)
                   #:terminology (make-terminology/packages (list ig-tgz core-tgz))))
]

@bold{Terminology.} The service answers @tt{$expand}, @tt{$validate-code}, @tt{$lookup} and
@tt{$translate} as FHIR JSON over the CodeSystems, ValueSets and ConceptMaps in packages or
resources, lazily indexed. As operations:

@racketblock[
(require fhir/terminology/operations)
($expand #:url "http://hl7.org/fhir/ValueSet/administrative-gender")
(code:comment "a ValueSet you hold")
($expand #:valueSet vs #:filter "fem")
($validate-code #:url "http://hl7.org/fhir/ValueSet/administrative-gender"
                #:system "http://hl7.org/fhir/administrative-gender" #:code "female")
($lookup #:system "http://loinc.org" #:code "85354-9")
]

An implicit VCL url (@tt{http://fhir.org/VCL?v1=…}) expands too. As a @racket[tx-service] handle,
@racket[(make-r5-terminology)] (or over packages, resources, any resolver) is what FHIRPath's
@tt{%terminologies} takes: @racket[(eval-fhirpath ast root #:externals (hash "terminologies" tx))].

@bold{Command line.}

@verbatim{
raco fhir-validate patient.json [us-core-patient.json …] [--format outcome|text|json]
raco fhir-validate --tx-tck                                  the terminology suite
}

The OperationOutcome on stdout by default; @tt{text} is one line per issue on stderr. Duplicate
JSON keys and malformed JSON are reported with their position. Exit 1 on any error issue, 2 on usage.

@section{Reference}

@subsection[#:style 'unnumbered]{@tt{fhir/conformance/validate}}
@defmodule[fhir/conformance/validate]

@defproc[(validate-issues [resource hash?]
                          [#:profiles profiles (listof hash?) '()]
                          [#:terminology terminology any/c #f]
                          [#:invariants? invariants? boolean? #f]
                          [#:duplicates duplicates (listof string?) '()]) (listof issue?)]{
Validates raw FHIR JSON against its base type, the profiles in @tt{meta.profile}, and the
StructureDefinitions given (those whose type matches), their snapshots generated on demand. The
checks: cardinality; unknown elements (lenient on choice variants); the choice variant narrowed to its
type; primitive lexemes (decimals on their lexeme, the id grammar, canonicals); @tt{fixed[x]} and
@tt{pattern[x]}; required bindings, through a @racket[tx-service] when one is given and the value
set expands offline; value and pattern discriminator slicing, with an entry matched to exactly one
slice held to the slice's own children; and, when @racket[invariants?], FHIRPath constraints.
Invariants are off by default because some base invariants evaluate differently from the Java
reference and would over-report. @racket[duplicates] are the paths of duplicate JSON keys from
@racket[read-fhir-json/duplicates], each an error. Anything undecidable (an unresolvable type,
profile or value set, an unparseable expression) is not reported.}
@defstruct*[issue ([severity string?] [code string?] [path (or/c string? #f)] [msg string?])]
@defproc[(validate-json [resource hash?]
                        [#:profiles profiles (listof hash?) '()]
                        [#:terminology terminology any/c #f]
                        [#:invariants? invariants? boolean? #f]
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

@subsection[#:style 'unnumbered]{@tt{fhir/terminology/service}}
@defmodule[fhir/terminology/service]

A terminology server as a value. Expansion follows @tt{compose} (includes, excludes, filters over
the code system's concepts and properties, nested value sets, version pins including @tt{1.x.x}
patterns, implicit VCL urls) with the expansion parameters (offset, count, activeOnly, filter,
displayLanguage, includeDesignations, property). Validation takes a code, a Coding or a
CodeableConcept, checks displays against designations, and honours system and value set versions.
What rests on a code system the service does not have (SNOMED, LOINC) is undecidable; the
hl7.fhir.uv.tx-ecosystem suite is at 463/553 with those skipped.

A @italic{resolver} is @tt{(url [version]) -> resource | #f}.

@deftogether[(
@defproc[(make-terminology [core path-string?]) tx-service?]
@defproc[(make-r5-terminology) tx-service?]
@defproc[(make-r4-terminology) tx-service?]
@defproc[(make-terminology/packages [packages (listof path-string?)]) tx-service?]
@defproc[(make-terminology/resources [resources (listof hash?)]) tx-service?]
@defproc[(make-terminology/resolver [resolver procedure?]) tx-service?])]{
A @racket[tx-service] over a core package, the vendored R5 or R4 core, several packages searched in
order (an IG, then its core), explicit resources, or any resolver. The matching tower must be
loaded.}
@deftogether[(
@defproc[(packages->resolver [packages (listof path-string?)]) procedure?]
@defproc[(resources->resolver [resources (listof hash?)]) procedure?])]
@deftogether[(
@defproc[(expand/json [resolver procedure?] [url string?] [version (or/c string? #f) #f] [params hash? (hash)] [policy version-policy? no-version-policy]) hash?]
@defproc[(validate-code/json [resolver procedure?] [url string?] [code (or/c string? #f) #f] [system (or/c string? #f) #f]
                             [#:coding coding any/c #f] [#:codeable-concept concept any/c #f] [#:display display any/c #f]
                             [#:lenient-display? lenient? boolean? #f] [#:system-version system-version any/c #f]
                             [#:valueset-version valueset-version any/c #f] [#:policy policy version-policy? no-version-policy]) hash?]
@defproc[(lookup/json [resolver procedure?] [system string?] [code string?] [version (or/c string? #f) #f]) hash?]
@defproc[(translate/json [resolver procedure?] [url string?] [code string?] [system (or/c string? #f) #f]) hash?])]{
The operations over a resolver, answering a ValueSet or Parameters jsexpr; they need no tower.
@racket[params] keys are the expansion parameter names as strings.}
@defstruct*[version-policy ([default hash?] [force hash?] [check hash?])]{The server-level @tt{system-version}, @tt{force-system-version} and @tt{check-system-version} parameters, each system to version.}
@deftogether[(@defthing[no-version-policy version-policy?] @defproc[(policy-of [default any/c] [force any/c] [check any/c]) version-policy?])]
@deftogether[(@defproc[(make-lookup [resolver procedure?]) procedure?] @defproc[(make-cs-validate [resolver procedure?]) procedure?] @defproc[(make-undecidable? [resolver procedure?]) procedure?])]{
CodeSystem-level @tt{$lookup} and @tt{$validate-code} as closures answering FHIRPath collections, and
the test for a ValueSet that would need a code system the service lacks.}

@subsection[#:style 'unnumbered]{@tt{fhir/terminology/operations}}
@defmodule[fhir/terminology/operations]

@deftogether[(
@defthing[$expand procedure?]
@defthing[$validate-code procedure?]
@defthing[$lookup procedure?]
@defthing[$translate procedure?])]{
The four as @tt{fhir/operation} values on the core OperationDefinitions, registered when the module
loads. A ValueSet is the subject, @tt{#:valueSet}, or named by @tt{#:url}; the inputs are the
definitions' parameters (@racket[($translate cm #:sourceCode "a" #:system url)]). Resources are
looked up in the inputs, then @racket[current-data-source], then @racket[current-sd-packages].}
@defproc[(current-terminology-resolver [extra (listof hash?) '()]) procedure?]{The resolver the operations use: the data source, then the packages, with @racket[extra] ahead.}
