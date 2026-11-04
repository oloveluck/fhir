#lang scribble/manual
@(require (for-label racket/base racket/contract
                     fhir/capability/runtime fhir/capability/derive fhir/capability/operations
                     fhir/http/server fhir/http/router fhir/store/fhir-sqlite fhir/store/fhir-engine
                     fhir/store/serve fhir/store/ig-server fhir/store/bundle fhir/store/load fhir/store/measure
                     fhir/store/data-source))

@title{fhir-server: FHIR servers generated from specs}

Three layers. @hash-lang[] @tt{fhir/capability} declares what an app supports and derives its
CapabilityStatement and OperationDefinitions, so @tt{/metadata} cannot drift from the code. A small
HTTP server maps the FHIR REST grammar onto that app, with an embedded SQLite store behind it
(versioned CRUD, type-driven search from the IG's SearchParameters, transactions, audit and
provenance). And @racket[make-ig-server] generates a whole server from an Implementation Guide
package: its CapabilityStatement gives the types, interactions, search parameters, includes and
operations; its profiles validate every write; what the IG asks for and the server does not do is
reported as a gap. US Core has none; six more IGs are held to their own examples in the
fhir-examples repository.

Part of the @hyperlink["https://github.com/oloveluck/fhir"]{fhir} family, in the @tt{fhir}
collection; depends on @tt{fhir}, @tt{fhir-spec}, @tt{fhirpath}, @tt{fhir-validation}, @tt{cql} and
@tt{db-lib}.

@table-of-contents[]

@section{Install}

@verbatim{
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-validation cql fhir/fhir-server
    # from source
}

@section{Using it}

@bold{A server from an Implementation Guide.} The package gives everything: types, interactions,
search parameters, includes, profiles (every write validated), operations. The IG's examples are
loaded first.

@verbatim{
raco fhir-server serve-ig hl7.fhir.us.core --port 8080
    a package in fhir-spec, a .tgz, or a path
raco fhir-server serve-ig my-ig-0.1.0.tgz --capability my-server --load data/ --db store.db
raco fhir-server serve-ig hl7.fhir.us.core --gaps
    what the IG asks for that is not served
curl localhost:8080/metadata
curl 'localhost:8080/Patient?name=Chalmers&_include=Patient:general-practitioner'
}

@litchar{--capability <id|url>} picks the server CapabilityStatement when the IG ships several;
@litchar{--load} takes Bundles, resources or @tt{.cql} files (as Library resources); @litchar{--db} keeps the
store between runs (SQLite); @litchar{--bearer <token>} requires a static token; @litchar{--tz-offset ±hh:mm}
sets the evaluation timezone; @litchar{--no-examples}, @litchar{--no-validate}. A package written by
@tt{raco fsh --pack} serves the same way, with its dependencies resolved from @tt{fhir-spec}.

From Racket, the same server is a value:

@racketblock[
(require fhir/store/fhir-sqlite fhir/store/ig-server fhir/http/server)
(define store (open-fhir-store "us-core.db"))
(define srv (make-ig-server store (ig-package-path "hl7.fhir.us.core")
                            #:capability "us-core-server"))
(load-ig-examples! srv)
(code:comment "(listof gap): what the IG asks for that is not served")
(ig-server-gaps srv)
(define stop (serve-app (ig-server-app srv) #:port 8080))
]

@bold{A server you declare: @hash-lang[] @tt{fhir/capability}.} Three forms among plain Racket
definitions; the lang derives the CapabilityStatement and the OperationDefinitions, so
@tt{/metadata} cannot drift from the code.

@verbatim|{#lang fhir/capability
(server #:mode "server" #:status "active" #:url "http://localhost/fhir")

(resource Patient
  #:interactions (read create update delete search-type)
  #:search-params ([gender token "Patient.gender"] [family string "Patient.name.family"]))

(resource Observation #:interactions (read create search-type)
  #:search-params ([status token "Observation.status"]))

(operation $ping #:system #:in ([message string 0 1]) #:out ([result string 1 1])
  #:handler ping-handler)

(define (ping-handler in req)
  (define msg (let ([m (hash-ref in "message" '())]) (if (pair? m) (car m) "pong")))
  (Parameters (parameter (ParametersParameter (name "result") (valueString msg)))))}|

@itemlist[
@item{@racket[(server #:mode "server" #:status s #:url u #:fhir-version v #:date d #:format f)], once; every keyword optional.}
@item{@racket[(resource Type #:interactions (read create search-type) #:search-params ([name type "FHIRPath"] ...) #:repository r #:profile url)].
Interactions and parameter types are checked against FHIR's code sets as the module compiles. Without
@tt{#:repository} the resource gets an in-memory one implementing exactly the declared interactions,
with search by each parameter's FHIRPath; @racket[make-repository] builds one from closures.}
@item{@racket[(operation $code #:system | #:on Type | #:level (system type instance) #:in ([name type min max] ...) #:out (...) #:handler h)]:
the handler is @racket[(lambda (inputs request) node)], @racket[inputs] a hash from parameter name to
its values. @racket[(operation "ValueSet/$expand")] or @racket[(operation $validate)] exposes an
existing @tt{fhir/operation} value under its own OperationDefinition.}]

@tt{racket server-app.rkt} prints @tt{/metadata}; @tt{raco fhir-server serve server-app.rkt 8080}
serves it. The module provides @racket[app], @racket[capability-statement] and
@racket[operation-definitions]; @racket[(dispatch app (search-request 'Patient '((gender . "male"))))]
runs a request in process. Served resources are R6 typed nodes.

@bold{Operations over HTTP.} Any @tt{fhir/operation} values, with a CapabilityStatement derived from
them:

@racketblock[
(require fhir/capability/operations fhir/conformance/operations fhir/terminology/operations)
(define stop (serve-operations (list $validate $expand $validate-code) #:port 8080))
]

@bold{A store.} The SQLite store behind the generated servers is usable on its own: versioned CRUD
with history, type-driven search from an IG's SearchParameters, transaction Bundles.

@racketblock[
(require fhir/store/fhir-sqlite fhir/store/fhir-engine fhir/store/bundle fhir/store/serve
         fhir/store/ig-params)
(define store (open-fhir-store "fhir.db"))
(define catalog (search-params-from-package (spec-package-path "hl7.fhir.r5.core.tgz")))
(fhir-create! store patient #:search-params catalog)
(fhir-search store "Patient" '(("gender" . "male")) #:search-params catalog)
(process-bundle! store transaction-bundle #:search-params catalog)
(serve-app (make-store-app store #:package core-tgz #:types '(Patient Observation) #:audit? #t)
           #:port 8080)
]

@verbatim{
raco fhir-server load store.db data/                 Bundles, resources, .cql files
raco fhir-server evaluate-measure store.db <Measure id|url> --period-start 2021-01-01 \
    --period-end 2021-12-31 [--subject Patient/x]
}

@section{Reference}

@subsection[#:style 'unnumbered]{@hash-lang[] @tt{fhir/capability}}
@defmodulelang[fhir/capability]

The @racket[server], @racket[resource] and @racket[operation] forms, as above; provides
@racket[app], @racket[capability-statement] and @racket[operation-definitions]. Everything from
@racket[fhir/capability/runtime], @racket[fhir/capability/derive] and @racket[fhir/r6/types] is in
scope.

@subsection[#:style 'unnumbered]{@tt{fhir/capability/runtime}}
@defmodule[fhir/capability/runtime]

The in-process app: structs of closures, a request as plain data, and @racket[dispatch].

@defstruct*[app ([capability-statement fhir?] [operation-definitions list?] [repositories hash?] [operations hash?] [transaction (or/c procedure? #f)])]
@defstruct*[repository ([read any/c] [vread any/c] [create any/c] [update any/c] [delete any/c] [search any/c] [history any/c] [patch any/c])]{
A closure per interaction, or @racket[#f]: @tt{read (id)}, @tt{vread (id vid)}, @tt{create (node)},
@tt{update (id node)}, @tt{delete (id)}, @tt{search (params)} answering nodes or a
@racket[search-result], @tt{history (id-or-#f params)}, and @tt{patch} as a read and update pair.}
@defproc[(make-repository [#:read read any/c #f] [#:vread vread any/c #f] [#:create create any/c #f] [#:update update any/c #f]
                          [#:delete delete any/c #f] [#:search search any/c #f] [#:history history any/c #f] [#:patch patch any/c #f]) repository?]
@defproc[(make-default-repository [type symbol?] [interactions (listof symbol?)] [search-params (listof list?)]) repository?]{
In memory, implementing the interactions given, with search by each parameter's FHIRPath.}
@defproc[(build-app [#:capability cs fhir?] [#:operation-definitions ods (listof fhir?)]
                    [#:repositories repos (listof (cons/c symbol? repository?))] [#:operations ops (listof operation-entry?)]
                    [#:transaction transaction (or/c #f (-> hash? hash?)) #f]) app?]
@defstruct*[request ([kind symbol?] [type any/c] [id any/c] [vid any/c] [params list?] [level any/c] [code any/c] [body any/c])]
@deftogether[(
@defproc[(read-request [type symbol?] [id string?]) request?]
@defproc[(vread-request [type symbol?] [id string?] [vid string?]) request?]
@defproc[(create-request [type symbol?] [node fhir?]) request?]
@defproc[(update-request [type symbol?] [id string?] [node fhir?]) request?]
@defproc[(delete-request [type symbol?] [id string?]) request?]
@defproc[(patch-request [type symbol?] [id string?] [patch list?]) request?]
@defproc[(history-request [type symbol?] [id (or/c string? #f)] [params (listof (cons/c symbol? string?)) '()]) request?]
@defproc[(search-request [type symbol?] [params (listof (cons/c symbol? string?)) '()]) request?]
@defproc[(invoke-request [#:code code string?] [#:level level (or/c 'system 'type 'instance) 'type] [#:type type (or/c symbol? #f) #f]
                         [#:id id (or/c string? #f) #f] [#:body body (or/c fhir? #f) #f]) request?])]
@defproc[(dispatch [a app?] [r request?]) fhir?]{
Routes an interaction or operation over the typed nodes. An undeclared one, invalid operation inputs
(checked against the derived OperationDefinition), or a raised exception is an OperationOutcome.}
@defstruct*[search-result ([matches list?] [includes list?])]
@defstruct*[operation-entry ([level symbol?] [code string?] [target any/c] [proc procedure?])]
@defstruct*[operation-handler ([proc procedure?] [op-def any/c] [level any/c] [target any/c])]
@defparam[current-app a (or/c app? #f)]{The app dispatching the current request.}
@deftogether[(
@defproc[(operation-outcome [severity string?] [code string?] [diagnostics string?]) fhir?]
@defproc[(operation-outcome-not-supported [msg string?]) fhir?]
@defproc[(operation-outcome-invalid [msg string?]) fhir?]
@defproc[(operation-outcome-exception [msg string?]) fhir?]
@defproc[(parameters->hash [p (or/c fhir? #f)]) hash?])]

@subsection[#:style 'unnumbered]{@tt{fhir/capability/derive}}
@defmodule[fhir/capability/derive]

@deftogether[(
@defproc[(derive-capability-statement [server rc-server?] [resources (listof rc-resource?)] [operations (listof rc-operation?)]) any/c]
@defproc[(derive-operation-definition [op rc-operation?]) any/c]
@defproc[(op-code->canonical [code string?]) string?])]{
The CapabilityStatement and OperationDefinition nodes from the declarations; the canonical is the
join key between @tt{rest.resource.operation.definition} and @tt{OperationDefinition.url}.}
@deftogether[(
@defstruct*[rc-server ([mode string?] [status string?] [date string?] [fhir-version string?] [format list?] [url any/c])]
@defstruct*[rc-resource ([type symbol?] [interactions list?] [search-params list?] [profile any/c])]
@defstruct*[rc-operation ([code string?] [display string?] [levels list?] [resource-types list?] [in-params list?] [out-params list?] [canonical any/c])]
@defstruct*[rc-param ([name string?] [type string?] [min exact-nonnegative-integer?] [max any/c] [use string?])])]

@subsection[#:style 'unnumbered]{@tt{fhir/capability/operations}}
@defmodule[fhir/capability/operations]

@tt{fhir/operation} values served over HTTP, with the CapabilityStatement derived from them.

@defproc[(serve-operations [ops (listof operation?)] [#:port port exact-nonnegative-integer? 8080] [#:url url (or/c string? #f) #f]
                           [#:fhir-version version string? "5.0.0"] [#:bearer bearer (or/c string? #f) #f]) procedure?]{
@racket[(serve-operations (list $validate $expand) #:port 8080)]; returns the stop thunk.}
@defproc[(operations-app [ops (listof operation?)] [#:url url (or/c string? #f) #f] [#:fhir-version version string? "5.0.0"]) app?]
@defproc[(operation->entries [op operation?] [#:read read (or/c procedure? #f) #f] [#:around around procedure? (lambda (thunk) (thunk))]) list?]{
Routes at every level and type the definition declares, the request Parameters as inputs, the stored
resource as the instance-level subject (through @racket[current-app], or @racket[read]);
@racket[around] wraps each call to bind the data source and packages.}
@deftogether[(@defproc[(operation->rc [op operation?]) any/c] @defproc[(operation->od [op operation?]) any/c])]

@subsection[#:style 'unnumbered]{@tt{fhir/http/server}}
@defmodule[fhir/http/server]

@defproc[(serve-app [a app?] [#:port port (integer-in 1 65535) 8080] [#:host host (or/c string? #f) #f] [#:bearer bearer (or/c string? #f) #f]) (-> void)]{
Serves the app over HTTP/1.1 (one request per connection, a thread each) and returns a thunk that
stops it. With @racket[bearer], every request but @tt{GET /metadata} needs that token.}

@subsection[#:style 'unnumbered]{@tt{fhir/http/router}}
@defmodule[fhir/http/router]

@defproc[(handle [a app?] [method string?] [path string?] [query (listof (cons/c symbol? string?))] [body string?]) (values exact-integer? (or/c hash? #f))]{
The pure router: @tt{GET /metadata}; @tt{POST /} (transaction or batch); @tt{GET|POST /{Type}};
@tt{GET|PUT|DELETE|PATCH /{Type}/{id}} (PATCH as JSON Patch); @tt{/{Type}/{id}/_history[/{vid}]},
@tt{/{Type}/_history}; @tt{GET|POST /$op}, @tt{/{Type}/$op}, @tt{/{Type}/{id}/$op}. The status comes
from the result: 201 on create, and for an OperationOutcome its first issue code (not-found 404,
invalid 400, processing 422, conflict 409, exception 500).}
@defproc[(handle/raw [a app?] [method string?] [path string?] [query (listof (cons/c symbol? string?))] [body string?]) (values exact-integer? bytes? string?)]{Like @racket[handle], but a Binary result streams as its own content type.}
@defproc[(parse-query [s string?]) (listof (cons/c symbol? string?))]

@subsection[#:style 'unnumbered]{@tt{fhir/store/fhir-sqlite}}
@defmodule[fhir/store/fhir-sqlite]

@defstruct*[fhir-store ([path path-string?] [pool connection-pool?])]
@defproc[(open-fhir-store [path path-string?] [#:max-connections n exact-positive-integer? 8]) fhir-store?]{WAL mode; the schema is created on open.}
@defproc[(close-fhir-store [s fhir-store?]) void?]
@deftogether[(
@defproc[(call-with-store-connection [s fhir-store?] [proc (-> connection? any)]) any]
@defproc[(call-with-store-transaction [s fhir-store?] [proc (-> connection? any)]) any])]{A leased connection; the transaction is the only way to write.}

@subsection[#:style 'unnumbered]{@tt{fhir/store/fhir-engine}}
@defmodule[fhir/store/fhir-engine]

Versioned CRUD and search over the store. Every write stamps @tt{meta.versionId} and
@tt{meta.lastUpdated}, keeps the version in an immutable history, and re-indexes the resource in the
same transaction. Search is type-driven by the catalog: each parameter's SearchParameter type picks
its index (token, reference, string, date, number, quantity, uri) and matching rules, with
prefixes, modifiers, @tt{_id}, @tt{_lastUpdated}, @tt{_count}, and comma as OR; unknown parameters
are ignored and reported by @racket[fhir-search/ignored].

@defstruct*[search-param ([name string?] [kind symbol?] [path string?])]{A parameter: its type and its FHIRPath.}
@defthing[default-search-params (hash/c symbol? (listof search-param?))]{A small catalog for Patient, Observation and Condition; IGs supply the real one (@racket[make-store-app]).}
@deftogether[(
@defproc[(fhir-create! [s fhir-store?] [resource jsexpr?] [#:search-params catalog hash? default-search-params]) (values string? string? exact-positive-integer?)]
@defproc[(fhir-read [s fhir-store?] [type string?] [id string?]) (or/c jsexpr? #f)]
@defproc[(fhir-vread [s fhir-store?] [type string?] [id string?] [version exact-positive-integer?]) (or/c jsexpr? #f)]
@defproc[(fhir-update! [s fhir-store?] [resource jsexpr?] [#:search-params catalog hash? default-search-params]) exact-positive-integer?]
@defproc[(fhir-delete! [s fhir-store?] [type string?] [id string?]) boolean?]
@defproc[(fhir-history [s fhir-store?] [type string?] [id string?] [#:since since (or/c string? #f) #f] [#:count count (or/c exact-nonnegative-integer? #f) #f]) (listof jsexpr?)]
@defproc[(fhir-history-type [s fhir-store?] [type string?] [#:since since (or/c string? #f) #f] [#:count count (or/c exact-nonnegative-integer? #f) #f]) (listof jsexpr?)]
@defproc[(fhir-search [s fhir-store?] [type string?] [params (listof (cons/c string? string?))] [#:search-params catalog hash? default-search-params]) (listof jsexpr?)]
@defproc[(fhir-search/ignored [s fhir-store?] [type string?] [params (listof (cons/c string? string?))] [#:search-params catalog hash? default-search-params]) (values (listof jsexpr?) (listof string?))]
@defproc[(fhir-includes [s fhir-store?] [type string?] [matches (listof jsexpr?)] [params (listof (cons/c string? string?))]) (listof jsexpr?)])]{
Create returns type, id and version. Delete removes the current resource; history remains and
@racket[fhir-vread] still reads it. Includes take @tt{_include} and @tt{_revinclude} values
(@tt{Source:param}, @tt{Source:param:Target}, @tt{Source:*}).}
@deftogether[(
@defproc[(create-in! [c connection?] [resource jsexpr?] [catalog hash?]) (values string? string? exact-positive-integer?)]
@defproc[(update-in! [c connection?] [resource jsexpr?] [catalog hash?]) exact-positive-integer?]
@defproc[(delete-in! [c connection?] [type string?] [id string?]) boolean?])]{The writes on a leased connection, to compose several in one transaction.}

@subsection[#:style 'unnumbered]{@tt{fhir/store/bundle}}
@defmodule[fhir/store/bundle]

@defproc[(process-bundle! [s fhir-store?] [bundle jsexpr?] [#:search-params catalog hash? default-search-params]) jsexpr?]{
A transaction or batch Bundle: @tt{urn:uuid} references rewritten to @tt{Type/id} first, entries
applied in spec order (deletes, creates, updates), a transaction in one store transaction that rolls
back whole on any failure, a batch entry by entry with error entries; the response Bundle mirrors
the request order.}
@defproc[(load-bundle! [s fhir-store?] [bundle jsexpr?] [#:search-params catalog hash? default-search-params]) (values exact-nonnegative-integer? jsexpr?)]{Prepopulation; also accepts a @tt{collection} Bundle as a batch of creates.}

@subsection[#:style 'unnumbered]{@tt{fhir/store/load}}
@defmodule[fhir/store/load]

@defproc[(load-files! [s fhir-store?] [path path-string?] [#:search-params catalog hash? default-search-params] [#:library-base base string? "http://localhost/fhir"]) (listof (cons/c string? exact-nonnegative-integer?))]{
A file, or every @tt{.json} and @tt{.cql} under a directory: Bundles, resources (upserted by id),
and CQL files as Library resources. The count loaded per file.}
@defproc[(cql->library [cql string?] [#:library-base base string? "http://localhost/fhir"]) hash?]{A logic Library carrying the CQL as base64 @tt{text/cql}, named from its header.}

@subsection[#:style 'unnumbered]{@tt{fhir/store/serve}}
@defmodule[fhir/store/serve]

@defproc[(make-store-app [s fhir-store?] [#:package package (or/c path-string? (listof path-string?))] [#:types types (listof symbol?)]
                         [#:url url (or/c string? #f) #f] [#:extra-params extra hash? (hash)] [#:fhir-version version string? "5.0.0"] [#:audit? audit? boolean? #f]) app?]{
The servable app over a store: read, vread, create, update, delete and search per type, a
transaction handler, the search catalog from the package's SearchParameters (the advertised
parameters are the indexed ones), the CapabilityStatement derived from it. With @racket[audit?],
every committed write records an AuditEvent, and creates and updates a Provenance, into the same
store.}
@defproc[(store-repository [s fhir-store?] [type symbol?] [catalog hash?]) any/c]{One type's repository.}

@subsection[#:style 'unnumbered]{@tt{fhir/store/data-source}}
@defmodule[fhir/store/data-source]

@defproc[(store->data-source [s fhir-store?] [#:search-params catalog hash? default-search-params]) data-source?]{The store as a @tt{fhir/data-source}, with real search, for operations.}

@subsection[#:style 'unnumbered]{@tt{fhir/store/measure}}
@defmodule[fhir/store/measure]

@defproc[(evaluate-measure [s fhir-store?] [measure hash?] [period-start string?] [period-end string?]
                           [#:subject subject (or/c string? #f) #f] [#:search-params catalog hash? default-search-params]
                           [#:valuesets valuesets procedure? (lambda (url) #f)] [#:offset offset (or/c exact-integer? #f) #f]) hash?]{
@tt{cql/measure}'s evaluation over the store: the Measure's Library by url or name, its includes,
value sets from the store then the packages, each patient's data through its patient search
parameter. An individual MeasureReport with a subject, a summary with the proportion score without.}

@subsection[#:style 'unnumbered]{@tt{fhir/store/ig-server}}
@defmodule[fhir/store/ig-server]

@defproc[(make-ig-server [s fhir-store?] [package path-string?]
                         [#:validate? validate? boolean? #t] [#:url url (or/c string? #f) #f]
                         [#:capability capability (or/c string? #f) #f] [#:offset offset (or/c exact-integer? #f) 0]) ig-server?]{
The whole server from the IG package. @tt{fhirVersions} picks the tower and core package;
dependencies resolve transitively from @racket[current-package-directories] and @tt{fhir-spec}; the
IG's server CapabilityStatement (@racket[capability] chooses one by id or url when it ships several)
gives the types, interactions, search parameters, includes, supported profiles and operations; the
catalog is core overlaid by the IG; every write is validated against its base type and claimed
profiles (422 on error); registered operations the IG declares are served with the store as data
source; @tt{/metadata} is the IG's own statement trimmed to what runs, and everything trimmed is a
@racket[gap].}
@defstruct*[ig-server ([plan ig-plan?] [app app?] [gaps (listof gap?)] [catalog hash?] [sd-packages list?] [store fhir-store?] [validate? boolean?] [tgz path?])]{
@racket[ig-server-app] is what @racket[serve-app] serves.}
@defstruct*[gap ([type any/c] [what any/c] [name any/c] [expectation any/c] [reason any/c])]{One requirement the server does not meet, with its SHALL, SHOULD or MAY.}
@defproc[(gap->list [g gap?]) list?]
@defproc[(plan-ig-server [package path-string?] [capability (or/c string? #f) #f]) ig-plan?]{The reading of the IG's statement, without a store.}
@deftogether[(
@defstruct*[ig-plan ([name string?] [version string?] [fhir-version string?] [tower any/c] [core-tgz any/c] [ig-cs any/c] [resources list?])]
@defstruct*[ig-resource ([type any/c] [interactions list?] [search-params list?] [profiles list?])])]
@defproc[(ig-server-put! [srv ig-server?] [resource hash?]) (or/c 'ok any/c)]{Validate and upsert by id (ids and references preserved); the OperationOutcome when invalid.}
@defproc[(load-ig-examples! [srv ig-server?]) (values exact-nonnegative-integer? (listof (cons/c string? string?)))]{Every example in the package, and the IG's ValueSets and CodeSystems; the ones rejected, with the reason.}
@deftogether[(@defproc[(ig-package-path [ref string?]) path?] @defproc[(package-manifest [package path-string?]) (or/c hash? #f)])]{A package by name in @tt{fhir-spec}, file name or path; its @tt{package.json}.}

