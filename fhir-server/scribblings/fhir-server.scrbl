#lang scribble/manual
@; Text in @tt is shown exactly as written: no curly quotes, and "--" stays two hyphens.
@(require (only-in scribble/core [element literal-element]))
@(define (tt . text) (literal-element (quote tt) text))
@(require (for-label racket/base racket/contract
                     fhir/capability/runtime fhir/capability/derive fhir/capability/operations
                     fhir/capability/store
                     fhir/http/server fhir/http/router fhir/store/fhir-sqlite fhir/store/fhir-engine
                     fhir/store/serve fhir/store/ig-server fhir/store/bundle fhir/store/load fhir/store/measure
                     fhir/store/data-source))

@title{fhir-server: FHIR servers}

Health data is exchanged as @hyperlink["https://hl7.org/fhir/"]{FHIR} @italic{resources}: a patient,
a lab result, a prescription, each a small JSON document. A @italic{FHIR server} is where such
resources are kept and reached over the web. It does four things. It @bold{stores} a resource you
send it, and keeps every earlier version. It lets you @bold{read} one back by its address. It lets
you @bold{search}: all the lab results of this patient, every patient born before 1980. And it
@bold{checks what is written}, refusing a resource that breaks FHIR's rules.

Every FHIR server also publishes a description of itself, called its @italic{CapabilityStatement}:
which kinds of resource it holds, what can be done with each, which searches it answers. Other
software reads that description to learn how to talk to it. In this package the description is
never written by hand. It is worked out from what the server really does, so the two cannot
disagree.

This package makes FHIR servers in two ways. One command builds a whole server from a published
Implementation Guide, with nothing to write. Or you declare a server of your own in a short file:
which resources, which searches, your own operations. Both keep their data in a single SQLite file.
The command is @tt{raco fhir-server}.

These servers are for developing and testing against a specification. They are not built to face
the internet: see @secref["limits"].

Part of the @hyperlink["https://oloveluck.github.io/fhir/"]{fhir} family of FHIR languages and tools.

@table-of-contents[]

@section{What you can do with it}

@itemlist[
@item{@bold{Start a small server of your own} and call it: @secref["first"].}
@item{@bold{Run a server that follows a published guide} such as US Core, loaded with the guide's
examples: @secref["serve-ig"].}
@item{@bold{Declare exactly what your server offers}: resources, searches, and calculations of your
own as operations (@secref["declare"]).}
@item{@bold{Decide what happens to a search the server cannot apply}: @secref["search"].}
@item{@bold{Fill the store from files and query it with SQL}: @secref["store"].}
@item{@bold{Compute a quality measure} over the stored patients: @secref["measures"].}
@item{@bold{Use any of it from a program}: @secref["racket"].}]

