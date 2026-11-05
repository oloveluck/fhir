#lang scribble/manual
@(require (for-label racket/base racket/contract fhir/terminology/service fhir/terminology/operations))

@title{fhir-tx: a FHIR terminology service}

A terminology server as a value: @tt{$expand}, @tt{$validate-code}, @tt{$lookup}, @tt{$subsumes},
@tt{$find-matches}, @tt{$translate} and @tt{$closure} over the CodeSystems, ValueSets and ConceptMaps
in FHIR NPM packages or in resources you hold. The same service is a set of @tt{fhir/operation}
values, the @tt{%terminologies} handle FHIRPath takes, what the validator checks bindings with, what
fhir-server serves over HTTP, and what expands VCL's implicit value set urls. The official
hl7.fhir.uv.tx-ecosystem suite stands at 473 of 553, with what rests on external code systems
skipped. Part of the @hyperlink["https://github.com/oloveluck/fhir"]{fhir} family.

@table-of-contents[]

@section{Quick start}

@bold{1. Install.} The packages are not on the Racket package server yet; clone the repositories
side by side and install from source:

@verbatim{
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx
}

@bold{2. Ask it something.} Over the R5 core by default, or any package with @litchar{--package}:

@verbatim{
$ raco fhir-tx expand http://hl7.org/fhir/ValueSet/administrative-gender
{"resourceType": "ValueSet", ..., "expansion": {"contains": [{"system": "http://hl7.org/fhir/administrative-gender", "code": "male", "display": "Male"}, ...]}}
$ raco fhir-tx validate-code http://hl7.org/fhir/ValueSet/administrative-gender http://hl7.org/fhir/administrative-gender female
{"resourceType": "Parameters", "parameter": [{"name": "result", "valueBoolean": true}, ...]}
$ raco fhir-tx expand http://hl7.org/fhir/us/core/ValueSet/us-core-condition-code --package hl7.fhir.us.core-6.1.0.tgz --filter diab
}

@bold{3. Serve it.} @tt{raco fhir-tx serve --package hl7.fhir.us.core-6.1.0.tgz --port 8080} puts
every operation over HTTP; @tt{GET /metadata} is the CapabilityStatement, @tt{GET
/metadata?mode=terminology} the TerminologyCapabilities.

@section{Using it}

@subsection{Command line}

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @tt{raco fhir-tx expand <ValueSet url> [--filter t] [--count n] [--offset n]} "the expansion")
      (list @tt{raco fhir-tx validate-code <ValueSet url> <system> <code> [--display t]} "is the code in the set")
      (list @tt{raco fhir-tx lookup <system> <code>} "a concept's details")
      (list @tt{raco fhir-tx translate <ConceptMap url> <code> [--system s]} "a code through a map")
      (list @tt{raco fhir-tx subsumes <system> <codeA> <codeB>} "the subsumption relation")
      (list @tt{raco fhir-tx serve [--port n]} "every operation over HTTP")
      (list @tt{raco fhir-tx tck [-v]} "the tx-ecosystem suite, floor-ratcheted"))]

@litchar{--package} names a .tgz or a file in @tt{fhir-spec}, repeatable, searched in order; with
none, the R5 core. The answer is the operation's FHIR JSON. Exit codes: 0, 1 when the operation
fails or the suite regresses, 2 on usage.

@subsection{As operations}

