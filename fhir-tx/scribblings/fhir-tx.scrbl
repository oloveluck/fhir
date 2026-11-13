#lang scribble/manual
@; Text in @tt is shown exactly as written: no curly quotes, and "--" stays two hyphens.
@(require (only-in scribble/core [element literal-element]))
@(define (tt . text) (literal-element (quote tt) text))
@(require (for-label racket/base racket/contract fhir/terminology/service fhir/terminology/operations))

@title{fhir-tx: codes, code systems and value sets}

Health records are full of codes. A diagnosis, a lab test, a patient's gender, the status of an
order: each is written as a short code from an agreed list rather than as free text, so that two
systems mean the same thing by it. Working with such data keeps raising the same few questions.
Which codes are allowed here? Is this code one of them? What does this code mean? What is the
matching code in that other list?

Answering them is the job of a @italic{terminology service}, and
@hyperlink["https://hl7.org/fhir/terminology-service.html"]{FHIR} defines what one must answer.
This package is a terminology service. It reads the code lists that FHIR and the published
Implementation Guides ship, and answers those questions from the command line
(@tt{raco fhir-tx}), over HTTP, or as functions in a program.

Part of the @hyperlink["https://oloveluck.github.io/fhir/"]{fhir} family of FHIR languages and tools.

@table-of-contents[]

@section{What you can do with it}

@itemlist[
@item{@bold{List the codes in a value set}: @secref["expand"].}
@item{@bold{Ask whether a code is in a value set}: @secref["validate-code"].}
@item{@bold{Ask what a code means}: @secref["lookup"].}
@item{@bold{Find the matching code in another system}: @secref["translate"].}
@item{@bold{Ask whether one code is a kind of another}: @secref["subsumes"].}
@item{@bold{Serve all of this over HTTP}, as a FHIR terminology server: @secref["serve"].}
@item{@bold{Use it from a program}, from FHIRPath, or to let the validator check codes:
@secref["program"].}]

