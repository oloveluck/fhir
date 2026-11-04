#lang scribble/manual
@(require (for-label (except-in racket/base make-string make-date read-string write-string) racket/contract
                     fhir/result/result fhir/model/node fhir/model/leaf fhir/model/registry
                     fhir/serialize/to-json fhir/serialize/from-json fhir/serialize/read-json
                     fhir/primitives/primitives fhir/package fhir/spec-package fhir/operation
                     fhir/data-source fhir/diagnostic fhir/sd/sd-index fhir/sd/snapshot
                     fhir/sd/element-index fhir/sd/operations))

@title{fhir: the foundation}

FHIR as a family of Racket languages. This package is the foundation the others build on: the
@racket[result] type, the typed node model and its registry, the primitive types, the JSON reader and
writer, the FHIR NPM package reader, StructureDefinition tooling (an index over packages, snapshot
generation), FHIR operations as procedures, data sources, and the diagnostics every language
reports. The R4, R5 and R6 type towers are generated from the HL7 specifications; R6 comes with
@hash-lang[] @tt{fhir/r6}, where a resource is a form checked as it compiles.

The other packages: @tt{fhir-spec} (the vendored HL7 packages), @tt{fhir-tx} (the terminology
service), @tt{fhir-validation} (the validator), @tt{fhir-server} (servers generated from Implementation Guides), and the
languages @tt{fhirpath}, @tt{cql}, @tt{fsh}, @tt{vcl}, @tt{fml} and @tt{sql-on-fhir}, each its own
package and repository.

@table-of-contents[]

@section{Install}

@verbatim{
raco pkg install --link --auto fhir/fhir fhir/fhir-spec
    # from source, in the fhir repository
}

@tt{fhir} depends on nothing but @tt{base}. @tt{fhir-spec} is data: codegen, snapshot generation,
the validator's profile index and the conformance suites read it through @racket[spec-package-path].

@section{Writing resources: @hash-lang[] @tt{fhir/r6}}

Each top-level form @racket[(Type (field value ...) ...)] builds a typed node of an R6 resource or
datatype. A list field takes several values, a complex field a nested form of its type, a choice
element its concrete name (@tt{deceasedBoolean}), a primitive a string, number or boolean literal.