@section[#:tag "first"]{A first example}

The smallest useful server: it keeps patients and observations, searches them, validates what is
written, and offers one operation of its own.

@bold{1. Install} the tools as the @hyperlink["https://oloveluck.github.io/fhir/"]{family's front
page} describes. The command is then @tt{raco fhir-server} (or @tt{fhir-server}, if you built the
standalone tools). It needs the system's SQLite library.

@bold{2. Write the server}, as @tt{study.capability.rkt}:

@verbatim|{#lang fhir/capability
(require (only-in fhir/conformance/operations $validate))
(server #:store "study.db" #:search-handling "strict"
        #:references "checked")
(resource Patient #:interactions (read create search-type) #:search-params ([gender token] [birthdate date]))
(resource Observation #:interactions (read create search-type) #:search-params ([patient reference] [code token]))
(define (double-handler in req)
  (Parameters (parameter (ParametersParameter (name "doubled") (valueDecimal (* 2 (car (hash-ref in "x"))))))))
(operation $double #:system #:in ([x decimal 1 1]) #:out ([doubled decimal 1 1]) #:handler double-handler)
(operation $validate)}|

Reading it from the top:

@itemlist[
@item{@tt{#lang fhir/capability} says the file is a server declaration.}
@item{@tt{(server …)} sets things for the whole server. The data goes in @tt{study.db}, beside the
file. The other two settings make it careful, as a server of patient data should be: it refuses a
search it cannot apply in full (@secref["search"]), and refuses an observation about a patient it
does not hold.}
@item{Each @tt{(resource …)} names a kind of resource the server holds, what may be done with it
(@italic{interactions}: read one, create one, search), and what it can be searched by.}
@item{@tt{(operation $double …)} is an @italic{operation}: a named service beyond storing and
searching, here one that doubles a number. Its inputs and outputs are declared with their types;
@tt{double-handler} is the code that does the work. It is a toy; a real one would compute a score
or a dose.}
@item{@tt{(operation $validate)} offers FHIR's standard validation operation, which the
@tt{require} line brought in.}]

You can also print this starting file instead of typing it:
@tt{raco fhir guide capability --block smallest > study.capability.rkt}.

@bold{3. Check it.} This compiles the declarations and says what the server will offer:

@verbatim{
$ raco fhir-server check study.capability.rkt
ok  study.capability.rkt  (FHIR 6.0.0-ballot4)
  Patient: read, create, search-type; search by gender, birthdate
    $validate
  Observation: read, create, search-type; search by patient, code
    $validate
  $double (system)
(what an operation answers is checked when it runs: serve it and call each once)
}

@bold{4. Start it.} @litchar{--port 0} takes any free port:

@verbatim{
$ raco fhir-server serve study.capability.rkt --port 0
FHIR server on http://localhost:43493  (Ctrl-C, or kill 9711, to stop)
search: strict (a parameter the app does not declare is refused, 400)
store: …/study.db (created on the first request)
}

The first line is the one to read: it gives the address the server answers at, with the port it
took, and the number to stop it by. The server keeps running; use another terminal for the next
steps, with the address your own server printed.

@bold{5. Ask what it supports.} Every FHIR server answers at @tt{/metadata} with its
CapabilityStatement. This one was derived from the file:

@verbatim|{$ curl http://localhost:43493/metadata
{"resourceType":"CapabilityStatement","status":"active", … "fhirVersion":"6.0.0-ballot4", …
 "rest":[{"mode":"server","resource":[
   {"type":"Patient","interaction":[{"code":"read"},{"code":"create"},{"code":"search-type"}],
    "searchParam":[{"name":"gender","type":"token"},{"name":"birthdate","type":"date"}],
    "operation":[{"name":"$validate", …}]}, …}|

@bold{6. Store a patient.} Send the resource with POST to the address of its type:

@verbatim|{$ curl -i -X POST http://localhost:43493/Patient -H 'Content-Type: application/fhir+json' \
    -d '{"resourceType":"Patient","gender":"female","birthDate":"1974-12-25","name":[{"family":"Lee","given":["Ann"]}]}'
HTTP/1.1 201 Created
Content-Type: application/fhir+json; charset=utf-8
Location: http://localhost:43493/Patient/758d3b7eabba0b5caa0f666c6f64eaa0/_history/1
…
{"resourceType":"Patient","id":"758d3b7eabba0b5caa0f666c6f64eaa0","meta":{"versionId":"1","lastUpdated":"2026-11-13T14:28:02Z"},"name":[{"family":"Lee","given":["Ann"]}],"gender":"female","birthDate":"1974-12-25"}}|

@tt{201 Created} means it was stored. The server gave the patient an @tt{id} and a version number,
and @tt{Location} is the address of exactly this version.

@bold{7. Read it back, and search.} A resource's address is its type and id. A search is the type,
a question mark, and what to match:

@verbatim|{$ curl http://localhost:43493/Patient/758d3b7eabba0b5caa0f666c6f64eaa0
{"resourceType":"Patient","id":"758d3b7eabba0b5caa0f666c6f64eaa0", … "gender":"female","birthDate":"1974-12-25"}

$ curl 'http://localhost:43493/Patient?gender=female'
{"resourceType":"Bundle","type":"searchset","total":1, … "entry":[{"fullUrl":"http://localhost:43493/Patient/758d3b7eabba0b5caa0f666c6f64eaa0","resource":{"resourceType":"Patient", …},"search":{"mode":"match"}}]}}|

A search answers with a @italic{Bundle}, FHIR's envelope for a list of resources. @tt{total} is how
many matched; each @tt{entry} is one of them. @tt{Patient?birthdate=lt1980} finds the same patient:
@tt{lt} means "before".

@bold{8. Send something wrong.} A French gender and a thirtieth of February:

@verbatim|{$ curl -X POST http://localhost:43493/Patient -H 'Content-Type: application/fhir+json' \
    -d '{"resourceType":"Patient","gender":"femme","birthDate":"1974-02-30"}'
{"resourceType":"OperationOutcome","issue":[
 {"severity":"error","code":"processing","diagnostics":"Patient does not conform to its base type: nothing was written"},
 {"severity":"error","code":"code-invalid","diagnostics":"code `femme` not in required value set http://hl7.org/fhir/ValueSet/administrative-gender; it holds female, male, other, unknown","expression":["Patient.gender"]},
 {"severity":"error","code":"invalid","diagnostics":"'1974-02-30' is not a valid date (February 1974 has 28 days)","expression":["Patient.birthDate"]}]}}|

The status is 422 and the answer is an @italic{OperationOutcome}, FHIR's report of problems: one
entry per problem, with the place. Nothing was stored.

@bold{9. Call the operation.} An operation's address starts with a dollar sign (quote it, or the
shell will read it as a variable):

@verbatim|{$ curl 'http://localhost:43493/$double?x=2.5'
{"resourceType":"Parameters","parameter":[{"name":"doubled","valueDecimal":5.0}]}}|

@bold{10. Stop it}, by the number in its first line: @tt{kill 9711}, or Ctrl-C in its own terminal.
The data stays in @tt{study.db}; start the server again and the patient is still there.

@bold{A mistake in the file} is reported by @tt{check}, at its line, before anything is served.
Write @tt{search} for @tt{search-type} and @tt{birthDate} for @tt{birthdate}:

@verbatim{
$ raco fhir-server check study.capability.rkt
study.capability.rkt:6:50: resource: unknown restful interaction search (did you mean `search-type`?); a resource takes read, vread, update, patch, delete, history-instance, history-type, create, search-type
study.capability.rkt:5:0: resource Patient: search parameter `birthDate`: FHIR defines none of that name for Patient (did you mean `birthdate`?); give its FHIRPath: [birthDate date "…"]
}

@section[#:tag "metadata"]{What a server says about itself}

The CapabilityStatement is how a client finds out, without trying, what a server can do. It lists
each resource type with its interactions, the names and kinds of its search parameters, and its
operations. A client that wants to search observations by date looks there first.

A hand-written statement goes stale: someone adds a search, or removes one, and forgets the
description. Here that cannot happen, in either kind of server.

@itemlist[
@item{For a server you declare, the statement is derived from the declarations, and the server does
what the declarations say: an interaction that is not declared is refused (405), and a search uses
exactly the declared parameters.}
@item{For a server generated from a guide, the statement starts as the guide's own and is trimmed
to what this server executes. What was trimmed is not hidden: it is listed for you as a
@italic{gap} (@secref["serve-ig"]).}]

Each operation has a description of its own as well, an @italic{OperationDefinition}: its inputs
and outputs with their types. These are derived too, and served at @tt{/OperationDefinition} (all
of them) and @tt{/OperationDefinition/double} (one).

@section[#:tag "serve-ig"]{A server from an Implementation Guide}

An @italic{Implementation Guide} (IG) is a published agreement on how to use FHIR for one purpose:
US Core for health records in the United States, the International Patient Summary, mCODE for
cancer data. It contains @italic{profiles} (stricter rules for particular resources), the search
parameters and operations a conforming server must offer, a CapabilityStatement saying so, and
example resources. It is distributed as a @italic{package}, one @tt{.tgz} file.

That is a complete specification of a server, and @tt{serve-ig} builds the server from it:

@verbatim{
$ raco fhir-server serve-ig hl7.fhir.us.core --port 8080
loaded 255 example(s); 0 rejected by validation
0 IG requirement(s) not met (raco fhir-server serve-ig hl7.fhir.us.core --gaps); 0 of them SHALL
FHIR server for hl7.fhir.us.core on http://localhost:8080  (store: /var/tmp/fhir-ig-17945801221794580122105.db; Ctrl-C, or kill 3282, to stop)
}

It takes about fifteen seconds to start. Everything came from the package:

@itemlist[
@item{@bold{The FHIR version.} US Core is written for FHIR R4, so this is an R4 server.}
@item{@bold{What it serves.} The guide's CapabilityStatement names 31 resource types, with the
interactions and search parameters for each. @tt{/metadata} answers that statement.}
@item{@bold{How search works.} Each search parameter is defined in the guide or in FHIR itself by a
formula saying where in a resource its value is found; the server indexes resources by those
formulas.}
@item{@bold{What it accepts.} Every resource written is validated against FHIR's rules for its type
and against the profiles it claims.}
@item{@bold{What is in it.} The guide's own examples are loaded first, each through the same
validation; a guide's examples are a ready set of test data.}]

Try it. The examples include two patients named Shaw, and an encounter can bring its patient along
(@tt{_include}):

@verbatim|{$ curl 'http://localhost:8080/Patient?family=Shaw'
{"resourceType":"Bundle","type":"searchset","total":2, … }      (Patient/deceased-example, Patient/example)

$ curl 'http://localhost:8080/Encounter?patient=Patient/example&_include=Encounter:patient'
{"resourceType":"Bundle","type":"searchset","total":3, … }      (three Encounters, and Patient/example marked "include")}|

A patient that claims the US Core profile and lacks the identifier it requires is refused, with
status 422:

@verbatim|{$ curl -X POST http://localhost:8080/Patient -H 'Content-Type: application/fhir+json' -d '
{"resourceType":"Patient","meta":{"profile":["http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"]},
 "gender":"female","name":[{"family":"Lee","given":["Ann"]}]}'
{"resourceType":"OperationOutcome","issue":[{"severity":"error","code":"processing","diagnostics":"Patient does not conform to http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"},{"severity":"error","code":"required","diagnostics":"minimum required = 1, but found 0","expression":["Patient.identifier"]}]}}|

Note what "claims" means: the resource lists the profile in its @tt{meta.profile}. The same patient
without that line is a valid plain Patient and is stored. The server holds a resource to the
profiles it says it follows, not to every profile the guide has for its type.

@subsection{Gaps: what the guide asks for that is not served}

A guide may require something this server does not do. Rather than advertise it anyway, the server
leaves it out of @tt{/metadata} and reports it. @litchar{--gaps} prints the list and stops. US Core
has none, and the command says so; the International Patient Summary has one:

@verbatim{
$ raco fhir-server serve-ig hl7.fhir.us.core --gaps
hl7.fhir.us.core: no unmet requirement (every SHALL, SHOULD and MAY of its CapabilityStatement is served)
$ raco fhir-server serve-ig hl7.fhir.uv.ips --gaps
Patient	operation	summary	SHOULD	operation not implemented
}

Each line is the resource type, the kind of thing (an interaction, a search parameter, an include,
an operation), its name, how strongly the guide asks for it (SHALL, SHOULD or MAY), and why it is
not served. The start-up line counts them, and how many are SHALL.

@subsection{Which guide, and the options}

The guide is named by a package that comes with the tools (@tt{hl7.fhir.us.core}, with or without
@tt{.tgz}) or by the path of a @tt{.tgz} you downloaded from
@hyperlink["https://packages.fhir.org"]{packages.fhir.org}. Those that come with the tools and
describe a server are US Core (@tt{hl7.fhir.us.core} is 9.0.0; @tt{hl7.fhir.us.core-8.0.0} and
@tt{hl7.fhir.us.core-6.1.0}), the International Patient Summary (@tt{hl7.fhir.uv.ips}), mCODE
(@tt{hl7.fhir.us.mcode-4.0.0}), CQF Measures (@tt{hl7.fhir.us.cqfmeasures-5.0.0}) and CRMI
(@tt{hl7.fhir.uv.crmi-2.0.0}). A guide's dependencies on other packages are found the same way. A
package with no server CapabilityStatement cannot be served, and the command says so.

A guide you wrote yourself in FHIR Shorthand works too: @tt{raco fsh <dir> --pack} writes the
package (see @hyperlink["https://oloveluck.github.io/fsh/"]{fsh}), and @tt{serve-ig} serves it.

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{option} @bold{what it does})
      (list @tt{--port n} "the port to listen on (8080 when absent)")
      (list @tt{--db store.db} "keep the data in this file between runs; without it, a temporary file whose name the start-up line gives")
      (list @tt{--capability <id>} "which of the guide's server CapabilityStatements to follow, when it has several (CQF Measures has four)")
      (list @tt{--load <file|dir>} @elem{also load these: FHIR JSON resources, Bundles, and @tt{.cql} files (stored as Library resources); repeatable})
      (list @tt{--no-examples} "do not load the guide's examples")
      (list @tt{--no-validate} "store what is written without validating it")
      (list @tt{--bearer <token>} @elem{require @tt{Authorization: Bearer <token>} on every request but @tt{GET /metadata}})
      (list @tt{--tz-offset ±hh:mm} @elem{the timezone measures are evaluated in (@secref["measures"]); UTC when absent})
      (list @tt{--gaps} "print the unmet requirements and stop"))]

@section[#:tag "declare"]{A server you declare}

When no guide describes the server you want, you write its declaration, as in @secref["first"]. The
file is a list of three kinds of form, in any order, among ordinary Racket definitions for the code
of your operations. This section says what each form can express. The repository's
@tt{fhir-server/capability/guide.md} goes further, with complete worked operations (an eGFR
calculator with typed, bounded inputs; an output with a unit); @tt{raco fhir guide capability}
prints it.

A declared server speaks FHIR R6, the version now being finalised. For the common resources
(Patient, most of Observation) the JSON is the same as in R4.

@subsection{@tt{server}: the whole server}

One @tt{(server …)} form, every setting optional and each value a text in quotes:

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{setting} @bold{meaning})
      (list @tt{#:store "fhir.db"} "the SQLite file the data is kept in, beside the declaration; without it, a temporary file removed when the server stops")
      (list @tt{#:search-handling "strict"} @elem{refuse a search with a parameter the server cannot apply (default @tt{"lenient"}; @secref["search"])})
      (list @tt{#:references "checked"} @elem{refuse a resource that refers to another the server should hold and does not (default @tt{"unchecked"})})
      (list @tt{#:warnings "refuse"} @elem{refuse a resource whose validation gives warnings, not only errors (default @tt{"accept"})})
      (list @elem{@tt{#:url}, @tt{#:name}, @tt{#:description}, @tt{#:status}, @tt{#:date}} "what the CapabilityStatement says of the server: its address, name and so on")
      (list @elem{@tt{#:mode}, @tt{#:format}} @elem{the statement's @tt{mode} (@tt{"server"} unless you say @tt{"client"}) and formats (JSON); leave them out}))]

@subsection{@tt{resource}: what is stored}

@verbatim|{(resource Patient
  #:interactions (read create update delete search-type history-instance)
  #:search-params ([gender token] [birthdate date] [family string "name.family"]))}|

@bold{Interactions} are FHIR's names for what can be done with a resource:

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{interaction} @bold{request} @bold{meaning})
      (list @tt{read} @tt{GET /Patient/ann} "the current version of one resource")
      (list @tt{vread} @tt{GET /Patient/ann/_history/2} "one earlier version")
      (list @tt{create} @tt{POST /Patient} "store a new resource; the server chooses its id")
      (list @tt{update} @tt{PUT /Patient/ann} "replace a resource, or create it with the id you chose")
      (list @tt{patch} @tt{PATCH /Patient/ann} "change part of a resource (a JSON Patch document)")
      (list @tt{delete} @tt{DELETE /Patient/ann} "remove it; its earlier versions stay readable")
      (list @tt{search-type} @tt{GET /Patient?gender=female} "search")
      (list @tt{history-instance} @tt{GET /Patient/ann/_history} "every version of one resource")
      (list @tt{history-type} @tt{GET /Patient/_history} "every version of every resource of the type"))]

An interaction you did not declare is refused with status 405, and a resource type you did not
declare with 404.

@bold{Search parameters} are what a resource can be found by. FHIR defines a standard set for each
type, with names such as @tt{gender}, @tt{birthdate}, @tt{family}, @tt{identifier} for a Patient
and @tt{patient}, @tt{subject}, @tt{code}, @tt{value-quantity} for an Observation. @tt{[gender token]} asks for FHIR's own
parameter of that name; the second word is its kind, which decides how values are compared:

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{kind} @bold{matches} @bold{example})
      (list @tt{token} "a code, optionally with its system" @tt{code=http://loinc.org|4548-4})
      (list @tt{string} "the start of a text, ignoring case and accents" @tt{family=lee})
      (list @tt{date} @elem{a date or a range (@tt{lt}, @tt{gt}, @tt{le}, @tt{ge} … before the value)} @tt{birthdate=lt1980})
      (list @tt{reference} "a link to another resource" @tt{patient=Patient/ann})
      (list @tt{number} "a number, with the same prefixes" "")
      (list @tt{quantity} "a number with a unit" @tt{value-quantity=gt9})
      (list @tt{uri} "an address, exactly" ""))]

A name FHIR does not define for that type, or the wrong kind for it, is an error when you
@tt{check} the file, with the nearest real name. For a search of your own invention, add the place
in the resource to look, as a FHIRPath expression: @tt{[family string "name.family"]}.

Every type also answers @tt{_id}, @tt{_lastUpdated}, @tt{_count} (how many to return),
@tt{_offset} and @tt{_sort}. A reference search can pull the referenced resources into the same
answer with @tt{_include} (and the resources that refer to the matches with @tt{_revinclude}).
A code can be searched by what it is called: @tt{Observation?code:text=hemoglobin} finds the
observations whose code's display, or whose concept's text, holds the word, in any case. (FHIR asks
@tt{:text} for text that begins with the words; here they may stand anywhere in it.)

@subsection{@tt{operation}: a service of your own}

@verbatim|{(operation $bmi #:system
  #:in ([weight decimal 1 1] [height decimal 1 1])
  #:out ([bmi decimal 1 1])
  #:handler bmi-handler)

(define (bmi-handler in req)
  (define (input k) (car (hash-ref in k)))
  (define m (/ (input "height") 100))
  (define bmi (/ (input "weight") (* m m)))
  (Parameters (parameter (ParametersParameter (name "bmi") (valueDecimal (/ (round (* bmi 10)) 10.0))))))}|

@itemlist[
@item{@bold{Where it is called.} @tt{#:system} puts it at the top (@tt{/$bmi}); @tt{#:on Patient}
at a type (@tt{/Patient/$bmi}).}
@item{@bold{Inputs and outputs} are @tt{[name type min max]}: the type is a FHIR type
(@tt{integer}, @tt{decimal}, @tt{boolean}, @tt{string}, @tt{code}, @tt{date}, @tt{Quantity},
@tt{Patient} …), and @tt{min max} say how many: @tt{1 1} required, @tt{0 1} optional, @tt{0 *} a
list. An input may add @tt{#:min}/@tt{#:max} (a number's allowed range), @tt{#:binding} (the value
set a code must come from) and @tt{#:documentation} (what it means, with its unit).}
@item{@bold{The handler} is a function of the inputs and the request. @tt{in} maps each input's
name to the list of its values, already converted to the declared type: a @tt{decimal} arrives as a
number. It answers a resource, usually a @tt{Parameters} holding the outputs.}
@item{@bold{Checking is done for you.} A request with a missing, misspelt, mistyped or out-of-range
input is refused with status 400 and one issue per problem, before your handler runs. What the
handler answers is held to @tt{#:out} in the same way, so the OperationDefinition always tells the
truth about the operation.}
@item{@bold{How it is called.} With the inputs in the address (@tt{GET /$bmi?weight=80&height=180})
or as a Parameters resource in a POST.}]

An operation that already exists in the family is offered by naming it, with no handler:
@tt{(operation $validate)} after requiring it, or by reference, @tt{(operation "ValueSet/$expand")}.
That covers validation, the terminology operations
(@hyperlink["../fhir-tx/index.html"]{fhir-tx}), @tt{StructureMap/$transform}
(@hyperlink["https://oloveluck.github.io/fml/"]{fml}) and @tt{Measure/$evaluate-measure}
(@hyperlink["https://oloveluck.github.io/cql/"]{cql}); each needs a @tt{require} of the module that
implements it.

@subsection{Checking and serving}

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @tt{raco fhir-server check app.rkt} "compile the declarations; one line per resource and operation, or every mistake at its line (exit code 1)")
      (list @tt{raco fhir-server serve app.rkt} "serve it on port 8080")
      (list @tt{raco fhir-server serve app.rkt --port 0} "on a free port, printed in the first line")
      (list @tt{raco fhir-server serve app.rkt --store fhir.db} @elem{keep the data in this file, whatever the declaration's @tt{#:store} says})
      (list @tt{raco fhir-server serve app.rkt --log} "print a line per request")
      (list @tt{racket app.rkt} "print the CapabilityStatement, without serving"))]

The first line the server prints is its ready signal, and a script should wait for it. It names
the address and the process number; stop the server with @tt{kill} and that number (Ctrl-C when it
runs in your terminal). A port already in use is one line saying so. After you edit the file, stop
the server and start it again; the store keeps the data.

@section[#:tag "search"]{Strict and lenient search}

Suppose a client searches @tt{Patient?name=Lee} on the first example's server, which can search
patients by gender and birth date only. FHIR allows two answers, and the choice matters more than
it looks. A @bold{lenient} server ignores the part it cannot apply and answers the rest. With
nothing left to filter by, that is @italic{every patient}; the Bundle carries a note saying
@tt{name} was ignored, which a careless client never reads. A @bold{strict} server refuses, with
status 400, and lists what it can search by:

@verbatim|{$ curl 'http://localhost:43493/Patient?name=Lee'
{"resourceType":"OperationOutcome","issue":[{"severity":"error","code":"invalid","diagnostics":"search parameter `name` not supported here (strict search handling); this server searches with what /metadata advertises (Patient: gender, birthdate; every type: _id, _lastUpdated, _count, _offset, _sort)"}]}}|

Lenient is FHIR's default and the default here; it suits a public reference server. For patient
data, where a misspelt filter must never turn into "everyone's records", declare
@tt{(server #:search-handling "strict")}. A client can also ask one lenient server to be strict for
one request, with the header @tt{Prefer: handling=strict}. The line @tt{search:} that @tt{serve}
prints at start-up says which the server is. A server generated from a guide is lenient.

@section[#:tag "writes"]{What happens on a write}

A create or update goes through the same steps in both kinds of server.

@itemlist[
@item{@bold{It is validated as sent.} The resource is checked by the family's validator
(@hyperlink["../fhir-validation/index.html"]{fhir-validation}) against FHIR's rules for its type
and the profiles it claims. An error refuses it with status 422 and every issue; nothing is stored.
A warning does not stop it, unless the server was declared with @tt{#:warnings "refuse"}. To see
warnings without storing anything, send the resource to @tt{/Patient/$validate} first.}
@item{@bold{It gets an id and a version.} On a create (POST) the server chooses the id, ignoring
one you sent; the @tt{Location} header gives it. To choose the id yourself, declare @tt{update} and
send @tt{PUT /Patient/ann}. Each write stamps @tt{meta.versionId} and @tt{meta.lastUpdated}, and
the previous version is kept.}
@item{@bold{It is indexed} for every search parameter of its type, in the same step as the write,
so a search just after a write finds it.}
@item{@bold{Its references can be checked.} With @tt{#:references "checked"}, an observation that
names @tt{Patient/nope} is refused when the server serves patients and holds none of that id. By
default it is stored as sent.}]

@section[#:tag "rest"]{Pages, versions and conditional requests}

These are FHIR's own rules for talking to a server; every server here follows them.

@bold{A search can be asked for a page at a time.} @litchar{_count} is the page size. The answer's
@tt{total} is the number of resources that match, not the number on the page, and a @tt{next} link
leads to the following page (@tt{previous} leads back). Here three patients match and two were
asked for:

@verbatim|{
$ curl -s "http://localhost:8080/Patient?gender=female&_count=2"
{"resourceType":"Bundle","type":"searchset","total":3,
 "link":[{"relation":"self","url":"http://localhost:8080/Patient?gender=female&_count=2"},
         {"relation":"next","url":"http://localhost:8080/Patient?gender=female&_count=2&_offset=2"}],
 "entry":[ … two patients … ]}
}|

Follow @tt{next} until an answer has none. To get the number alone, ask for
@litchar{_summary=count}: the answer has the @tt{total} and no entries. A search may also be sent
as @tt{POST /Patient/_search} with the parameters as a form in the body, which keeps them out of
the url.

@bold{Every answer that is one resource carries its version.} The @tt{ETag} header is the
resource's @tt{meta.versionId}, and @tt{Last-Modified} its @tt{meta.lastUpdated}:

@verbatim|{
$ curl -s -i http://localhost:8080/Patient/d044f915
HTTP/1.1 200 OK
ETag: W/"1"
Last-Modified: Fri, 13 Nov 2026 20:39:31 GMT
}|

@bold{A read can say which version you already have.} Send that version back as
@tt{If-None-Match} (or the date as @tt{If-Modified-Since}); if it is still the current one the
server answers 304 and sends nothing:

@verbatim|{
$ curl -s -i http://localhost:8080/Patient/d044f915 -H 'If-None-Match: W/"1"'
HTTP/1.1 304 Not Modified
ETag: W/"1"
Content-Length: 0
}|

@bold{A write can say which version it changes.} Two people who read version 1 and both send an
update would otherwise overwrite each other without knowing. With @tt{If-Match}, an update, patch
or delete is carried out only if the version named is still the current one:

@verbatim|{
$ curl -s -i -X PUT http://localhost:8080/Patient/d044f915 -H 'If-Match: W/"7"' …
HTTP/1.1 412 Precondition Failed
{"resourceType":"OperationOutcome","issue":[{"severity":"error","code":"conflict","diagnostics":"If-Match: W/\"7\", but the current version is W/\"1\": the resource has changed since you read it"}]}
}|

Read the resource again, apply your change to what you get, and send it with the new version.

@bold{A deleted resource is gone, not unknown.} Reading it answers 410 Gone and says where its
earlier versions are; an id that was never used answers 404. (A server you declare can tell the
two apart when it serves @tt{history-instance}; without it both are 404.)

@section[#:tag "store"]{The store}

Both kinds of server keep their data in one SQLite file. SQLite is a database that lives in a
single file and needs no separate program; you can copy the file, back it up, or open it with any
SQLite tool. Inside, each resource is kept as its JSON, with every earlier version and the search
indexes. Two files with the same name plus @tt{-wal} and @tt{-shm} may sit beside it while a server
is running or after it was stopped abruptly; they are part of the store and are read again at the
next open.

@subsection{Loading files}

@tt{raco fhir-server load} fills a store from files, with no server running: FHIR resources as
JSON, Bundles (each entry is stored), bulk-data files (@tt{.ndjson} or @tt{.ndjson.gz}: one
resource to a line, read a batch at a time, so a file of any size loads), and @tt{.cql} libraries
(stored as Library resources). Here
@tt{data/} holds a patient and one of her lab results:

@verbatim{
$ raco fhir-server load clinic.db data/
a1c.json: 1 resource(s)
ann.json: 1 resource(s)
loaded 2 resources into clinic.db (indexed for FHIR 4.0.1 search)
}

A resource with an @tt{id} keeps it, and loading the same file again replaces it with a new
version. The resources are indexed for every search FHIR defines for their type, in FHIR R4 unless
you say @litchar{--fhir-version 5.0.0} or @litchar{6.0.0} (a server you declare is R6), so a server
started over the store later finds them.

By itself @tt{load} checks nothing: it stores what it reads. Add @litchar{--validate} to have every
resource, a Bundle's entries included, held to its type and to the profiles it claims before
anything is written. Each problem is printed with its file, and one error means nothing is loaded:

@verbatim{
$ raco fhir-server load clinic.db incoming/ --validate
bea.json: Patient/bea: error: Patient.gender: code `femme` not in required value set http://hl7.org/fhir/ValueSet/administrative-gender; it holds female, male, other, unknown
bea.json: Patient/bea: error: Patient.birthDate: '1980-02-30' is not a valid date (February 1980 has 29 days)
fhir-server load: 1 of 2 resource(s) are not valid FHIR 4.0.1 (2 error(s)): nothing was loaded
}

The command exits with status 1 and makes no store. Warnings are printed and do not stop the load.
When the data claims a guide's profiles, name the guide with @litchar{--package hl7.fhir.us.core}
(or a @tt{.tgz} file; repeatable), as for @tt{raco fhir-validate}: without it a claimed profile
that nothing in context defines is a warning, and the resource is checked against its base type
alone.

@subsection{Large files}

A bulk export is one resource to a line (@tt{.ndjson}, often gzipped), a file to a type, and can
hold hundreds of thousands of resources. @tt{load} reads such files as a stream and spreads the
work over every core of the machine: worker processes read the lines, stamp the resources and work
out their search index entries, and one process writes. When the store is empty, the search
indexes are built once at the end instead of entry by entry. The hospital dataset this is measured
on (a public intensive-care dataset of 928,935 resources, most of them observations) loads in a little over three minutes on four cores, about 4,700 resources a second. What is stored is
exactly what loading the resources one by one stores.

@subsection{Indexing again}

A resource is indexed for search when it is written. When the way values are indexed changes (a
newer version of this package, a store loaded as another FHIR version), the resources already
stored keep their old index entries. @tt{raco fhir-server reindex} works them out again:

@verbatim{
$ raco fhir-server reindex clinic.db
indexed 2 resources of clinic.db again (for FHIR 4.0.1 search)
}

It happens in one transaction: a reindex that is interrupted leaves the store as it was. A store
made before periods (an encounter's, a procedure's) were indexed as dates needs it once: until
then a search by such a date finds nothing in it.

@subsection{Reading it with SQL}

@tt{raco fhir-server sql} runs one SQL query over a store and prints the rows as CSV. It only
reads: anything but a @tt{SELECT} is refused. Each stored type is a table of that name with the
columns @tt{id}, @tt{versionId}, @tt{lastUpdated} and @tt{resource}, the JSON. SQLite's @tt{->>}
takes a value out of the JSON by its path:

@verbatim|{$ raco fhir-server sql clinic.db "SELECT id, resource ->> '$.subject.reference' AS patient, resource ->> '$.valueQuantity.value' AS value, resource ->> '$.valueQuantity.unit' AS unit FROM Observation"
id,patient,value,unit
a1c-1,Patient/ann,7.2,%}|

Two more tables span the types: @tt{resources} (every current resource, with a @tt{type} column)
and @tt{history} (every version ever written, the same columns):

@verbatim{
$ raco fhir-server sql clinic.db "SELECT type, count(*) AS n FROM resources GROUP BY type"
type,n
Observation,1
Patient,1
}

This is the quick look. For tables you will ask for again, describe them once as
@hyperlink["https://oloveluck.github.io/sql-on-fhir/"]{SQL on FHIR} views, which name their columns
by FHIRPath rather than by JSON paths.

@section[#:tag "measures"]{Measures}

A @italic{quality measure} counts, among a group of patients, how many received some recommended
care: of the women in the age range for breast-cancer screening, how many had a mammogram recently
enough. FHIR writes one
as a Measure resource that points to a library of logic in
@hyperlink["https://oloveluck.github.io/cql/"]{Clinical Quality Language} (CQL). The operation
@tt{$evaluate-measure} runs it and answers a MeasureReport with the counts.

A store that holds the Measure, its libraries, the value sets they use and the patients' records is
all that is needed. Here the files are the breast-cancer-screening measure and two of its test
patients from the public eCQM content (in the cql repository, under @tt{tests/vendor/ecqm}):

@verbatim{
$ raco fhir-server load measures.db ecqm/cql
…
loaded 12 resources into measures.db (indexed for FHIR 4.0.1 search)
$ raco fhir-server load measures.db ecqm/measure
…
loaded 4 resources into measures.db (indexed for FHIR 4.0.1 search)
$ raco fhir-server load measures.db ecqm/valueset
…
loaded 57 resources into measures.db (indexed for FHIR 4.0.1 search)
$ raco fhir-server load measures.db ecqm/tests/BreastCancerScreeningsFHIR/denom-EXM125
$ raco fhir-server load measures.db ecqm/tests/BreastCancerScreeningsFHIR/numer-EXM125-diagnosticReport
}

Then evaluate. The measure is named by its id or its canonical url, and the period is given as two
dates:

@verbatim|{$ raco fhir-server evaluate-measure measures.db BreastCancerScreeningsFHIR \
    --period-start 2021-01-01 --period-end 2021-12-31 --tz-offset -07:00
{"group":[{"measureScore":{"value":0.5},"population":[
  {"code":{"coding":[{"code":"initial-population", …}]},"count":2},
  {"code":{"coding":[{"code":"denominator", …}]},"count":2},
  {"code":{"coding":[{"code":"denominator-exclusion", …}]},"count":0},
  {"code":{"coding":[{"code":"numerator", …}]},"count":1}]}],
 "measure":"http://ecqi.healthit.gov/ecqms/Measure/BreastCancerScreeningsFHIR",
 "period":{"end":"2021-12-31","start":"2021-01-01"},"resourceType":"MeasureReport","status":"complete","type":"summary"}}|

Read the @italic{populations}: both patients are in the initial population and the denominator
(they are eligible), one is in the numerator (she had the screening), and the score is one half.
With @litchar{--subject Patient/numer-EXM125-diagnosticReport} the report is for that one patient,
each count 0 or 1. @litchar{--tz-offset} is the timezone the dates are read in; these test patients
were written for seven hours behind UTC.

The same operation is served over HTTP by a server generated from the CQF Measures guide, which
asks for it:

@verbatim|{$ raco fhir-server serve-ig hl7.fhir.us.cqfmeasures-5.0.0.tgz --capability measure-calculation-service-example \
    --load ecqm/cql --load ecqm/measure --load ecqm/valueset \
    --load ecqm/tests/BreastCancerScreeningsFHIR/denom-EXM125 \
    --load ecqm/tests/BreastCancerScreeningsFHIR/numer-EXM125-diagnosticReport \
    --tz-offset -07:00 --no-examples --port 8080

$ curl 'http://localhost:8080/Measure/BreastCancerScreeningsFHIR/$evaluate-measure?periodStart=2021-01-01&periodEnd=2021-12-31&subject=Patient/numer-EXM125-diagnosticReport'
$ curl 'http://localhost:8080/Measure/$evaluate-measure?measure=http://ecqi.healthit.gov/ecqms/Measure/BreastCancerScreeningsFHIR&periodStart=2021-01-01&periodEnd=2021-12-31'}|

The first answers the individual report (numerator 1), the second the summary above. What kinds of
measure are computed is a limit of the CQL package: proportion measures, counted per patient.

@section[#:tag "racket"]{From a program}

Everything the commands do is a function in Racket. This section shows the main ones;
@secref["reference"] has them all.

@subsection{A server from a guide}

@racketblock[
(require fhir/store/fhir-sqlite fhir/store/ig-server fhir/http/server)
(define store (open-fhir-store "us-core.db"))
(define srv (make-ig-server store (ig-package-path "hl7.fhir.us.core") #:capability "us-core-server"))
(load-ig-examples! srv)                               (code:comment "=> 255 loaded, none rejected")
(ig-server-gaps srv)                                  (code:comment "=> '(): the unmet requirements")
(define stop (serve-app (ig-server-app srv) #:port 8080))
(stop)                                                (code:comment "when done")
]

@subsection{A declared server, in process}

A declaration file is a module. It provides @racket[app] (the server as a value),
@racket[capability-statement] and @racket[operation-definitions], and each operation you declared
as a function. Nothing needs to listen on a port for you to use them:

@racketblock[
(require (only-in fhir/capability/runtime dispatch search-request)
         (only-in "study.capability.rkt" app $double))
(dispatch app (search-request 'Patient '((gender . "male"))))   (code:comment "a searchset Bundle")
($double #:x 2.5)                                               (code:comment "a Parameters: doubled = 5.0")
]

@subsection{Operations alone, over HTTP}

Any of the family's operations can be served with no resources at all. The CapabilityStatement is
derived from the list:

@racketblock[
(require fhir/capability/operations fhir/conformance/operations fhir/terminology/operations
         fhir/r5/schemas)
(define stop (serve-operations (cons $validate terminology-operations) #:port 8080
                               #:terminology-capabilities (current-terminology-capabilities)))
]

That is what @hyperlink["../fhir-tx/index.html"]{@tt{raco fhir-tx serve}} does for the terminology
operations.

@subsection{The store directly}

The store is usable without any server: versioned writes, history, search, and FHIR transaction
Bundles. Search is driven by a @italic{catalog} of search parameters read from a package.

@racketblock[
(require fhir/store/fhir-sqlite fhir/store/fhir-engine fhir/store/bundle fhir/store/serve
         fhir/store/ig-params fhir/spec-package fhir/r5/schemas)
(define store (open-fhir-store "fhir.db"))
(define core (spec-package-path "hl7.fhir.r5.core.tgz"))
(define catalog (search-params-from-package core))

(define-values (type id version) (fhir-create! store patient #:search-params catalog))
(fhir-search store "Patient" '(("gender" . "male")) #:search-params catalog)
(fhir-update! store (hash-set patient 'id id) #:search-params catalog)   (code:comment "=> 2, the new version")
(fhir-history store "Patient" id)                                        (code:comment "both versions")
(process-bundle! store transaction-bundle #:search-params catalog)       (code:comment "all of it, or none")

(code:comment "a server over the store: the types you name, searched by the package's parameters;")
(code:comment "with audit, every write also records an AuditEvent and a Provenance")
(serve-app (make-store-app store #:package core #:types '(Patient Observation) #:audit? #t) #:port 8080)
]

@section{For an AI agent}

In a @hyperlink["../fhir-mcp/index.html"]{fhir-mcp} workspace a declaration file
(@tt{<name>.capability.rkt}) is one of the workspace's languages: the agent writes it and gets its
mistakes back at their lines, runs it over the workspace's own store, and calls its operations. The
guide written for an agent to read is @tt{fhir-server/capability/guide.md} (served as
@tt{learn://capability}, printed by @tt{raco fhir guide capability}); every example in it is run by
the tests. @tt{.claude/skills/fhir-serving} is the same ground for an agent using the command line.

@section[#:tag "limits"]{Limits}

What a FHIR server can be asked for and these do not do. A server generated from a guide reports
the search parameters, includes, interactions and operations it cannot do as gaps; the rest is not
reported anywhere but here.

@itemlist[
@item{@bold{Not for production.} There is no TLS, and no access control beyond one fixed token
(@litchar{--bearer}): no SMART on FHIR, OAuth, scopes or per-patient permissions. A guide's security
section is copied into @tt{/metadata} unchanged. Run these servers on your own machine or a trusted
network.}
@item{@bold{Search that is not done.} Chained searches (@tt{patient.name=…}), reverse chaining
(@litchar{_has}), composite and special parameters, @litchar{_summary}, @litchar{_elements},
@litchar{_total}, @litchar{_filter}, @litchar{_text}, @litchar{_content}, @litchar{:iterate}, the
modifiers @litchar{:above}, @litchar{:below}, @litchar{:in} and
@litchar{:identifier}, searching across all types at once, and the
parameters defined for every resource (@litchar{_tag}, @litchar{_profile}, @litchar{_security}).
Of @litchar{_summary} only @tt{count} is done. A lenient server answers as if the unsupported part
were not there (@secref["search"]). Quantity
search does not convert units. String search covers names and addresses, not every complex type.}
@item{@bold{Paging.} Pages are taken by position (@litchar{_offset}): a resource written between
two requests can shift what the next page holds. There are @tt{next} and @tt{previous} links, no
@tt{first} or @tt{last}. A history is not paged.}
@item{@bold{@tt{raco fhir-server load} validates only when asked.} Without @litchar{--validate} it
stores and indexes what it reads.}
@item{@bold{Conditional writes by search.} No conditional create, update or delete
(@tt{If-None-Exist}, @tt{PUT /Type?param}, @tt{DELETE /Type?param}). @tt{If-Match} is checked just
before the write, not in one step with it: two writers a few milliseconds apart can both pass. A
PUT that creates a resource answers 201, except when it re-creates one that was deleted (200: the
resource already has earlier versions).}
@item{@bold{History.} Of one resource and of one type, with @litchar{_since} and @litchar{_count};
not of the whole server, no @litchar{_at}, no paging. A delete removes the current resource and
leaves its versions, but is not itself recorded as an entry.}
@item{@bold{Transactions.} A server generated from a guide (and @racket[make-store-app]) accepts
transaction and batch Bundles at @tt{POST /}: a transaction is all or nothing, and temporary
@tt{urn:} references between its entries are resolved. Its entries may be POST, PUT and DELETE; no
GET or PATCH entries, and no conditional ones. On a generated server each resource in a Bundle is
validated as a single write is: a transaction with an invalid entry is refused whole, and a batch
answers that entry with its problems (422) and writes the others. A declared server has no
transaction endpoint.}
@item{@bold{PATCH} takes JSON Patch only, not FHIRPath Patch.}
@item{@bold{Transport.} JSON only, no XML and no content negotiation. HTTP/1.1, one request per
connection; no HEAD or OPTIONS, no CORS headers.}
@item{@bold{Operations.} Those implemented in the family (validation, terminology, snapshot,
transform, measure evaluation, US Core's @tt{$docref}) and the ones you declare. No
@tt{$everything} or patient compartments, no subscriptions, bulk export or GraphQL.}
@item{@bold{FHIR versions.} A declared server is R6 and cannot be made R4 or R5; an R4 client's
JSON is accepted where the two versions agree (the capability guide lists where they differ). A
generated server has its guide's version.}
@item{@bold{A generated server's CapabilityStatement} keeps some of the guide's flags as written
(@tt{conditionalCreate}, @tt{conditionalUpdate}, @tt{versioning}, @tt{updateCreate}) although
conditional requests are not done, and always lists transaction and batch.}
@item{@bold{Measures.} Proportion measures counted per patient; see the limits of
@hyperlink["https://oloveluck.github.io/cql/"]{cql}.}]

@section[#:tag "words"]{Words used here}

@itemlist[
@item{@bold{Resource}: one FHIR document, such as a Patient or an Observation, written as JSON.}
@item{@bold{FHIR server}: a program that stores resources and answers requests for them over HTTP,
in the way FHIR lays down (its @italic{REST API}).}
@item{@bold{Interaction}: one of the things a server lets you do with a resource: read, create,
update, delete, search, and the others in @secref["declare"].}
@item{@bold{Search parameter}: a named thing a resource can be searched by (@tt{gender},
@tt{birthdate}); its kind (token, string, date, reference …) decides how values are compared.}
@item{@bold{CapabilityStatement}: a server's own description of what it supports, served at
@tt{/metadata}.}
@item{@bold{Operation}: a named service beyond the interactions, written with a dollar sign
(@tt{$validate}, @tt{$evaluate-measure}). @bold{OperationDefinition}: its formal description.}
@item{@bold{Parameters}: the FHIR resource that carries an operation's named inputs or outputs.}
@item{@bold{Bundle}: FHIR's envelope for several resources: a search result (@italic{searchset}), a
history, or a @italic{transaction}, a set of writes done all together or not at all.}
@item{@bold{OperationOutcome}: the FHIR resource that reports problems, one issue each.}
@item{@bold{Implementation Guide} (IG): a published set of profiles, search parameters, operations
and examples for one purpose. @bold{Package}: the @tt{.tgz} file it is distributed as.}
@item{@bold{Profile}: stricter rules for one type of resource in one setting. A resource
@italic{claims} a profile by listing it in @tt{meta.profile}.}
@item{@bold{Gap}: something a guide asks of a server that this one does not do.}
@item{@bold{Strict}, @bold{lenient}: whether a search with a parameter the server cannot apply is
refused or answered without it.}
@item{@bold{Store}: the SQLite file the resources, their versions and the search indexes are kept
in.}
@item{@bold{Measure}: a quality measure. @bold{Population}: one of its counted groups (initial
population, denominator, numerator). @bold{MeasureReport}: the result.}
@item{@bold{Handler}: the function that does an operation's work.}
@item{@bold{Canonical url}: the web address that names a profile, a measure or an operation's
definition. It is a name; nothing needs to be served there.}]

@section[#:tag "tested"]{How it is tested}

Against published guides, used as the specification of a server:

@itemlist[
@item{@bold{US Core 9.0.0.} The generated server serves all 31 resource types with no unmet
requirement at any level; the guide's examples load through validation with none rejected; and each
example is found by searching on its own values, 2468 searches out of 2468.}
@item{@bold{mCODE 4.0.0}, compiled from its FHIR Shorthand source, packed and served here: all 283
examples validate against its profiles, with no unmet requirement.}
@item{@bold{CQF Measures 5.0.0.} A measure server generated from the guide evaluates two published
measures for 65 test patients; 60 reports are as expected, and the 5 that differ are named in the
test with the reason.}
@item{@bold{A declared server's own description is valid FHIR}: the derived CapabilityStatement,
every OperationDefinition and a search result are run through the validator. The examples of the
capability guide are run as written, over a real socket.}]

Speed is measured on one dataset, the same way each time (@tt{fhir-server/bench/store-bench.rkt}):
a public intensive-care dataset of 928,935 resources. It loads in a little over three minutes, and a search for one patient's ten most recent observations among
them answers in under a fifth of a second.

The repository's @hyperlink["https://github.com/oloveluck/fhir/blob/main/TESTING.md"]{@tt{TESTING.md}}
has every suite, names the misses, and has the timings.

@section[#:tag "reference"]{Reference}

@subsection[#:tag "commands"]{Commands}

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @tt{raco fhir-server serve-ig <ig> [options]} @elem{a server generated from a guide (@secref["serve-ig"] has the options)})
      (list @tt{raco fhir-server check <app.rkt>} "a declaration compiled: what it offers, or its mistakes")
      (list @tt{raco fhir-server serve <app.rkt> [port | --port n] [--store fhir.db] [--log]} "a declared server")
      (list @tt{raco fhir-server load <store.db> <file|dir> [--validate]} @elem{resources, Bundles, bulk-data files and @tt{.cql} libraries into a store})
      (list @tt{raco fhir-server reindex <store.db> [--fhir-version v]} "every stored resource indexed for search again")
      (list @tt{raco fhir-server sql <store.db> "SELECT …"} "one reading query over a store, as CSV")
      (list @tt{raco fhir-server evaluate-measure <store.db> <Measure id|url> --period-start D --period-end D [--subject Patient/x] [--tz-offset ±hh:mm]} "a MeasureReport from a store"))]

Each takes @litchar{--help}. Exit codes: 0, 1 when the thing asked for failed (a declaration with
mistakes, a port in use, an unknown measure), 2 when the command was called wrongly.

@subsection[#:style 'unnumbered]{@hash-lang[] @tt{fhir/capability}}
@defmodulelang[fhir/capability]

The @racket[server], @racket[resource] and @racket[operation] forms, as in @secref["declare"];
provides @racket[app], @racket[capability-statement] and @racket[operation-definitions]. The forms
are checked when the module compiles (resource types, interactions, parameter types, server options)
and every mistake is reported, each at its form. Everything from @racket[fhir/capability/runtime],
@racket[fhir/capability/derive] and @racket[fhir/r6/types] is in scope. An inline
@racket[(operation $code … #:handler h)] also defines @racket[$code] as a @tt{fhir/operation} value
(@racket[declared-operation]): the same handler, applied in-process with the inputs and an
in-process request, registered by its canonical (@tt{urn:fhir-capability:operation:<code>}) and
provided by the module — a pipeline declared once is served and callable
(@racket[($code #:name value)], @racket[(apply-operation "$code" …)]).

@itemlist[
@item{@racket[(server #:store f #:search-handling s #:references r #:warnings w #:url u #:name n
#:description d #:status s #:date d #:mode m #:format f ...)], once; every keyword optional, each
value a string. @racket[#:fhir-version] is accepted only as the server's own (R6).}
@item{@racket[(resource Type #:interactions (...) #:search-params ([name type] [name type "FHIRPath"] ...) #:repository r #:profile url)].
Without @racket[#:repository] the resource is kept in the store: the one
@racket[current-repository-factory] gives (@tt{raco fhir-server serve --store}, a workspace), else
the server form's @racket[#:store] file, else a temporary SQLite file.}
@item{@racket[(operation $code #:on Type #:in ([name type min max option ...] ...) #:out (...) #:handler h)], or
@racket[#:system] in place of @racket[#:on Type]; an input's options are @racket[#:min],
@racket[#:max], @racket[#:binding] and @racket[#:documentation]. The handler is
@racket[(lambda (inputs request) node)]. @racket[(operation "ValueSet/$expand")] or
@racket[(operation $validate)] exposes an existing @tt{fhir/operation} value under its own
definition.}]

@subsection[#:style 'unnumbered]{@tt{fhir/capability/runtime}}
@defmodule[fhir/capability/runtime]

The in-process app: structs of closures, a request as plain data, and @racket[dispatch].

@defstruct*[app ([capability-statement fhir?] [operation-definitions list?] [repositories hash?] [operations hash?] [transaction (or/c procedure? #f)] [metadata hash?])]{@racket[metadata] maps a @tt{mode} to the resource @tt{GET /metadata?mode=} answers, and carries the app's settings (strict search, checked references).}
@defstruct*[repository ([read any/c] [vread any/c] [create any/c] [update any/c] [delete any/c] [search any/c] [history any/c] [patch any/c])]{
A closure per interaction, or @racket[#f]: @tt{read (id)}, @tt{vread (id vid)}, @tt{create (node)},
@tt{update (id node)}, @tt{delete (id)}, @tt{search (params)} answering nodes or a
@racket[search-result], @tt{history (id-or-#f params)}, and @tt{patch} as a read and update pair.}
@defproc[(make-repository [#:read read any/c #f] [#:vread vread any/c #f] [#:create create any/c #f] [#:update update any/c #f]
                          [#:delete delete any/c #f] [#:search search any/c #f] [#:history history any/c #f] [#:patch patch any/c #f]) repository?]
@defproc[(make-default-repository [type symbol?] [interactions (listof symbol?)] [search-params (listof list?)]) repository?]{
The repository of a resource declared without one: @racket[current-repository-factory]'s when it is
set, else in memory, implementing the interactions given, with search by equality of each
parameter's FHIRPath values.}
@defparam[current-repository-factory factory (or/c #f (-> symbol? (listof symbol?) (listof list?) repository?))]{
What makes the repository of a resource declared without @racket[#:repository]: a type, its
interactions and its search parameters to a repository. @racket[fhir/capability/store] has the
SQLite ones.}
@defproc[(build-app [#:capability cs fhir?] [#:operation-definitions ods (listof fhir?)]
                    [#:repositories repos (listof (cons/c symbol? repository?))] [#:operations ops (listof operation-entry?)]
                    [#:transaction transaction (or/c #f (-> hash? hash?)) #f] [#:metadata metadata hash? (hash)]) app?]
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
(checked against the derived OperationDefinition, every problem at once), an inline operation's
answer that does not match its declared outputs, or a raised exception is an OperationOutcome.}
@defstruct*[search-result ([matches list?] [includes list?])]
@defstruct*[(search-result/ignored search-result) ([names list?])]{A search result that also names
the parameters that were not applied; a lenient search says them in the Bundle, a strict one
refuses.}
@defstruct*[(search-page search-result/ignored) ([total exact-nonnegative-integer?])]{One page
(@tt{_count}, @tt{_offset}) of @racket[total] matches: the Bundle's @tt{total}, and what decides
whether it has a @tt{next} link. A repository that answers a plain list or one of the structs above
answers every match.}
@defproc[(search-facts [r any/c]) (values list? list? (listof string?) exact-nonnegative-integer?)]{
What a repository's search answered, whichever of the four forms it took: the matches, the included
resources, the parameters not applied, and the total.}
@defstruct*[operation-entry ([level symbol?] [code string?] [target any/c] [proc procedure?])]
@defstruct*[operation-handler ([proc procedure?] [op-def any/c] [level any/c] [target any/c])]
@defparam[current-app a (or/c app? #f)]{The app dispatching the current request.}
@defparam[current-request-json body any/c]{The request body as sent, set by the HTTP layer while
dispatching. Validation and operations read it: the typed node is parsed leniently and has dropped
what it did not know.}
@defparam[current-search-strict? strict? any/c]{Whether the current request asked for strict search
handling (@tt{Prefer: handling=strict}).}
@defproc[(strict-search-app? [a app?]) boolean?]{Whether the app refuses every search it cannot
apply in full (@tt{(server #:search-handling "strict")}).}
@defthing[r6-sd-packages any/c]{The R6 core package as the validation context of a declared
server.}
@defstruct*[(exn:fail:declaration exn:fail:user) ([type any/c])]{A mistake in a declaration found
when the app is built (a search parameter FHIR does not define), reported at its form.}
@deftogether[(
@defproc[(operation-outcome [severity string?] [code string?] [diagnostics string?]) fhir?]
@defproc[(operation-outcome-not-supported [msg string?]) fhir?]
@defproc[(operation-outcome-invalid [msg string?]) fhir?]
@defproc[(operation-outcome-exception [msg string?]) fhir?]
@defproc[(operation-result? [v any/c]) boolean?]
@defproc[(refused! [node any/c]) any/c]
@defproc[(make-searchset [result any/c]) fhir?]
@defproc[(parameters->hash [p (or/c fhir? #f)]) hash?])]{
OperationOutcome constructors for handlers; whether an operation's definition returns an
OperationOutcome as its result; an OperationOutcome marked as the request's own failure, so it is
not mistaken for such a result; a searchset Bundle from a search result; a Parameters node as a hash
of name to values.}

@subsection[#:style 'unnumbered]{@tt{fhir/capability/derive}}
@defmodule[fhir/capability/derive]

@deftogether[(
@defproc[(derive-capability-statement [server rc-server?] [resources (listof rc-resource?)] [operations (listof rc-operation?)]) any/c]
@defproc[(derive-operation-definition [op rc-operation?]) any/c]
@defproc[(op-code->canonical [code string?]) string?]
@defproc[(operation-name [code string?]) string?])]{
The CapabilityStatement and OperationDefinition nodes from the declarations; the canonical is the
join key between @tt{rest.resource.operation.definition} and @tt{OperationDefinition.url};
@racket[operation-name] is an OperationDefinition's machine-usable name (@racket["evaluate-measure"]
gives @racket["EvaluateMeasure"]).}
@deftogether[(
@defproc[(rc-server [mode string?] [status string?] [date string?] [fhir-version string?] [format list?] [url any/c]
                    [name any/c #f] [description any/c #f]) rc-server?]
@defstruct*[rc-resource ([type symbol?] [interactions list?] [search-params list?] [profile any/c])]
@defstruct*[rc-operation ([code string?] [display string?] [levels list?] [resource-types list?] [in-params list?] [out-params list?] [canonical any/c])]
@defproc[(rc-param [name string?] [type string?] [min exact-nonnegative-integer?] [max any/c] [use string?]
                   [binding any/c #f] [documentation any/c #f] [low any/c #f] [high any/c #f]) rc-param?])]{
The declarations as values. @racket[rc-server] and @racket[rc-param] are constructors with optional
last arguments (the structs are @tt{rc-server-struct} and @tt{rc-param-struct}):
a parameter's @racket[binding] is the value set a code input must come from, @racket[low] and
@racket[high] a number's range.}

@subsection[#:style 'unnumbered]{@tt{fhir/capability/operations}}
@defmodule[fhir/capability/operations]

@tt{fhir/operation} values served over HTTP, with the CapabilityStatement derived from them.

@defproc[(serve-operations [ops (listof operation?)] [#:port port exact-nonnegative-integer? 8080] [#:url url (or/c string? #f) #f]
                           [#:fhir-version version string? "5.0.0"] [#:bearer bearer (or/c string? #f) #f]
                           [#:terminology-capabilities capabilities (or/c hash? #f) #f]) procedure?]{
@racket[(serve-operations (list $validate $expand) #:port 8080)]; returns the stop thunk.}
@defproc[(operations-app [ops (listof operation?)] [#:url url (or/c string? #f) #f] [#:fhir-version version string? "5.0.0"]
                         [#:terminology-capabilities capabilities (or/c hash? #f) #f]) app?]
@defproc[(operation->entries [op operation?] [#:read read (or/c procedure? #f) #f] [#:around around procedure? (lambda (thunk) (thunk))]) list?]{
Routes at every level and type the definition declares, the request Parameters as inputs, the stored
resource as the instance-level subject (through @racket[current-app], or @racket[read]);
@racket[around] wraps each call to bind the data source and packages.}
@deftogether[(@defproc[(operation->rc [op operation?]) any/c] @defproc[(operation->od [op operation?]) any/c])]
@defproc[(declared-operation [definition any/c] [handler procedure?] [code string?]) operation?]{
An inline declaration as a @tt{fhir/operation} value: the handler run with the inputs and an
in-process request, its typed result returned as JSON, registered by its canonical.}

@subsection[#:style 'unnumbered]{@tt{fhir/capability/store}}
@defmodule[fhir/capability/store]

The SQLite repositories of a declared server.

@defproc[(store-repository-factory [s fhir-store?] [#:search-params catalog hash? (core-search-params)] [#:validate? validate? boolean? #t]) procedure?]{
A @racket[current-repository-factory] over a store: each repository restricted to the declared
interactions, searching with the declared parameters, validating what is written.}
@defproc[(store-file-factory [path path-string?]) procedure?]{The same over the store in that file, opened once per path.}
@defproc[(temporary-store-factory) procedure?]{The same over a store in a temporary file, removed when the process ends.}
@defproc[(core-search-params) hash?]{The R6 core package's SearchParameters as a catalog.}
@defproc[(with-declared [catalog hash?] [type symbol?] [search-params (listof list?)]) hash?]{The catalog with a declaration's own @tt{[name type "FHIRPath"]} parameters added.}
@defproc[(opened-store-files) (listof path?)]{The store files this process has opened for apps.}

@subsection[#:style 'unnumbered]{@tt{fhir/http/server}}
@defmodule[fhir/http/server]

@defproc[(serve-app [a app?] [#:port port (integer-in 0 65535) 8080] [#:host host (or/c string? #f) #f] [#:bearer bearer (or/c string? #f) #f]
                    [#:log? log? boolean? #f] [#:on-listen on-listen (or/c #f (-> (integer-in 1 65535) any)) #f]) (-> void)]{
Serves the app over HTTP/1.1 (one request per connection, a thread each) and returns a thunk that
stops it. Port 0 takes a free port; @racket[on-listen] receives the port listened on. With
@racket[bearer], every request but @tt{GET /metadata} needs that token. With @racket[log?], a line
per request on standard error. Searchset and history Bundles get each entry's @tt{fullUrl} and a
@tt{self} link from the request's @tt{Host}.}
@defproc[(answer [a app?] [method string?] [target string?] [headers (listof (cons/c string? string?))] [body string?]) response?]{
One request answered, as a value and with no socket: the router's answer, and around it what only
HTTP knows. The base url from the @tt{Host} header (absolute paging links, @tt{fullUrl}s,
@tt{Location}); @tt{Prefer: handling=strict}; the resource's version as @tt{ETag} and
@tt{Last-Modified}; a conditional read answered 304; a write refused 412 when @tt{If-Match} names
another version than the current one (@secref["rest"]). @racket[headers] are lower-cased names with
their values.}
@defstruct*[response ([status exact-integer?] [body bytes?] [content-type string?] [headers (listof (cons/c string? string?))])]{What goes on the wire.}

@subsection[#:style 'unnumbered]{@tt{fhir/http/router}}
@defmodule[fhir/http/router]

@defproc[(handle [a app?] [method string?] [path string?] [query (listof (cons/c symbol? string?))] [body string?]) (values exact-integer? (or/c hash? #f))]{
The pure router: @tt{GET /metadata} (@tt{?mode=} picks another metadata resource); @tt{POST /}
(a transaction through the app's processor; a batch entry by entry when it has none); @tt{GET|POST /{Type}};
@tt{GET|PUT|DELETE|PATCH /{Type}/{id}} (PATCH as JSON Patch); @tt{/{Type}/{id}/_history[/{vid}]},
@tt{/{Type}/_history}; @tt{POST /{Type}/_search} (the parameters as a form); @tt{GET|POST /$op}, @tt{/{Type}/$op}, @tt{/{Type}/{id}/$op};
@tt{GET /OperationDefinition[/{code}]}. The status comes from the result: 201 on create, and for an
OperationOutcome its first issue code (not-found 404, deleted 410, not-supported 405 on a served
type, invalid 400, processing 422, conflict 409, exception 500).}
@defproc[(handle/raw [a app?] [method string?] [path string?] [query (listof (cons/c symbol? string?))] [body string?]) (values exact-integer? bytes? string?)]{Like @racket[handle], but a Binary result streams as its own content type.}
@defproc[(parse-query [s string?]) (listof (cons/c symbol? string?))]

@subsection[#:style 'unnumbered]{@tt{fhir/store/fhir-sqlite}}
@defmodule[fhir/store/fhir-sqlite]

@defstruct*[fhir-store ([path path-string?] [pool connection-pool?])]
@defproc[(open-fhir-store [path path-string?] [#:max-connections n exact-positive-integer? 8] [#:lazy? lazy? any/c #f]) fhir-store?]{
WAL mode; resources kept as SQLite JSONB. The schema is created on open, or, with @racket[lazy?], when
the store is first used (nothing touches the file before).}
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
prefixes, modifiers, @tt{_id}, @tt{_lastUpdated}, @tt{_count}, @tt{_offset}, @tt{_sort}, and comma
as OR; unknown parameters are ignored and reported by @racket[fhir-search/ignored].

@defstruct*[search-param ([name string?] [kind symbol?] [path string?])]{A parameter: its type and its FHIRPath.}
@defthing[default-search-params (hash/c symbol? (listof search-param?))]{A small catalog for Patient, Observation and Condition; packages supply the real one (@racket[make-store-app], @racket[core-search-params]).}
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
@defproc[(fhir-search/page [s fhir-store?] [type string?] [params (listof (cons/c string? string?))] [#:search-params catalog hash? default-search-params]) (values (listof jsexpr?) (listof string?) exact-nonnegative-integer?)]
@defproc[(fhir-includes [s fhir-store?] [type string?] [matches (listof jsexpr?)] [params (listof (cons/c string? string?))]) (listof jsexpr?)])]{
Create returns type, id and version. Delete removes the current resource and its index rows; history
remains and @racket[fhir-vread] still reads it. Includes take @tt{_include} and @tt{_revinclude}
values (@tt{Source:param}, @tt{Source:param:Target}, @tt{Source:*}).}
@deftogether[(
@defproc[(create-in! [c connection?] [resource jsexpr?] [catalog hash?] [#:rows rows (or/c #f list?) #f]) (values string? string? exact-positive-integer?)]
@defproc[(update-in! [c connection?] [resource jsexpr?] [catalog hash?] [#:rows rows (or/c #f list?) #f]) exact-positive-integer?]
@defproc[(delete-in! [c connection?] [type string?] [id string?]) boolean?])]{The writes on a leased
connection, to compose several in one transaction. @racket[rows] are the resource's index rows when
they were extracted ahead.}
@deftogether[(
@defproc[(indexed-entries [catalog hash?] [type string?]) (listof (list/c string? symbol? string?))]
@defproc[(index-rows/text [item (list/c string? list?)]) (listof (list/c string? string? list?))])]{
The catalog's indexed parameters of a type as plain rows, and a resource's index rows from its JSON
text and those entries: what a worker process is handed, so a bulk load extracts on every core.}

@subsection[#:style 'unnumbered]{@tt{fhir/store/bundle}}
@defmodule[fhir/store/bundle]

@defproc[(process-bundle! [s fhir-store?] [bundle jsexpr?] [#:search-params catalog hash? default-search-params]
                          [#:tower tower (or/c module-path? #f) #f]) jsexpr?]{
A transaction or batch Bundle: @tt{urn:uuid} references rewritten to @tt{Type/id} first, entries
applied in spec order (deletes, creates, updates), a transaction in one store transaction that rolls
back whole on any failure, a batch entry by entry with error entries; the response Bundle mirrors
the request order. @racket[tower] names the type tower the store runs on (@racket['fhir/r4/schemas]
…): with it, a large load's index rows are extracted on every core before the writes.}
@defproc[(load-bundle! [s fhir-store?] [bundle jsexpr?] [#:search-params catalog hash? default-search-params]
                       [#:tower tower (or/c module-path? #f) #f]) (values exact-nonnegative-integer? jsexpr?)]{Prepopulation; also accepts a @tt{collection} Bundle as a batch of creates.}

@subsection[#:style 'unnumbered]{@tt{fhir/store/load}}
@defmodule[fhir/store/load]

@defproc[(load-files! [s fhir-store?] [path path-string?] [#:search-params catalog hash? default-search-params] [#:library-base base string? "http://localhost/fhir"]
                      [#:tower tower (or/c module-path? #f) #f]) (listof (cons/c string? exact-nonnegative-integer?))]{
A file, or every @tt{.json}, @tt{.ndjson}, @tt{.ndjson.gz} and @tt{.cql} under a directory:
Bundles, resources (upserted by id), bulk-data files and CQL files as Library resources. The count
loaded per file. With @racket[tower] (the type tower the store runs on, @racket['fhir/r4/schemas])
bulk-data files are prepared on every core. Resources are indexed by
@racket[catalog]: with the default, by the few parameters of @racket[default-search-params] only.}
@defproc[(file-resources [path path-string?]) (listof (cons/c string? hash?))]{Every resource
@racket[load-files!] would write from the JSON files at @racket[path], each with its file's name and a
Bundle's entries each on their own: what @litchar{--validate} checks before the load.}
@defproc[(cql->library [cql string?] [#:library-base base string?]) hash?]{A logic Library carrying the CQL as base64 @tt{text/cql}, named from its header.}

@subsection[#:style 'unnumbered]{@tt{fhir/store/serve}}
@defmodule[fhir/store/serve]

@defproc[(make-store-app [s fhir-store?] [#:package package (or/c path-string? (listof path-string?))] [#:types types (listof symbol?)]
                         [#:url url (or/c string? #f) #f] [#:extra-params extra hash? (hash)] [#:fhir-version version string? "5.0.0"] [#:audit? audit? boolean? #f]) app?]{
The servable app over a store: read, vread, create, update, delete and search per type, a
transaction handler, the search catalog from the package's SearchParameters (the advertised
parameters are the indexed ones), the CapabilityStatement derived from it. With @racket[audit?],
every committed write records an AuditEvent, and creates and updates a Provenance, into the same
store. It serves history and PATCH but advertises neither.}
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
gives the types, interactions, search parameters, includes, supported profiles and operations (a
resource that lists search parameters without the @tt{search-type} interaction is read as
searchable); the catalog is core overlaid by the IG; every write is validated against its base type
and claimed profiles (422 on error); registered operations the IG declares are served with the store
as data source; @tt{/metadata} is the IG's own statement trimmed to what runs, and everything
trimmed is a @racket[gap].}
@defstruct*[ig-server ([plan ig-plan?] [app app?] [gaps (listof gap?)] [catalog hash?] [sd-packages list?] [store fhir-store?] [validate? boolean?] [tgz path?])]{
@racket[ig-server-app] is what @racket[serve-app] serves.}
@defstruct*[gap ([type any/c] [what any/c] [name any/c] [expectation any/c] [reason any/c])]{One requirement the server does not meet, with its SHALL, SHOULD or MAY.}
@defproc[(gap->list [g gap?]) list?]
@defproc[(plan-ig-server [package path-string?] [capability (or/c string? #f) #f]) ig-plan?]{The reading of the IG's statement, without a store (@tt{fhir/store/ig-plan}, which also resolves the package's dependencies). The gaps and the instance statement are @tt{fhir/store/ig-capability}'s: the statement held against what the server executes, as four predicates.}
@deftogether[(
@defstruct*[ig-plan ([name string?] [version string?] [fhir-version string?] [tower any/c] [core-tgz any/c] [ig-cs any/c] [resources list?])]
@defstruct*[ig-resource ([type any/c] [interactions list?] [search-params list?] [profiles list?])])]
@defproc[(ig-server-put! [srv ig-server?] [resource hash?]) (or/c 'ok any/c)]{Validate and upsert by id (ids and references preserved); the OperationOutcome when invalid.}
@defproc[(load-ig-examples! [srv ig-server?]) (values exact-nonnegative-integer? (listof (cons/c string? string?)))]{Every example in the package, and the IG's ValueSets and CodeSystems; the ones rejected, with the reason.}
@deftogether[(@defproc[(ig-package-path [ref string?]) path?] @defproc[(package-manifest [package path-string?]) (or/c hash? #f)])]{A package by name in @tt{fhir-spec}, file name or path; its @tt{package.json}.}