@section[#:tag "first"]{A first example}

@bold{1. Install} the tools as the @hyperlink["https://oloveluck.github.io/fhir/"]{family's front
page} describes. The command is then @tt{raco fhir-tx} (or @tt{fhir-tx}, if you built the standalone
tools).

@bold{2. Ask which codes a value set holds.} FHIR says a patient's gender must be one of a small
set of codes. That set has a name, which is a web address:
@tt{http://hl7.org/fhir/ValueSet/administrative-gender}. Ask for its members:

@verbatim|{$ raco fhir-tx expand http://hl7.org/fhir/ValueSet/administrative-gender
{"expansion":{"contains":[{"code":"male","display":"Male","system":"http://hl7.org/fhir/administrative-gender","version":"5.0.0"},{"code":"female","display":"Female", …},{"code":"other","display":"Other", …},{"code":"unknown","display":"Unknown", …}],"total":4},"resourceType":"ValueSet","url":"http://hl7.org/fhir/ValueSet/administrative-gender"}}|

The answer is JSON, a FHIR ValueSet resource. Its @tt{expansion.contains} is the list: four codes,
each with the text shown to people (@tt{display}) and the code system it comes from (@tt{system}).

@bold{3. Ask whether a code is in it.} Give the value set, the code's system and the code:

@verbatim|{$ raco fhir-tx validate-code http://hl7.org/fhir/ValueSet/administrative-gender http://hl7.org/fhir/administrative-gender female
{"parameter":[{"name":"result","valueBoolean":true},{"name":"code","valueCode":"female"},{"name":"system","valueUri":"http://hl7.org/fhir/administrative-gender"},{"name":"display","valueString":"Female"}],"resourceType":"Parameters"}}|

This answer is a FHIR @italic{Parameters} resource, a list of named values. The one to read is
@tt{result}: true.

@bold{4. Make a mistake.} Ask about @tt{femme}:

@verbatim|{$ raco fhir-tx validate-code http://hl7.org/fhir/ValueSet/administrative-gender http://hl7.org/fhir/administrative-gender femme
{"parameter":[{"name":"result","valueBoolean":false},{"name":"code","valueCode":"femme"},{"name":"system","valueUri":"http://hl7.org/fhir/administrative-gender"},{"name":"message","valueString":"Unknown code 'femme' in the CodeSystem 'http://hl7.org/fhir/administrative-gender'"}],"resourceType":"Parameters"}}|

@tt{result} is false, and @tt{message} says why. Note that the command itself succeeded: "no" is an
answer, not a failure, so the exit code is 0.

@section[#:tag "ideas"]{Codes, code systems and value sets}

Three ideas carry everything on this page.

A @bold{code system} is a list of codes with their meanings, kept by one organisation. LOINC lists
laboratory tests and measurements, SNOMED CT clinical findings and procedures, ICD-10 diagnoses.
FHIR has many small ones of its own, such as the four administrative genders. A code system is
named by an address, like @tt{http://loinc.org} or @tt{http://hl7.org/fhir/administrative-gender}.

A @bold{code} only means something together with its system: @tt{female} in
@tt{http://hl7.org/fhir/administrative-gender}, @tt{4548-4} in @tt{http://loinc.org} (an HbA1c
test). A code and its system written together are a @italic{coding}. Each code has a
@italic{display}, the words shown to a person.

A @bold{value set} is a selection of codes for one purpose: "the codes allowed for a patient's
gender", "the codes that mean a blood-pressure reading". It can draw from one code system or
several, and it is defined in one of two ways:

@itemlist[
@item{@bold{by listing} its codes one by one; or}
@item{@bold{by a rule} over a code system: "every code in this system", "this code and everything
beneath it", "the codes whose property X is Y".}]

The difference matters here. To turn a list into its members, the service needs only the value set.
To turn a rule into its members, it needs the whole code system the rule is about
(@secref["offline"]).

One more: a @bold{concept map} says which code in one system corresponds to which in another, for
moving data between systems.

Code systems, value sets and concept maps are themselves FHIR resources (CodeSystem, ValueSet,
ConceptMap), published inside @italic{packages}: the FHIR specification is one package, each
Implementation Guide another. Those packages are what the service reads (@secref["packages"]).

@section[#:tag "questions"]{The questions it answers}

FHIR calls each kind of question an @italic{operation} and writes its name with a dollar sign. Each
has a command of the same name.

@subsection[#:tag "expand"]{Which codes are in this value set? (@tt{$expand})}

@tt{raco fhir-tx expand <value set>} lists the members, as in the first example. Listing a value
set's members is called @italic{expanding} it, and the list is its @italic{expansion}.

Large value sets are read in parts. @litchar{--filter} keeps the members whose code or display
contains a text (in any letter case); @litchar{--count} and @litchar{--offset} take a page of them.
@tt{total} counts every member that passed the filter, not just the page:

@verbatim|{$ raco fhir-tx expand http://hl7.org/fhir/ValueSet/administrative-gender --filter fem
{"expansion":{"contains":[{"code":"female","display":"Female","system":"http://hl7.org/fhir/administrative-gender","version":"5.0.0"}],"total":1},"resourceType":"ValueSet","url":"http://hl7.org/fhir/ValueSet/administrative-gender"}}|

@subsection[#:tag "validate-code"]{Is this code in it? (@tt{$validate-code})}

@tt{raco fhir-tx validate-code <value set> <system> <code>} answers true or false in @tt{result},
with the code's display when it is found and a @tt{message} when it is not.

It can check the display too. Systems often send a code with the wrong words beside it, which is a
sign the wrong code was picked. @litchar{--display} gives the words you have:

@verbatim|{$ raco fhir-tx validate-code http://hl7.org/fhir/ValueSet/administrative-gender http://hl7.org/fhir/administrative-gender female --display Woman
{"parameter":[{"name":"result","valueBoolean":false},{"name":"code","valueCode":"female"},{"name":"system","valueUri":"http://hl7.org/fhir/administrative-gender"},{"name":"display","valueString":"Female"},{"name":"message","valueString":"Wrong Display Name 'Woman', should be 'Female'"}],"resourceType":"Parameters"}}|

@subsection[#:tag "lookup"]{What does this code mean? (@tt{$lookup})}

@tt{raco fhir-tx lookup <system> <code>} gives what the code system says about one code. Here the
code is @tt{required}, one of the kinds of problem a FHIR validator reports:

@verbatim|{$ raco fhir-tx lookup http://hl7.org/fhir/issue-type required
{"parameter":[{"name":"name","valueString":"IssueType"},{"name":"version","valueString":"5.0.0"},{"name":"display","valueString":"Required element missing"},{"name":"definition","valueString":"A required element is missing."}],"resourceType":"Parameters"}}|

@tt{name} and @tt{version} are the code system's; @tt{display} and @tt{definition} are the code's.
A code the system does not have comes back with the system's name and version and no display.

@subsection[#:tag "translate"]{What is this code in another system? (@tt{$translate})}

@tt{raco fhir-tx translate <concept map> <code>} sends a code through a concept map. FHIR ships a
map from its gender codes to the ones the older HL7 version 2 messages use:

@verbatim|{$ raco fhir-tx translate http://hl7.org/fhir/ConceptMap/cm-administrative-gender-v2 female
{"parameter":[{"name":"result","valueBoolean":true},{"name":"match","part":[{"name":"relationship","valueCode":"equivalent"},{"name":"concept","valueCoding":{"code":"F","system":"http://terminology.hl7.org/CodeSystem/v2-0001"}}]}],"resourceType":"Parameters"}}|

Each @tt{match} is a target code and how good the match is: @tt{equivalent} here. A code can have
several matches, or a looser one: the same map sends @tt{other} to two version 2 codes, each marked
@tt{source-is-broader-than-target}. A code the map does not mention answers @tt{result} false.
@litchar{--system} names the source code's system when the map has groups for several.

@subsection[#:tag "subsumes"]{Is this code a kind of that one? (@tt{$subsumes})}

Many code systems are trees: a broad code with narrower ones beneath it. FHIR's issue types are
one: @tt{invalid} has @tt{structure}, @tt{required}, @tt{value} and @tt{invariant} under it.
@tt{raco fhir-tx subsumes <system> <codeA> <codeB>} says how two codes stand:

@verbatim|{$ raco fhir-tx subsumes http://hl7.org/fhir/issue-type invalid required
{"parameter":[{"name":"outcome","valueCode":"subsumes"}],"resourceType":"Parameters"}}|

@tt{subsumes} means the first is the broader one. The other answers are @tt{subsumed-by} (the first
is the narrower), @tt{equivalent} and @tt{not-subsumed} (neither contains the other). Here a code
the system does not have is an error, with exit code 1:

@verbatim{
$ raco fhir-tx subsumes http://hl7.org/fhir/issue-type required nosuch
fhir-tx: subsumes: unknown code nosuch in http://hl7.org/fhir/issue-type
}

@section[#:tag "packages"]{Which packages it reads}

The service knows the code systems, value sets and concept maps in the packages it is given, and
nothing else. With no option that is the FHIR R5 specification. @litchar{--package} names another
package, and can be repeated; the packages are searched in the order given.

An Implementation Guide's value sets usually draw on code systems from the FHIR version the guide
is written for, so name both: the guide, then its core package. US Core 6.1.0 is written for R4:

@verbatim|{$ raco fhir-tx expand http://hl7.org/fhir/us/core/ValueSet/us-core-screening-assessment-observation-category \
    --package hl7.fhir.us.core-6.1.0.tgz --package hl7.fhir.r4.core.tgz
{"expansion":{"contains":[{"code":"sdoh","display":"SDOH","system":"http://hl7.org/fhir/us/core/CodeSystem/us-core-category","version":"6.1.0"},{"code":"functional-status","display":"Functional Status", …},{"code":"disability-status","display":"Disability Status", …},{"code":"cognitive-status","display":"Cognitive Status", …}],"total":4},"resourceType":"ValueSet","url":"http://hl7.org/fhir/us/core/ValueSet/us-core-screening-assessment-observation-category"}}|

A package is named by the path of its @tt{.tgz} file, or by the file name of one that comes with
the tools (with or without @tt{.tgz}). Those are the core specification
(@tt{hl7.fhir.r4.core}, @tt{hl7.fhir.r5.core}, @tt{hl7.fhir.r6.core}), US Core
(@tt{hl7.fhir.us.core-6.1.0}, @tt{hl7.fhir.us.core-8.0.0}, and @tt{hl7.fhir.us.core}, which is
9.0.0), the International Patient Summary (@tt{hl7.fhir.uv.ips}), mCODE
(@tt{hl7.fhir.us.mcode-4.0.0}), CQF Measures (@tt{hl7.fhir.us.cqfmeasures-5.0.0}), CRMI
(@tt{hl7.fhir.uv.crmi-2.0.0}) and Genomics Reporting (@tt{hl7.fhir.uv.genomics-reporting-2.0.0}).
Other packages are downloaded from @hyperlink["https://packages.fhir.org"]{packages.fhir.org}; a
directory named in the environment variable @tt{FHIR_PACKAGE_PATH} is searched for them by name
too.

@section[#:tag "offline"]{What it cannot answer offline}

The big clinical code systems are not in any FHIR package. SNOMED CT, LOINC, RxNorm, ICD-10 and CPT
are large, separately licensed, and distributed by their owners. This service does not ship them
and does not call out to a server that has them. So it knows that @tt{http://loinc.org} is a code
system, but not what is in it. That has three consequences. The service marks each of them in its
answer, so you can tell "no" from "cannot say".

@bold{A value set that lists such codes works, without displays.} Membership needs only the list.
US Core's vital signs are LOINC codes written out one by one:

@verbatim|{$ raco fhir-tx expand http://hl7.org/fhir/us/core/ValueSet/us-core-vital-signs \
    --package hl7.fhir.us.core-6.1.0.tgz --package hl7.fhir.r4.core.tgz --count 3
{"expansion":{"contains":[{"code":"59576-9","system":"http://loinc.org"},{"code":"8289-1","system":"http://loinc.org"},{"code":"77606-2","system":"http://loinc.org"}],"total":19},"resourceType":"ValueSet","url":"http://hl7.org/fhir/us/core/ValueSet/us-core-vital-signs"}}|

The codes are there and @tt{validate-code} answers correctly for them. There is no @tt{display},
because the words live in LOINC.

@bold{A value set defined by a rule over such a system comes back short or empty.} US Core's
condition codes are one listed SNOMED CT code plus three rules of the form "this SNOMED CT code and
everything beneath it".
(It also takes all of ICD-10-CM and ICD-9-CM, which are not shipped either.) The expansion holds the
one listed code, and says that this is not every code:

@verbatim|{$ raco fhir-tx expand http://hl7.org/fhir/us/core/ValueSet/us-core-condition-code \
    --package hl7.fhir.us.core-6.1.0.tgz --package hl7.fhir.r4.core.tgz
fhir-tx: not every code is listed: the value set selects from http://snomed.info/sct,
  http://hl7.org/fhir/sid/icd-10-cm, http://hl7.org/fhir/sid/icd-9-cm by rule, and that content
  is not in the packages (the expansion is marked valueset-unclosed)
{"expansion":{"contains":[{"code":"160245001","system":"http://snomed.info/sct"}],
  "extension":[{"url":"http://hl7.org/fhir/StructureDefinition/valueset-unclosed","valueBoolean":true}],
  "total":1},"resourceType":"ValueSet","url":"http://hl7.org/fhir/us/core/ValueSet/us-core-condition-code"}}|

(Both the note and the JSON are one line each; they are wrapped here.) The note goes to standard
error. The mark in the answer itself is FHIR's own @tt{valueset-unclosed} extension on the
expansion, which a program can test for.

For the same reason, a SNOMED CT code that the rules do include (type 2 diabetes, @tt{44054006},
for one) cannot be confirmed. @tt{validate-code} answers @tt{result} false, as the operation must
answer true or false, and says why in two more parameters:

@verbatim|{$ raco fhir-tx validate-code http://hl7.org/fhir/us/core/ValueSet/us-core-condition-code \
    http://snomed.info/sct 44054006 --package hl7.fhir.us.core-6.1.0.tgz --package hl7.fhir.r4.core.tgz
{"parameter":[{"name":"result","valueBoolean":false},{"name":"code","valueCode":"44054006"},
  {"name":"system","valueUri":"http://snomed.info/sct"},
  {"name":"message","valueString":"Whether '44054006' is in the value set cannot be decided here:
     the value set selects from http://snomed.info/sct by rule, and that code system's content is
     not in the packages"},
  {"name":"x-caused-by-unknown-system","valueCanonical":"http://snomed.info/sct"}],
 "resourceType":"Parameters"}}|

@tt{x-caused-by-unknown-system} is the parameter the reference terminology server uses for the
same situation: read a false that carries it as "cannot say", not as "not allowed". A code of a
system that @italic{is} at hand gets a plain true or false.

@bold{Questions about the system itself are refused.} @tt{lookup} and @tt{subsumes} on a system
whose content is not there say so and exit with 1:

@verbatim{
$ raco fhir-tx lookup http://loinc.org 4548-4
fhir-tx: no CodeSystem http://loinc.org in the R5 core package (name others with --package)
}

The family's validator reads these marks: when it checks a resource's codes through this service
and the value set rests on a system that is not there, it reports nothing rather than call the code
invalid (@hyperlink["../fhir-validation/index.html"]{fhir-validation}).

A misspelt address is an error too, on the command line as over HTTP, not an empty answer:

@verbatim{
$ raco fhir-tx expand http://example.org/ValueSet/nope
fhir-tx: no ValueSet http://example.org/ValueSet/nope in the R5 core package (name others with --package)
}

@section[#:tag "serve"]{Serving it over HTTP}

Other software asks a terminology service its questions over the web, in the way FHIR lays down.
One command starts such a server:

@verbatim{
$ raco fhir-tx serve --port 8080
terminology server on http://localhost:8080  (GET /metadata, /metadata?mode=terminology; Ctrl-C, or kill 8987, to stop)
}

It serves the R5 specification's terminology unless you give @litchar{--package}s, as above. The
port is 8080 unless you say otherwise. Ask it something from another terminal, here with
@tt{curl}. The address has the kind of resource, then the operation; the inputs follow the
question mark:

@verbatim|{$ curl 'http://localhost:8080/ValueSet/$expand?url=http://hl7.org/fhir/ValueSet/administrative-gender&filter=fem'
{"resourceType":"ValueSet","url":"http://hl7.org/fhir/ValueSet/administrative-gender","expansion":{"total":1,"contains":[{"system":"http://hl7.org/fhir/administrative-gender","version":"5.0.0","code":"female","display":"Female"}]}}

$ curl 'http://localhost:8080/ValueSet/$validate-code?url=http://hl7.org/fhir/ValueSet/administrative-gender&code=female'
{"resourceType":"Parameters","parameter":[{"name":"result","valueBoolean":true},{"name":"code","valueCode":"female"},{"name":"display","valueString":"Female"}]}

$ curl 'http://localhost:8080/CodeSystem/$lookup?system=http://hl7.org/fhir/issue-type&code=required'
{"resourceType":"Parameters","parameter":[{"name":"name","valueString":"IssueType"},{"name":"version","valueString":"5.0.0"},{"name":"display","valueString":"Required element missing"},{"name":"definition","valueString":"A required element is missing."}]}

$ curl 'http://localhost:8080/ConceptMap/$translate?url=http://hl7.org/fhir/ConceptMap/cm-administrative-gender-v2&sourceCode=female'
{"resourceType":"Parameters","parameter":[{"name":"result","valueBoolean":true},{"name":"match","part":[{"name":"relationship","valueCode":"equivalent"},{"name":"concept","valueCoding":{"system":"http://terminology.hl7.org/CodeSystem/v2-0001","code":"F"}}]}]}}|

The whole list of what is served:

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{address} @bold{question})
      (list @tt{/ValueSet/$expand} "which codes are in the value set")
      (list @tt{/ValueSet/$validate-code} "is the code in the value set")
      (list @tt{/CodeSystem/$validate-code} "is the code in the code system")
      (list @tt{/CodeSystem/$lookup} "what the code means")
      (list @tt{/CodeSystem/$subsumes} "how two codes stand in the hierarchy")
      (list @tt{/CodeSystem/$find-matches} "the codes with given properties")
      (list @tt{/ConceptMap/$translate} "the code in another system")
      (list @tt{/$closure} "a running table of how the codes a client has sent relate")
      (list @tt{/metadata} "the server's CapabilityStatement: what it supports")
      (list @tt{/metadata?mode=terminology} "its TerminologyCapabilities: the code systems it holds")
      (list @tt{/OperationDefinition} "the formal definition of each operation"))]

Inputs can also be sent as a Parameters resource in a POST, which is how a Coding or a whole value
set is passed:

@verbatim|{$ curl -X POST -H 'Content-Type: application/fhir+json' 'http://localhost:8080/ValueSet/$validate-code' -d '
{"resourceType": "Parameters", "parameter": [
  {"name": "url", "valueUri": "http://hl7.org/fhir/ValueSet/administrative-gender"},
  {"name": "coding", "valueCoding": {"system": "http://hl7.org/fhir/administrative-gender", "code": "female"}}]}'
{"resourceType":"Parameters","parameter":[{"name":"result","valueBoolean":true},{"name":"code","valueCode":"female"},{"name":"system","valueUri":"http://hl7.org/fhir/administrative-gender"},{"name":"display","valueString":"Female"}]}}|

A question that cannot be answered gets an OperationOutcome, FHIR's report of a problem, and an HTTP
error status. An unknown value set is 404:

@verbatim|{$ curl 'http://localhost:8080/ValueSet/$expand?url=http://example.org/nope'
{"resourceType":"OperationOutcome","issue":[{"severity":"error","code":"not-found","diagnostics":"$expand: ValueSet http://example.org/nope is not in the data source or the packages"}]}}|

@litchar{--url} sets the address the server gives as its own in its CapabilityStatement, for when
it is reached through another name than @tt{localhost}. Serving needs the
@hyperlink["../fhir-server/index.html"]{fhir-server} package, which is installed with the rest. A
server generated from an Implementation Guide by @tt{raco fhir-server serve-ig} serves @tt{$expand}
as well when the guide asks for it, over the value sets it stores and the guide's packages.

The line the server prints when it is ready ends with its process id (@tt{Ctrl-C, or kill 8987, to
stop}), and is written at once, to a terminal or to a file: a script that started the server in the
background can wait for that line, then stop the server by the id.

@section[#:tag "program"]{From a program}

@subsection{As operations}

In a Racket program each operation is a function, and its inputs are keyword arguments with the
names FHIR gives them. The answers are the same FHIR JSON as on the command line, as hash tables.

@racketblock[
(require fhir/terminology/operations)
(define gender "http://hl7.org/fhir/ValueSet/administrative-gender")

($expand #:url gender)                                       (code:comment "the ValueSet with its expansion")
($expand #:url gender #:filter "fem")
($validate-code #:url gender #:system "http://hl7.org/fhir/administrative-gender" #:code "female")
($lookup #:system "http://hl7.org/fhir/issue-type" #:code "required")
($subsumes #:system "http://hl7.org/fhir/issue-type" #:codeA "invalid" #:codeB "required")
($translate #:url "http://hl7.org/fhir/ConceptMap/cm-administrative-gender-v2" #:sourceCode "female")
]

A value set does not have to be published anywhere. Give one you hold, as the first argument or as
@racket[#:valueSet]:

@racketblock[
(define binary
  (hasheq 'resourceType "ValueSet" 'url "http://example.org/ValueSet/binary"
          'compose (hasheq 'include
                           (list (hasheq 'system "http://hl7.org/fhir/administrative-gender"
                                         'concept (list (hasheq 'code "female") (hasheq 'code "male")))))))
($expand binary)                                             (code:comment "female, male")
($validate-code binary #:system "http://hl7.org/fhir/administrative-gender" #:code "other")
(code:comment "result false: The code 'other' is not in the value set")
]

@bold{Where definitions are looked for.} A value set, code system or concept map named by its
address is looked for, in this order: in the inputs of the call; among the resources of
@racket[current-data-source] (data you hold: a folder, a Bundle, a server's store); among the
definitions that Racket modules in the family's languages have registered (a @tt{#lang vcl} value
set, a @tt{#lang fsh} code system, once the file is required); in the packages of
@racket[current-sd-packages], which with nothing set is the R5 core.

@racketblock[
(require fhir/sd/sd-index fhir/spec-package)
(parameterize ([current-sd-packages (list (spec-package-path "hl7.fhir.us.core-6.1.0.tgz")
                                          (spec-package-path "hl7.fhir.r4.core.tgz"))])
  ($expand #:url "http://hl7.org/fhir/us/core/ValueSet/us-core-screening-assessment-observation-category"))
]

A value set that is found nowhere raises @racket[exn:fail:operation]:
@tt{$expand: ValueSet http://example.org/nope is not in the data source or the packages}.

@bold{A value set written in the address.} The
@hyperlink["https://oloveluck.github.io/vcl/"]{ValueSet Compose Language} (VCL) writes a value set
as one short expression, and FHIR lets that expression stand in an address. The service expands
such an address with no value set stored anywhere:

@racketblock[
($expand #:url "http://fhir.org/VCL?v1=(http://hl7.org/fhir/administrative-gender)(male;female)")
(code:comment "male, female")
]

@subsection{Without the operations: resolvers}

Under the operations are plain functions over a @italic{resolver}: a function from an address (and
optionally a version) to the resource it names, or @racket[#f]. You make one from packages or from
resources, and pass it to the function for each question. This is the level to use when you do not
want the operation machinery, or when you hand the service to something else.

@racketblock[
(require fhir/terminology/service fhir/spec-package)
(define r (packages->resolver (list (spec-package-path "hl7.fhir.us.core-6.1.0.tgz")
                                    (spec-package-path "hl7.fhir.r4.core.tgz"))))
(expand/json r "http://hl7.org/fhir/us/core/ValueSet/us-core-vital-signs" #f (hash "count" 2))
(validate-code/json r "http://hl7.org/fhir/ValueSet/administrative-gender" "female"
                    "http://hl7.org/fhir/administrative-gender")
(lookup/json r "http://hl7.org/fhir/administrative-gender" "female")
]

@subsection{In FHIRPath, and for the validator}

@racket[make-terminology/resolver] wraps a resolver as the service handle two other parts of the
family take. @hyperlink["https://oloveluck.github.io/fhirpath/"]{FHIRPath} expressions reach it as
@tt{%terminologies}; here an expression asks whether a patient's gender is in the value set:

@racketblock[
(require fhirpath/eval fhirpath/parser/parse fhir/r4/schemas)
(define tx (make-terminology/resolver r))
(code:comment "patient: a Patient read with from-json (fhir/serialize/from-json)")
(eval-fhirpath
 (parse-fhirpath "%terminologies.validateVS('http://hl7.org/fhir/ValueSet/administrative-gender', gender).parameter.where(name = 'result').value")
 (list patient)
 #:externals (hash "terminologies" (list tx)))
(code:comment "=> true, for a patient whose gender is female")
]

The @hyperlink["../fhir-validation/index.html"]{validator} takes the same handle as
@racket[#:terminology], to check a resource's codes against value sets it could not otherwise list.

@section[#:tag "where"]{Where codes are checked in the family}

Codes are checked at three moments, by three mechanisms, and it helps to know which one you are
relying on.

@itemlist[
@item{@bold{When a resource is written as a program.} The Racket forms for FHIR resources
(@tt{fhir/r6} and the others) refuse a literal code outside its set when the file compiles. The
sets were worked out when the forms were generated: every required binding whose value set lists
its codes or takes a whole code system from the same package (202 value sets in R6). Value sets
with rules, imports or exclusions are left unchecked there.}
@item{@bold{When a resource is validated.} The validator checks required bindings through this
service when it is given one, else against those same built-in sets. Only the @tt{$validate}
operation builds a service for itself; @tt{raco fhir-validate}, the generated servers and
@tt{raco fsh check} use the built-in sets.}
@item{@bold{When you ask}, by this service: over packages or resources, as commands, as operations,
as FHIRPath's @tt{expand()}, @tt{validateVS()} and @tt{translate()}, over HTTP, and for VCL
addresses.}]

The languages use it differently. CQL takes value set expansions as data and does not call the
service. FHIR Shorthand records which value set an element is bound to and validates no codes
itself. The mapping language's @tt{translate} asks the service for a concept map the map file does
not contain.

@section[#:tag "cli"]{Command reference}

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @tt{raco fhir-tx expand <ValueSet url> [--filter t] [--count n] [--offset n]} "the value set's members")
      (list @tt{raco fhir-tx validate-code <ValueSet url> <system> <code> [--display t]} "is the code in the set")
      (list @tt{raco fhir-tx lookup <system> <code>} "what a code means")
      (list @tt{raco fhir-tx translate <ConceptMap url> <code> [--system s]} "a code through a map")
      (list @tt{raco fhir-tx subsumes <system> <codeA> <codeB>} "how two codes stand in the hierarchy")
      (list @tt{raco fhir-tx serve [--port n] [--url base]} "every operation over HTTP")
      (list @tt{raco fhir-tx tck [-v]} "run the conformance suite (see below)"))]

Every command but @tt{tck} takes @litchar{--package <tgz|name>}, repeatable, searched in order;
with none, the R5 core. The answer is the operation's FHIR JSON on standard output. Exit codes: 0
when the question was answered (whatever the answer), 1 when it could not be or the suite fell
below its floor, 2 when the command was called wrongly. @tt{raco fhir-tx <command> --help} prints a
command's usage.

@section[#:tag "limits"]{Limits}

@itemlist[
@item{@bold{External code systems.} SNOMED CT, LOINC, RxNorm and the like are not shipped and not
fetched. What follows from that, and how the answers are marked, is in @secref["offline"].}
@item{@bold{@tt{$expand}} takes @tt{filter}, @tt{count}, @tt{offset}, @tt{activeOnly},
@tt{excludeNested}, @tt{displayLanguage}, @tt{includeDesignations}, @tt{property} and
@tt{useSupplement}. It does not take @tt{includeDefinition}, @tt{excludeNotForUI} or @tt{limit},
and does not flag members as @tt{abstract} or @tt{inactive}. @tt{displayLanguage} matches a
language tag exactly.}
@item{@bold{@tt{$translate}} goes forward only, from a source code and system. It does not
translate towards a given target, and ignores a map's @tt{dependsOn} and @tt{unmapped} parts and
its version.}
@item{@bold{Hierarchy} is read from codes nested inside one another in the CodeSystem resource, not
from @tt{parent} or @tt{subsumedBy} properties.}
@item{@bold{Versions.} When several versions of a code system or value set are at hand and none is
asked for, the highest is taken, comparing the version texts as strings.}
@item{@bold{Supplements} to a code system apply only when a request names them with
@tt{useSupplement}; none is found by itself.}
@item{@bold{@tt{$find-matches}} matches properties exactly or by substring; it has no grammar for
composed expressions.}
@item{@bold{@tt{$closure}} tables live in the running process and are gone when it stops.}
@item{@bold{FHIRPath's @tt{%terminologies}} offers @tt{expand()} (with a Parameters argument),
@tt{validateVS()} and @tt{translate()} (a code, a Coding or a CodeableConcept, and a system). It has
no @tt{lookup()}, @tt{subsumes()} or @tt{validateCS()}.}]

@section[#:tag "words"]{Words used here}

@itemlist[
@item{@bold{Code}: a short identifier with an agreed meaning. @bold{Display}: the words shown for
it.}
@item{@bold{Code system}: a list of codes and their meanings, named by an address (LOINC, SNOMED
CT, FHIR's own small lists). As a resource, a CodeSystem.}
@item{@bold{Coding}: a code together with its system. @bold{CodeableConcept}: one idea written as
one or more codings and optional text.}
@item{@bold{Value set}: a selection of codes for one purpose, listed or defined by a rule. As a
resource, a ValueSet; its definition is its @italic{compose}.}
@item{@bold{Expansion}: the list of codes a value set comes to. To @bold{expand} is to work it out.}
@item{@bold{Concept map}: a table from the codes of one system to those of another (a ConceptMap).}
@item{@bold{Binding}: the statement, in FHIR or a profile, that an element's code comes from a
value set. A @italic{required} binding allows no other code.}
@item{@bold{Subsumes}: "is broader than and includes", between two codes of a hierarchy.}
@item{@bold{Operation}: a named service FHIR defines, written with a dollar sign (@tt{$expand}).}
@item{@bold{Parameters}: the FHIR resource that carries an operation's named inputs or outputs.
@bold{OperationOutcome}: the one that reports a problem.}
@item{@bold{Canonical url}: the web address that names a value set, code system or concept map. It
is a name; nothing needs to be served there.}
@item{@bold{Package}: the @tt{.tgz} file an Implementation Guide or the FHIR specification is
distributed as.}
@item{@bold{CapabilityStatement}, @bold{TerminologyCapabilities}: a server's own description of
what it supports and of the code systems it holds.}
@item{@bold{VCL}: the ValueSet Compose Language, a one-line way to write a value set.}
@item{@bold{Resolver}: in the programming interface, the function that finds a resource by its
address.}]

@section[#:tag "tested"]{How it is tested}

HL7 publishes a conformance suite for terminology servers,
@tt{hl7.fhir.uv.tx-ecosystem} (version 1.9.3 here): requests with the responses a correct server
gives. @tt{raco fhir-tx tck} runs it:

@verbatim{
$ raco fhir-tx tck
terminology conformance: 473/553  (skipped 367: external terminologies, value sets
  resting on code systems we cannot see, operations and parameters not implemented)
}

473 of the 553 cases it attempts give the expected response. The 367 skipped are the ones no
offline service can answer (they need SNOMED CT, LOINC and other systems that are not shipped) and
operations and parameters that are not implemented (@secref["limits"]); they are counted, not hidden. The
number is a floor: the command fails if it drops. @litchar{-v} lists each failing case. The
repository's @hyperlink["https://github.com/oloveluck/fhir/blob/main/TESTING.md"]{@tt{TESTING.md}}
has the other suites.

@section{Reference}

@subsection[#:style 'unnumbered]{@tt{fhir/terminology/service}}
@defmodule[fhir/terminology/service]

A terminology server as a value. Expansion follows @tt{compose} (includes, excludes, filters over
the code system's concepts and properties, nested value sets, version pins including @tt{1.x.x}
patterns, a pre-expanded value set, implicit VCL urls) with the expansion parameters (offset, count,
activeOnly, filter, displayLanguage, includeDesignations, property). Validation takes a code, a
Coding or a CodeableConcept, checks displays against designations, and honours system and value set
versions. Rules over a code system the service does not have (SNOMED, LOINC) select nothing.

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
@defproc[(resources->resolver [resources (listof hash?)]) procedure?])]{
A resolver over packages, searched in order, or over resources in hand.}
@deftogether[(
@defproc[(expand/json [resolver procedure?] [url string?] [version (or/c string? #f) #f] [params hash? (hash)] [policy version-policy? no-version-policy]) hash?]
@defproc[(validate-code/json [resolver procedure?] [url string?] [code (or/c string? #f) #f] [system (or/c string? #f) #f]
                             [#:coding coding any/c #f] [#:codeable-concept concept any/c #f] [#:display display any/c #f]
                             [#:lenient-display? lenient? boolean? #f] [#:system-version system-version any/c #f]
                             [#:valueset-version valueset-version any/c #f] [#:policy policy version-policy? no-version-policy]) hash?]
@defproc[(lookup/json [resolver procedure?] [system string?] [code string?] [version (or/c string? #f) #f]) hash?]
@defproc[(translate/json [resolver procedure?] [url string?] [code string?] [system (or/c string? #f) #f]) hash?])]{
The operations over a resolver, answering a ValueSet or Parameters jsexpr; they need no tower.
@racket[params] keys are the expansion parameter names as strings. A url the resolver does not have
expands to no members.}
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
the test for a ValueSet that would need a code system the service lacks (what the conformance
harness skips by).}
@defproc[(implicit-vcl-valueset [url string?]) (or/c hash? #f)]{The ValueSet an implicit VCL url
(@tt{http://fhir.org/VCL?v1=<expression>}) stands for, else @racket[#f].}

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
The eight as @tt{fhir/operation} values on the core OperationDefinitions, registered when the module
loads. A ValueSet is the subject, @tt{#:valueSet}, or named by @tt{#:url}; the inputs are the
definitions' parameters (@racket[($translate cm #:sourceCode "a" #:system url)]). Resources are
looked up in the inputs, then @racket[current-data-source], then the registered definitions, then
@racket[current-sd-packages]; a ValueSet found nowhere is an @racket[exn:fail:operation].}
@defproc[(current-terminology-resolver [extra (listof hash?) '()]) procedure?]{The resolver the operations use: @racket[extra], then the data source (asked by url when it searches, as a store does), then the registered definitions, then the packages, then an implicit VCL url.}
@defthing[terminology-operations (listof procedure?)]{All eight, in the order a server lists them.}
@defproc[(current-terminology-capabilities [#:url url (or/c string? #f) #f]) hash?]{A TerminologyCapabilities over the code systems in @racket[current-sd-packages].}