@racketmod[fhir/r6
(Patient
 (id "example") (active #t) (gender "male") (birthDate "1974-12-25")
 (name (HumanName (use "official") (family "Chalmers") (given "Peter" "James")))
 (contact (PatientContact (name (HumanName (family "du Marché"))) (gender "female"))))]

Checked as the module compiles: unknown or duplicate fields, cardinality, a missing required field,
the head of a nested form, a primitive's lexeme (@racket[(birthDate "1974-13-40")]), and the codes of
required bindings (@racket[(gender "florp")] lists the valid codes). A non-literal value is checked
when it runs.

@tt{racket patient.fhir6} prints each resource as JSON. @racket[(require "forms.fhir6")] gives
@racket[resources] (the typed nodes), @racket[(->nodes)] and @racket[(->json)] (jsexprs):

@racketblock[
(require (only-in "forms.fhir6" [->json forms]))
(for/list ([form (in-list (forms))]) (~> form intake->reading (ensure-valid #:profile url)))
]

R4 and R5 are schema-only towers: @racket[(require fhir/r4/schemas)] or @racket[fhir/r5/schemas]
registers their types for @racket[from-json], FHIRPath and the validator, with no forms.
@racket[fhir/r4/operations], @racket[fhir/r5/operations] and @racket[fhir/r6/operations] carry each
version's OperationDefinitions as data (@tt{<code>-definition}).

@subsection[#:style 'unnumbered]{Profiles as forms: @hash-lang[] @tt{fhir/sd}}
@defmodulelang[fhir/sd]

@racket[(profile Name #:base Base (field min max) ...)] defines @racket[Name] as a form like its base
with the narrowed cardinalities, checked at compile time (a profile may only narrow; @tt{max} is a
number or @tt{*}). Full profiles are written in FSH (the @tt{fsh} package); this is the small
in-Racket form.

@racketmod[fhir/sd
(profile USCorePatient #:base Patient (name 1 *) (gender 1 1))
(profile VIPPatient #:base USCorePatient (name 1 1))]

@section{Using it from Racket}

@bold{JSON in and out.} Load a tower, then @racket[from-json] gives a typed node and
@racket[node->jsexpr] gives it back.

@racketblock[
(require fhir/r5/schemas fhir/serialize/from-json fhir/serialize/to-json fhir/serialize/read-json
         fhir/model/node fhir/model/leaf fhir/result/result)
(define p (ok-value (from-json (call-with-input-file "patient.json" read-fhir-json)
                               #:lenient? #t)))
(fhir-type p)                                  (code:comment "'Patient")
(node-str p 'gender)                           (code:comment "\"male\"")
(pv (fhir-ref (car (listify (fhir-ref p 'name))) 'family))   (code:comment "\"Chalmers\"")
(node->json-string p)                          (code:comment "decimals as written")
]

Strict @racket[from-json] returns an @racket[err] for an unknown element; lenient parsing skips it.
@racket[read-fhir-json] keeps each number's lexeme, so @racket["1.50"] survives a round trip.

@bold{Operations as procedures.} An operation is applied by reference to its OperationDefinition,
with its parameters as keywords; the subject is the first argument; @racket[~>] threads a value
through several. Loading a package's @tt{operations} module registers what it implements.

@racketblock[
(require fhir/operation fhir/data-source
         (code:comment "fhir-validation")
         (only-in fhir/conformance/operations ensure-valid)
         (code:comment "fhir-tx")
         (only-in fhir/terminology/operations $expand)
         (only-in fml/operations))                              (code:comment "fml")
(apply-operation "StructureMap/$transform" qr #:srcMap fml-text)
(define transform (operation "StructureMap/$transform"))
(~> qr (transform #:srcMap fml-text) (ensure-valid))
(apply-operation "ValueSet/$validate-code"
                 #:url "http://hl7.org/fhir/ValueSet/administrative-gender"
                 #:system "http://hl7.org/fhir/administrative-gender" #:code "female")
(code:comment "a failure as its OperationOutcome")
(apply-operation/outcome "$validate" patient #:profile url)
]

Context comes from two parameters: @racket[current-data-source], where an operation finds resources
(the ValueSet @tt{$expand} is asked for, the profile @tt{$validate} is given), and
@racket[current-sd-packages], the FHIR packages profiles and value sets resolve from (an IG, its
dependencies, then core).

@racketblock[
(parameterize ([current-data-source (resources->data-source clinic)]
               [current-sd-packages (list "hl7.fhir.us.core-6.1.0.tgz" "hl7.fhir.r4.core.tgz")])
  (ensure-valid observation
                #:profile "http://example.org/StructureDefinition/screening-blood-pressure"))
]

@bold{Packages.} @racket[read-package] reads a FHIR NPM package's manifest, resources and examples;
@racket[spec-package-path] finds one of the vendored HL7 packages, or one in
@racket[current-package-directories].

@bold{Diagnostics.} Every language reports problems as @racket[diagnostic] values, positioned; the
CLIs render them as text with a caret, JSON, or an OperationOutcome (@litchar{--format}).

@bold{Command line.}

@verbatim{
raco fhir regen [r6|r4|r5|all]      regenerate the type towers from fhir-spec
raco fhir check [r6|r4|r5|all]      the committed towers match a fresh regeneration
raco fhir roundtrip <file.json> [Type]
raco fhir roundtrip-tck [r4|r5]     parse and serialize the whole core corpus
raco fhir snapshot <sd.json>
}

@litchar{-h} on the tool or any command prints usage and exits 0; a usage error or missing file is one
line on stderr, exit 2; drift or a failed parse exits 1.

@section{Limits}

@itemlist[
@item{Forms exist for R6 only. R4 and R5 are schema towers for parsing, navigation and validation;
there is no @tt{#lang fhir/r4} or @tt{fhir/r5}.}
@item{Snapshot generation covers the differential merge, named slices and datatype expansion;
not reslicing, discriminator inference, @tt{[x]} slice expansion or @tt{contentReference}. The
HL7 snapshot cases stand at 80/80 paths, 476/478 cardinalities, 235/236 types; the rest are
version-induced.}
@item{Compile-time bindings cover required bindings on @tt{code} elements whose value set enumerates
its codes or includes a whole system from the same package; filters, imports and excludes fail
open.}
@item{Generating an IG's own resources as a tower (a @racket[gen-target] with a delegate base) is a
recipe that has been exercised, but no IG target is configured.}
@item{JSON only: no XML anywhere in the family.}]

@section{Reference}

@subsection[#:style 'unnumbered]{@hash-lang[] @tt{fhir/r6}}
@defmodulelang[fhir/r6]

Provides @racket[resources], @racket[(->nodes)] and @racket[(->json)], as above; the form macros are
the R6 types from @racket[fhir/r6/types].

@subsection[#:style 'unnumbered]{@tt{fhir/result/result}}
@defmodule[fhir/result/result]

Validation returns data, not exceptions. Every error carries the spec url of the rule.

@deftogether[(@defstruct*[ok ([value any/c])] @defstruct*[err ([error any/c])] @defproc[(result? [v any/c]) boolean?])]
@defstruct*[validation-error ([type symbol?] [spec-url (or/c string? #f)])]{
The base of @racket[pattern-mismatch], @racket[out-of-range], @racket[length-exceeded],
@racket[precision-exceeded], @racket[invalid-encoding], @racket[unknown-field], @racket[missing-field]
and @racket[multiple] (a list of errors).}
@deftogether[(
@defproc[(result-map [f (-> any/c any/c)] [r result?]) result?]
@defproc[(result-bind [r result?] [f (-> any/c result?)]) result?]
@defproc[(result-traverse [rs (listof result?)] [#:accumulate? accumulate? boolean? #f]) result?])]{
Functor, monad, sequence; with @racket[accumulate?] every error is collected into a
@racket[multiple] instead of the first short-circuiting.}
@defproc[(ok-or-raise [r result?]) any/c]{The value, or an error.}
@defproc[(validation-error-message [e validation-error?]) string?]

@subsection[#:style 'unnumbered]{@tt{fhir/model/node}}
@defmodule[fhir/model/node]

@defstruct*[fhir ([type symbol?] [fields hash?])]{
The one in-memory value: a type and the fields present (a single value, or a list for a repeating
field). Primitives inside it are the structs of @tt{fhir/primitives/primitives}.}
@defproc[(fhir-ref [node fhir?] [field symbol?] [default any/c #f]) any/c]
@defproc[(fhir-has? [node fhir?] [field symbol?]) boolean?]
@defproc[(fhir-field-names [node fhir?]) (listof symbol?)]

@subsection[#:style 'unnumbered]{@tt{fhir/model/leaf}}
@defmodule[fhir/model/leaf]

@defproc[(pv [v any/c]) any/c]{A primitive's value; anything else passes through.}
@defproc[(listify [v any/c]) list?]{A repeating field's value as a list, always.}
@defproc[(node-str [node fhir?] [field symbol?]) (or/c string? #f)]{A leaf rendered as a string, or @racket[#f].}

@subsection[#:style 'unnumbered]{@tt{fhir/model/registry}}
@defmodule[fhir/model/registry]

Every FHIR type knows the spec that defines it. Loading a tower registers its types; the registry
is what @racket[from-json], the form macros, FHIRPath's type system and the validator consult.

@defstruct*[fhir-spec ([name string?] [url string?] [constraint any/c])]
@defstruct*[type-info ([spec fhir-spec?] [schema any/c] [predicate any/c] [constructor any/c])]
@deftogether[(
@defproc[(type-registered? [type symbol?]) boolean?]
@defproc[(type-spec-of [type symbol?]) (or/c fhir-spec? #f)]
@defproc[(type-schema-of [type symbol?]) any/c]
@defproc[(type-predicate-of [type symbol?]) (or/c procedure? #f)]
@defproc[(type-constructor-of [type symbol?]) (or/c procedure? #f)]
@defproc[(all-types) (listof symbol?)])]{Complex types and resources.}
@deftogether[(
@defproc[(primitive-name? [name symbol?]) boolean?]
@defproc[(spec-of [name symbol?]) (or/c fhir-spec? #f)]
@defproc[(predicate-of [name symbol?]) (or/c procedure? #f)]
@defproc[(constructor-of [name symbol?]) (or/c procedure? #f)]
@defproc[(registered-names) (listof symbol?)])]{Primitives.}
@deftogether[(
@defproc[(element-spec-of [path string?]) (or/c fhir-spec? #f)]
@defproc[(registered-element-paths) (listof string?)])]{Elements by path.}

@subsection[#:style 'unnumbered]{@tt{fhir/primitives/primitives}}
@defmodule[fhir/primitives/primitives]

The 23 FHIR primitive types, each a struct with @racket[id], @racket[extension] and @racket[value],
a validating constructor and a JSON writer: @racket[fhir-string], @racket[make-string],
@racket[fhir-date], @racket[make-date], and so on for @tt{id}, @tt{code}, @tt{markdown}, @tt{uri},
@tt{url}, @tt{canonical}, @tt{oid}, @tt{uuid}, @tt{base64Binary}, @tt{xhtml}, @tt{boolean},
@tt{integer}, @tt{integer64}, @tt{positiveInt}, @tt{unsignedInt}, @tt{decimal} (string-backed, so
precision survives), @tt{time}, @tt{dateTime} and @tt{instant}. @racket[(make-date "1974-13-40")]
is an @racket[err] naming the pattern and its spec url. The module re-exports the results, the
registry and the temporal structs @racket[t-date], @racket[t-time] and @racket[t-datetime] (components
and a precision).

@defproc[(primitive->jsexpr [p primitive-type?]) (or/c string? boolean? real? 'null)]
@defproc[(temporal->string [t any/c]) string?]

@tt{fhir/primitives/literals} provides @racket[(lit date "1974-12-25")]: a primitive literal
validated at compile time.

@subsection[#:style 'unnumbered]{@tt{fhir/serialize/from-json}}
@defmodule[fhir/serialize/from-json]

@defproc[(from-json [js any/c] [#:type type (or/c symbol? #f) #f] [#:lenient? lenient? boolean? #f]) result?]{
FHIR JSON to a typed node, driven by the registered schema. A resource carries its
@tt{resourceType}; a bare datatype needs @racket[type]. Strict by default: an unknown element is an
@racket[err]. Lenient parsing skips unknown keys and drops fields that do not parse, and never
raises, so data from a newer FHIR version still loads.}

@subsection[#:style 'unnumbered]{@tt{fhir/serialize/to-json}}
@defmodule[fhir/serialize/to-json]

@defproc[(node->jsexpr [node fhir?]) jsexpr?]{The structured view: decimals as numbers.}
@defproc[(node->json-string [node fhir?]) string?]{Precise text: decimals as the tokens they were read as, so @racket["1.50"] survives.}

@subsection[#:style 'unnumbered]{@tt{fhir/serialize/read-json}}
@defmodule[fhir/serialize/read-json]

A JSON reader that keeps each number's lexeme in a @racket[jnum], so decimals round-trip.

@defstruct*[jnum ([lexeme string?])]
@defproc[(read-fhir-json [in input-port?]) any/c]
@defproc[(read-fhir-json/duplicates [in input-port?]) (values any/c (listof string?))]{Also the dotted paths of duplicate object keys the reader collapsed.}
@defproc[(string->fhir-jsexpr [s string?]) any/c]
@defproc[(jnum-value [n jnum?]) real?]
@defproc[(strip-jnum [v any/c]) any/c]{A plain jsexpr.}

@subsection[#:style 'unnumbered]{@tt{fhir/package}}
@defmodule[fhir/package]

@defproc[(read-package [tgz path-string?] [#:exact-decimals? exact-decimals? boolean? #f] [#:select select (-> string? any/c) (lambda (f) #t)])
         (values (or/c hash? #f) (listof (cons/c string? hash?)) (listof (cons/c string? hash?)))]{
A FHIR NPM package: its manifest, its resources (@tt{package/*.json}) and its examples
(@tt{package/example/*.json}), each as @racket[(cons file-name resource)]. @racket[select] filters by
file name before parsing.}

@subsection[#:style 'unnumbered]{@tt{fhir/spec-package}}
@defmodule[fhir/spec-package]

@defproc[(spec-package-path [file string?] [#:optional? optional? boolean? #f]) (or/c path? #f)]{
A package by file name (@racket["hl7.fhir.r5.core.tgz"]): @racket[current-package-directories] first,
then the @tt{fhir-spec} collection. Missing is an error unless @racket[optional?].}
@defparam[current-package-directories dirs (listof path-string?)]{Directories of packages searched before @tt{fhir-spec}, for fetched IGs.}
@defproc[(spec-package-available?) boolean?]{Is @tt{fhir-spec} installed.}

@subsection[#:style 'unnumbered]{@tt{fhir/sd/sd-index}}
@defmodule[fhir/sd/sd-index]

@defparam[current-sd-packages packages (or/c #f (listof path-string?))]{
The packages (.tgz) profiles, value sets and code systems resolve from, in priority order: an IG, its
dependencies, then core. @racket[#f] means @tt{fhir-spec}'s R5 core. The validator, the terminology
service and the FSH compiler all read it.}
@defproc[(resolve-sd-raw [ref string?]) (or/c hash? #f)]{A StructureDefinition by canonical (a @tt{|version} is dropped), name, id or bare type code.}
@defproc[(resolve-canonical-raw [type (or/c "CodeSystem" "ValueSet" "StructureDefinition")] [ref string?]) (or/c hash? #f)]
@defproc[(sd-context) (listof path?)]{The effective package list: a cache key.}
@defproc[(sd-index-available?) boolean?]

@subsection[#:style 'unnumbered]{@tt{fhir/sd/snapshot}}
@defmodule[fhir/sd/snapshot]

@defproc[(generate-snapshot [sd hash?]) list?]{
The snapshot elements of a profile: the base's snapshot re-rooted, the differential merged element by
element (constraints accumulate), named slices re-rooted, datatypes the profile dives into expanded.
With no resolvable base, the differential.}
@defproc[(snapshot-paths [elements list?]) list?]

@subsection[#:style 'unnumbered]{@tt{fhir/sd/element-index}}
@defmodule[fhir/sd/element-index]

@defproc[(make-element-index [elements (listof hash?)]) element-index?]{O(1) lookups over a snapshot.}
@deftogether[(
@defproc[(element-index? [v any/c]) boolean?]
@defproc[(index-elements [ix element-index?]) (listof hash?)]
@defproc[(index-root [ix element-index?]) (or/c hash? #f)]
@defproc[(child-elements [ix element-index?] [path string?]) (listof hash?)]
@defproc[(slices-of [ix element-index?] [path string?]) (listof hash?)]
@defproc[(index-by-id [ix element-index?] [id string?]) (or/c hash? #f)])]
@defproc[(type-index [type string?]) (or/c element-index? #f)]{A type code's snapshot index, cached per @racket[sd-context].}
@defproc[(opaque-type? [type string?]) boolean?]{Resource, DomainResource, Element, BackboneElement, Extension.}

@subsection[#:style 'unnumbered]{@tt{fhir/sd/operations}}
@defmodule[fhir/sd/operations]

@defthing[$snapshot procedure?]{@tt{StructureDefinition/$snapshot} as an operation: @racket[($snapshot sd)] or @racket[(apply-operation "$snapshot" #:url canonical)].}

@subsection[#:style 'unnumbered]{@tt{fhir/operation}}
@defmodule[fhir/operation]

A FHIR operation is an OperationDefinition plus an implementation, with nothing about HTTP: a
procedure whose keyword arguments are the definition's parameters. Applying is
@racket[(op subject #:name value ...)]: the subject is the resource the operation applies to, a
Parameters resource may carry inputs, a list gives several values; strings are converted for
integer, decimal and boolean parameters; an unknown keyword is an error listing the parameters. The
result is the @tt{return} resource, or a Parameters of the outputs. The packages register their
operations when loaded: @tt{$validate} and @racket[ensure-valid] (fhir-validation), @tt{$expand},
@tt{$validate-code}, @tt{$lookup}, @tt{$translate} (fhir-tx), @tt{$transform} (fml),
@tt{$evaluate-measure} (cql), @tt{$sql-run} (sql-on-fhir), @tt{$snapshot} (here).

@racketblock[
(apply-operation "StructureMap/$transform" qr #:srcMap fml)
(define transform (operation "StructureMap/$transform"))
(~> qr (transform #:srcMap fml) (ensure-valid) ($snapshot))]

@defproc[(operation [ref (or/c string? hash? operation?)]) operation?]{
A reference resolved to a procedure: a canonical url, an OperationDefinition, @racket["$code"], or
@racket["Type/$code"] when a code is ambiguous.}
@deftogether[(
@defproc[(apply-operation [ref any/c] [subject any/c] ... [#:name value any/c] ...) hash?]
@defproc[(apply-operation/outcome [ref any/c] [subject any/c] ... [#:name value any/c] ...) hash?])]{
Apply by reference; the second returns a failure's OperationOutcome instead of raising.}
@defform[(~> expr (proc arg ...) ...)]{Threads a value: each form receives the previous value as its first argument.}
@defstruct*[(exn:fail:operation exn:fail) ([outcome hash?])]{What a failure raises.}
@defproc[(make-operation [definition hash?] [run (-> hash? any/c any/c)] [#:subject subject (or/c string? #f) #f]) operation?]{
An implementation: @racket[run] takes the inputs (name to a list of values) and the subject.
@racket[subject] names the input the subject fills (@racket["resource"] for @tt{$validate}), or
@racket[#f] when the operation applies to the subject itself.}
@defproc[(register-operation! [op operation?]) void?]{Makes it resolvable by its canonical.}
@defproc[(registered-operations) (listof operation?)]
@deftogether[(
@defproc[(operation? [v any/c]) boolean?]
@defproc[(operation-definition [op operation?]) hash?]
@defproc[(operation-code [op operation?]) string?]
@defproc[(operation-url [op operation?]) (or/c string? #f)]
@defproc[(operation-subject [op operation?]) (or/c string? #f)]
@defproc[(operation-levels [op operation?]) (listof (or/c 'system 'type 'instance))]
@defproc[(operation-resource-types [op operation?]) (listof string?)])]
@defproc[(invoke [op operation?] [subject any/c] [inputs hash?]) hash?]{The host form: a server's request Parameters as an inputs hash.}
@defproc[(input [inputs hash?] [name string?] [default any/c]) any/c]{For implementations: the first value given for a name.}
@defproc[(operation-error [issue-code string?] [format string?] [arg any/c] ...) none/c]{Raises @racket[exn:fail:operation].}
@deftogether[(
@defproc[(outcome [severity string?] [code string?] [diagnostics string?]) hash?]
@defproc[(outcome-errors? [outcome hash?]) boolean?]
@defproc[(parameters->inputs [parameters hash?]) hash?]
@defproc[(outputs->parameters [op operation?] [outputs hash?]) hash?])]

@subsection[#:style 'unnumbered]{@tt{fhir/data-source}}
@defmodule[fhir/data-source]

Where an operation's data comes from, independent of any server.

@defstruct*[data-source ([all procedure?] [read procedure?] [of-patient procedure?] [search (or/c procedure? #f)])]{
@racket[all] is @tt{type -> resources}, @racket[read] is @tt{type id -> resource | #f},
@racket[of-patient] is @tt{type patient-id -> resources}, @racket[search] takes a type and
parameters, or is @racket[#f]. Resources are FHIR JSON. fhir-server's @tt{store->data-source} gives
one with real search.}
@defparam[current-data-source source data-source?]{What operations read; @racket[empty-data-source] by default.}
@defproc[(resources->data-source [resources (listof hash?)]) data-source?]{In memory; Bundles contribute their entries.}
@defproc[(directory->data-source [dir path-string?]) data-source?]{Every @tt{.json} under it, read once.}
@defthing[empty-data-source data-source?]
@defproc[(patient-reference-of [resource hash?]) (listof string?)]{The @tt{Patient/id} references in @tt{patient}, @tt{subject}, @tt{beneficiary} and @tt{individual}.}
@defproc[(bundle-resources [bundle hash?]) (listof hash?)]{A Bundle's entries, nested Bundles flattened; any other resource as itself.}

@subsection[#:style 'unnumbered]{@tt{fhir/diagnostic}}
@defmodule[fhir/diagnostic]

Every language reports errors as one value, rendered three ways: text with the source line and a
caret, JSON, or a FHIR OperationOutcome with the standard line, column and source extensions. The
CLIs take @litchar{--format text|json|outcome}.

@defstruct*[loc ([source any/c] [line exact-integer?] [column exact-integer?] [position exact-integer?] [span exact-integer?]) #:prefab]{1-based line and column.}
@defstruct*[diagnostic ([lang symbol?] [phase symbol?] [severity (or/c 'error 'warning)] [message string?] [loc (or/c loc? #f)]) #:prefab]{
@racket[lang] is @racket['fsh], @racket['cql], @racket['fhirpath], @racket['vcl] or @racket['fml];
@racket[phase] is @racket['lex], @racket['parse], @racket['compile], @racket['validate],
@racket['server] or @racket['run].}
@defstruct*[(exn:fail:diagnostic exn:fail) ([diagnostic diagnostic?])]{The carrier FSH and FHIRPath raise; it has @racket[prop:exn:srclocs].}
@defproc[(raise-diagnostic [d diagnostic?]) any]
@defproc[(exn->diagnostic [e exn?] [lang symbol?] [#:phase phase symbol? 'parse] [#:source source any/c #f]
                          [#:line-offset line-offset exact-integer? 0] [#:last-position last-position (or/c exact-integer? #f) #f]
                          [#:unit unit string? "input"] [#:ran-out? ran-out? (-> any/c) (lambda () #f)]) diagnostic?]{
A parser's exception as a diagnostic: brag's message becomes words, and when the failure sits on the
last token a probe tells whether the input ran out ("the entity ends after @tt{=}").}
@deftogether[(
@defproc[(diagnostic->string [d diagnostic?] [#:text text (or/c string? #f) #f]) string?]
@defproc[(diagnostic->jsexpr [d diagnostic?]) hash?]
@defproc[(diagnostics->operation-outcome [ds (listof diagnostic?)]) hash?])]{The three renderings; with @racket[text], the source line and a caret.}
@defproc[(emit-diagnostics [ds (listof diagnostic?)] [#:format format (or/c 'text 'json 'outcome) 'text] [#:text-of text-of (-> any/c (or/c string? #f)) (lambda (s) #f)]) void?]{Text to stderr; JSON and outcome to stdout.}
@defproc[(format-flag [args (listof string?)]) (values (or/c 'text 'json 'outcome) (listof string?))]{Takes @litchar{--format} out of a command line.}
@deftogether[(
@defproc[(attach-diagnostic! [v any/c] [d diagnostic?]) any]
@defproc[(attached-diagnostic [v any/c]) (or/c diagnostic? #f)]
@defproc[(attach-loc! [v any/c] [l loc?]) any]
@defproc[(attached-loc [v any/c]) (or/c loc? #f)])]{Diagnostics and positions attached to values that are not exceptions (VCL's error payload, CQL's definitions).}
@deftogether[(
@defproc[(tokens->last-position [tokens list?] [position-of (-> any/c (or/c exact-integer? #f))]) (or/c exact-integer? #f)]
@defproc[(error-position [e exn?]) (or/c exact-integer? #f)])]

