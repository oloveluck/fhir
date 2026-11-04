#lang scribble/manual
@(require (for-label racket/base racket/contract fhir/terminology/service fhir/terminology/operations))

@title{fhir-tx: a FHIR terminology service}

A terminology server as a value: @tt{$expand}, @tt{$validate-code} (ValueSet and CodeSystem),
@tt{$lookup} and @tt{$translate} over the CodeSystems, ValueSets and ConceptMaps in FHIR NPM
packages or in resources you hold, indexed lazily. The same service is a @tt{fhir/operation} value,
the @tt{%terminologies} handle FHIRPath takes, what the validator checks bindings with, what
fhir-server serves, and what expands VCL's implicit value set urls. The official
hl7.fhir.uv.tx-ecosystem suite stands at 463/553, with what rests on external code systems skipped.

Part of the @hyperlink["https://github.com/oloveluck/fhir"]{fhir} family, in the @tt{fhir}
collection; depends on @tt{fhir}, @tt{fhir-spec}, @tt{fhirpath} (the handle) and @tt{vcl}.

@table-of-contents[]

@section{Install}

@verbatim{
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx   # from source
}

@section{Using it}

@bold{The operations.} The service answers @tt{$expand}, @tt{$validate-code}, @tt{$lookup} and
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
@tt{%terminologies} takes, as a one-item collection:
@racket[(eval-fhirpath ast root #:externals (hash "terminologies" (list tx)))].

@bold{From Racket.} A @italic{resolver} is @tt{(url [version]) -> resource | #f}; the JSON-level
functions take one and answer FHIR JSON with no tower loaded.

@racketblock[
(require fhir/terminology/service)
(define r (packages->resolver (list "hl7.fhir.us.core-6.1.0.tgz" "hl7.fhir.r4.core.tgz")))
(expand/json r "http://hl7.org/fhir/us/core/ValueSet/us-core-condition-code" #f (hash "filter" "diab"))
(validate-code/json r "http://hl7.org/fhir/ValueSet/administrative-gender" "female"
                    "http://hl7.org/fhir/administrative-gender")
(lookup/json r "http://hl7.org/fhir/administrative-gender" "female")
(define tx (make-terminology/resolver r))        (code:comment "the handle: for validate-issues, for %terminologies")
]

@bold{Command line.}

@verbatim{
raco fhir-tx expand http://hl7.org/fhir/ValueSet/administrative-gender
raco fhir-tx expand <ValueSet url> --package hl7.fhir.us.core-6.1.0.tgz --filter diab
raco fhir-tx validate-code <ValueSet url> <system> <code> [--display <text>]
raco fhir-tx lookup http://hl7.org/fhir/administrative-gender female
raco fhir-tx translate <ConceptMap url> <code> [--system <system>]
raco fhir-tx tck [-v]                 the tx-ecosystem suite (floor-ratcheted)
}

@litchar{--package} names a .tgz or a file in @tt{fhir-spec}, repeatable, searched in order; with none,
the R5 core. @litchar{--filter}, @litchar{--count} and @litchar{--offset} are the expansion
parameters; @litchar{--display} checks a display. The answer is the operation's FHIR JSON. Exit codes:
0, 1 when the operation fails or the suite regresses, 2 on usage.

@section{How terminology is handled}

Terminology lives in four places, by when it is needed:

@itemlist[
@item{@bold{At compile time, in the towers.} Code generation expands every required binding on a
@tt{code} element whose ValueSet enumerates its codes or includes a whole CodeSystem from the same
package, and writes the sets into @tt{fhir/r6/terminology} (202 value sets; 241 for R5, 211 for
R4), registered in @tt{fhir/model/binding}. The @tt{fhir/r6} form macros reject a literal code
outside its set when the module compiles. Filters, imports and excludes are not expanded: those
value sets fail open.}
@item{@bold{At validation time.} The validator checks required bindings through a
@racket[tx-service] when it is given one, else against the same offline sets. Only @tt{$validate}
builds a service (over the data source and the packages). @tt{raco fhir-validate}, the generated
server's write validation and @tt{raco fsh check} pass none, so for them a binding to a value set
defined by filters is not checked.}
@item{@bold{At run time, the service} in @racket[fhir/terminology/service]: @tt{$expand},
@tt{$validate-code} (ValueSet and CodeSystem), @tt{$lookup} and @tt{$translate} over the
CodeSystems, ValueSets and ConceptMaps in packages or resources, indexed lazily per package. The
operations in @racket[fhir/terminology/operations] put it behind @tt{fhir/operation}; FHIRPath's
@tt{expand()}, @tt{validateVS()} and @tt{translate()} call it through the @racket[tx-service]
handle; fhir-server serves the operations an IG declares; VCL's implicit urls compile on the way
in.}
@item{@bold{In the languages, by expansion.} CQL's @tt{in "ValueSet"} and retrieves by value set
take ValueSet resources with an @tt{expansion} (else enumerated concepts) and do not call the
service. FML has no @tt{translate} transform. FSH records a binding's strength and url and
validates no codes.}]

@section{Limits}

@itemlist[
@item{@bold{What the terminology service does not do.} @tt{$subsumes}, @tt{$closure},
@tt{$find-matches}, batch validation, CodeSystem supplements. Expansion ignores
@tt{compose.include.valueSet} (an include by value set contributes nothing, and a system include is
not narrowed by one), and a ValueSet that carries only an @tt{expansion} and no @tt{compose}
expands to nothing. The filter operators @tt{generalizes}, @tt{descendent-leaf} and @tt{of} match
nothing, so a VCL expression using them expands to nothing; @tt{is-a} and @tt{descendent-of} use the
concept tree, not the named property. @tt{$expand} does not take @tt{includeDefinition},
@tt{excludeNotForUI} or @tt{limit}, and emits no @tt{abstract} or @tt{inactive} flags;
@tt{displayLanguage} matches a tag exactly. @tt{$lookup} drops a designation's @tt{use} and any
property that is not a code, string or boolean. @tt{$translate} is forward only, by source code and
system, with no target, @tt{dependsOn} or @tt{unmapped} handling and no ConceptMap version. Version
resolution picks the highest version by string order. Concept lookups scan linearly, so
@tt{activeOnly} and @tt{is-a} are quadratic in the code system's size. Anything resting on a code
system the service cannot see (SNOMED CT, LOINC, RxNorm) is undecidable and reported as unknown,
never as invalid; the tx-ecosystem suite stands at 463/553 with those skipped.}
@item{@bold{FHIRPath's @tt{%terminologies}} offers @tt{expand()}, @tt{validateVS()} and
@tt{translate()}; @tt{expand()} drops its parameters argument and the other two their system
argument, and there is no @tt{lookup()}, @tt{subsumes()} or @tt{validateCS()}.}]

@section{Reference}

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