@racketblock[
(require fhir/terminology/operations)
($expand #:url "http://hl7.org/fhir/ValueSet/administrative-gender")
($expand #:valueSet vs #:filter "fem")                       (code:comment "a ValueSet you hold")
($validate-code #:url "http://hl7.org/fhir/ValueSet/administrative-gender"
                #:system "http://hl7.org/fhir/administrative-gender" #:code "female")
($lookup #:system "http://loinc.org" #:code "85354-9")
($subsumes #:system "http://snomed.info/sct" #:codeA "73211009" #:codeB "44054006")
]

The packages searched are @racket[current-sd-packages]; resources in @racket[current-data-source]
come first. An implicit VCL url (@tt{http://fhir.org/VCL?v1=…}) expands too.

@subsection{From Racket}

A @italic{resolver} is @tt{(url [version]) -> resource | #f}; the JSON-level functions take one and
answer FHIR JSON with no tower loaded. @racket[make-terminology/resolver] wraps one as the
@racket[tx-service] handle the validator and FHIRPath's @tt{%terminologies} take.

@racketblock[
(require fhir/terminology/service)
(define r (packages->resolver (list "hl7.fhir.us.core-6.1.0.tgz" "hl7.fhir.r4.core.tgz")))
(expand/json r "http://hl7.org/fhir/us/core/ValueSet/us-core-condition-code" #f (hash "filter" "diab"))
(validate-code/json r "http://hl7.org/fhir/ValueSet/administrative-gender" "female"
                    "http://hl7.org/fhir/administrative-gender")
(define tx (make-terminology/resolver r))
(eval-fhirpath ast root #:externals (hash "terminologies" (list tx)))   (code:comment "fhirpath")
]

@section{How terminology is handled}

Codes are checked at three times by three mechanisms:

@itemlist[
@item{@bold{When a resource form compiles.} Code generation expands every required binding whose
ValueSet enumerates its codes or includes a whole CodeSystem from the same package (202 value sets
in R6), and the @tt{fhir/r6} forms reject a literal code outside its set. Filters, imports and
excludes fail open.}
@item{@bold{When a resource is validated.} The validator checks required bindings through a
@racket[tx-service] when given one, else against the same offline sets. Only @tt{$validate} builds
a service; @tt{raco fhir-validate}, the generated servers and @tt{raco fsh check} pass none.}
@item{@bold{At run time}, this service: over packages or resources, indexed lazily per package, as
operations, as FHIRPath's @tt{expand()}, @tt{validateVS()} and @tt{translate()}, over HTTP, and
for VCL's implicit urls.}]

CQL takes value set expansions as data and does not call the service; FSH records a binding's
strength and url and validates no codes; FML's @tt{translate} asks it for ConceptMaps the map does
not embed.

@section{Limits}

@itemlist[
@item{@bold{What the terminology service does not do.} CodeSystem supplements apply only when
named by @tt{useSupplement}; nothing discovers them. @tt{$closure} tables live in the process.
@tt{$find-matches} matches properties exactly or by substring, with no compositional grammar.
@tt{$expand} does not take @tt{includeDefinition}, @tt{excludeNotForUI} or @tt{limit}, and emits no
@tt{abstract} or @tt{inactive} flags; @tt{displayLanguage} matches a tag exactly. @tt{$translate}
is forward only, by source code and system, with no target, @tt{dependsOn} or @tt{unmapped}
handling and no ConceptMap version. Hierarchy comes from nested concepts, not from @tt{parent} or
@tt{subsumedBy} properties. Version resolution picks the highest version by string order. Anything
resting on a code system the service cannot see (SNOMED CT, LOINC, RxNorm) is undecidable and
reported as unknown, never as invalid; the tx-ecosystem suite stands at 473/553 with those skipped.}
@item{@bold{FHIRPath's @tt{%terminologies}} offers @tt{expand()} (with a Parameters argument),
@tt{validateVS()} and @tt{translate()} (a code, a Coding or a CodeableConcept, and a system); the
handle has no @tt{lookup()}, @tt{subsumes()} or @tt{validateCS()}.}]

@section{Reference}

@subsection[#:style 'unnumbered]{@tt{fhir/terminology/service}}
@defmodule[fhir/terminology/service]

A terminology server as a value. Expansion follows @tt{compose} (includes, excludes, filters over
the code system's concepts and properties, nested value sets, version pins including @tt{1.x.x}
patterns, implicit VCL urls) with the expansion parameters (offset, count, activeOnly, filter,
displayLanguage, includeDesignations, property). Validation takes a code, a Coding or a
CodeableConcept, checks displays against designations, and honours system and value set versions.
What rests on a code system the service does not have (SNOMED, LOINC) is undecidable; the
hl7.fhir.uv.tx-ecosystem suite is at 473/553 with those skipped.

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
@deftogether[(
@defproc[(cs-validate-code/json [resolver procedure?] [system string?] [code string?] [version (or/c string? #f) #f] [#:display display any/c #f]) hash?]
@defproc[(subsumes/json [resolver procedure?] [system string?] [code-a string?] [code-b string?] [version (or/c string? #f) #f]) hash?]
@defproc[(find-matches/json [resolver procedure?] [system string?] [properties (listof (cons/c string? string?))] [version (or/c string? #f) #f] [exact? boolean? #t]) hash?]
@defproc[(closure-relation [resolver procedure?] [system string?] [code-a string?] [code-b string?]) (or/c string? #f)]
@defproc[(packages->code-systems [packages (listof path-string?)]) (listof hash?)]
@defproc[(terminology-capabilities [code-systems (listof hash?)] [#:url url (or/c string? #f) #f]) hash?])]{
CodeSystem-level validation, subsumption (@racket["equivalent"], @racket["subsumes"],
@racket["subsumed-by"], @racket["not-subsumed"]; an unknown system or code raises), concepts
matching every property given, the ConceptMap relationship between two codes for @tt{$closure}, the
CodeSystems a package list holds, and the TerminologyCapabilities describing them.}
@deftogether[(@defproc[(make-lookup [resolver procedure?]) procedure?] @defproc[(make-cs-validate [resolver procedure?]) procedure?] @defproc[(make-undecidable? [resolver procedure?]) procedure?])]{
CodeSystem-level @tt{$lookup} and @tt{$validate-code} as closures answering FHIRPath collections, and
the test for a ValueSet that would need a code system the service lacks.}

@subsection[#:style 'unnumbered]{@tt{fhir/terminology/operations}}
@defmodule[fhir/terminology/operations]

@deftogether[(
@defthing[$expand procedure?]
@defthing[$validate-code procedure?]
@defthing[$cs-validate-code procedure?]
@defthing[$lookup procedure?]
@defthing[$subsumes procedure?]
@defthing[$find-matches procedure?]
@defthing[$translate procedure?]
@defthing[$closure procedure?])]{
The four as @tt{fhir/operation} values on the core OperationDefinitions, registered when the module
loads. A ValueSet is the subject, @tt{#:valueSet}, or named by @tt{#:url}; the inputs are the
definitions' parameters (@racket[($translate cm #:sourceCode "a" #:system url)]). Resources are
looked up in the inputs, then @racket[current-data-source], then @racket[current-sd-packages].}
@defproc[(current-terminology-resolver [extra (listof hash?) '()]) procedure?]{The resolver the operations use: @racket[extra], then the data source (asked by url when it searches, as a store does), then the packages.}
@defthing[terminology-operations (listof procedure?)]{All eight, in the order a server lists them.}
@defproc[(current-terminology-capabilities [#:url url (or/c string? #f) #f]) hash?]{A TerminologyCapabilities over the code systems in @racket[current-sd-packages].}
