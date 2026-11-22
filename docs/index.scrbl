#lang scribble/manual

@; tt : code inside a sentence, exactly as typed (scribble's own tt would turn -- into a dash and
@; 'x' into curly quotes)
@(require (only-in scribble/core element))
@(define (tt . text) (element 'tt text))

@title{fhir: a toolkit for AI agents on FHIR}

@hyperlink["https://hl7.org/fhir/"]{FHIR} is the standard most health systems use to exchange data:
a patient, a lab result, a prescription are each a small document called a @italic{resource}. The
standard also defines several small languages for working with those resources. This project
implements them all, with a validator, a terminology service, a store and servers around them,
built so that an AI agent can do real work with health data and you can check what it did: the
agent writes a file in one of the languages, a tool checks it and says exactly where any mistake
is, and then it runs over real data.

You do not need to know Racket (the language this is written in) to use it. Each language has a
command-line tool, and there is one server, @tt{fhir-mcp}, that an agent works through. Everything
here works for a person at a terminal too.

@table-of-contents[]

@section{Why it suits an agent}

An agent pays for every word it reads and writes, makes fewer mistakes the less it has to write,
and needs to be told plainly when it is wrong. Four choices follow from that.

@itemlist[
@item{@bold{Languages, not JSON.} A FHIR resource is JSON, and the definitions FHIR works with
(a profile, a value set, a map, a library of logic) are long JSON documents. Each of FHIR's
languages is a shorter way to say one of them, and the tools compile the language to the JSON. So
the agent reads and writes the language. Counted in a model's own tokens over published material:
a CQL library is 13% of the JSON it compiles to, a value set written in VCL 28%, a map 52%.}
@item{@bold{Say only what changes.} A stored resource is changed by the rules that change it, not
by sending the whole resource back: 26 tokens in a test of sixty changes where the resource as
JSON was 535, with the same result every time.}
@item{@bold{The data as tables.} A patient's facts are spread over many resources, and most
questions are about a table: the latest result per patient, the stays of a year. The agent defines
the tables once over the stored data (a SQL on FHIR view for each kind of resource, a @tt{.sql}
file for a join) and a question is then one SQL statement. A table can keep, in a column, the
resource each row came from, so an answer can still be traced to the record. The
@hyperlink["fhir-mcp/index.html"]{fhir-mcp} page shows one.}
@item{@bold{Checked before it is written, traced after.} Nothing reaches the data without being
validated against FHIR and against your own rules, and every write records who made it, when, why
and from which line of which text. A mistake comes back as one line, at its place, saying what was
found and what would fix it.}]

Measured with Claude Sonnet on two benchmarks other people published, graded by their own
graders, against the same data served as plain FHIR REST calls. On MedAgentBench (300 clinical
tasks): 300 right at 6 thousand tokens a task, where an agent making REST calls got 294 right at
38 thousand. On FHIR-AgentBench (questions about a hospital's records): 147 of 150 right at 10
thousand tokens a question, against 109 at 69 thousand; over its whole test split of 409
questions, asked three times, 402 are marked right each time, and every question whose recorded
answer can be held to is right every time.

How those numbers were reached says what matters. Through the workspace's nine tools from a
shell, the same agent got 300 of MedAgentBench's tasks right at 41 thousand tokens and 122 of the
150 questions at 57 thousand: more right answers than REST, for tokens of the same order. The
tokens went when the agent was given the few actions a task needs as the tools of one process, and
a prompt holding only what its first step uses. The answers came when the benchmark's own
relational schema was defined over the FHIR store by an agent, as views, and its questions were
answered in SQL beside an example query of the same kind from the benchmark's training questions
(the REST agents, run in an earlier round, had the data alone).

And asked to write 24 published profiles from their stated requirements, a model got
1427 of 1431 constraints right in FHIR Shorthand at half the tokens of the JSON. The harnesses, the
runs and every miss are in @hyperlink["https://github.com/oloveluck/fhir-examples"]{fhir-examples}.

A correction, as an agent makes it (the first file was written when the reading was stored):

@verbatim|{
$ cat fix.fsh
Instance: Observation/a1c-1
* status = #amended
* valueQuantity = 9.1 '%'
* note.text = "repeat sample"
$ raco fhir-mcp call stage fsh=@fix.fsh
{"changes":[{"action":"update","changed":["note: added [{\"text\":\"repeat sample\"}]","status: \"final\" → \"amended\"","valueQuantity.value: 9.4 → 9.1"],"resource":"Observation/a1c-1"}],"errors":0,"next":"commit stage=stage-2 writes the 1 change(s) to the store fhir.db","stage":"stage-2"}
$ raco fhir-mcp call commit stage=latest reason="repeat sample" agent=Practitioner/dr-ng
$ raco fhir-mcp call describe ref=Observation/a1c-1/_history as=csv columns=versionId,agent,reason,value,at
versionId,agent,reason,value,at
2,Practitioner/dr-ng,repeat sample,9.1 %,fix.fsh:4
1,Practitioner/dr-ng,clinic intake,9.4 %,readings.fsh:15
}|

The first line of the file names the stored resource; the lines under it are what changes. The
answer to @tt{stage} says what would change and that nothing is wrong; @tt{commit} writes it; the
last command reads the resource's history back as a table. The @hyperlink["fhir-mcp/index.html"]{fhir-mcp}
page starts from an empty folder.

@section{What you can do}

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{You want to} @bold{Language} @bold{Tool and documentation})
      (list "say what valid data looks like, and write examples of it" "FHIR Shorthand" @hyperlink["https://oloveluck.github.io/fsh/"]{fsh})
      (list "compute over a patient's record: rules, cohorts, quality measures" "Clinical Quality Language (CQL)" @hyperlink["https://oloveluck.github.io/cql/"]{cql})
      (list "convert data from one shape to another" "FHIR Mapping Language" @hyperlink["https://oloveluck.github.io/fml/"]{fml})
      (list "name a set of codes" "ValueSet Compose Language (VCL)" @hyperlink["https://oloveluck.github.io/vcl/"]{vcl})
      (list "ask a question of one resource" "FHIRPath" @hyperlink["https://oloveluck.github.io/fhirpath/"]{fhirpath})
      (list "turn resources into tables you can query" "SQL on FHIR" @hyperlink["https://oloveluck.github.io/sql-on-fhir/"]{sql-on-fhir})
      (list "check that a resource is valid" "" @hyperlink["fhir-validation/index.html"]{fhir-validate})
      (list "look up codes and expand value sets" "" @hyperlink["fhir-tx/index.html"]{fhir-tx})
      (list "run a FHIR server" "" @hyperlink["fhir-server/index.html"]{fhir-server})
      (list "see mistakes in your editor as you type" "" @hyperlink["fhir-lsp/index.html"]{fhir-lsp})
      (list "let an AI agent do the work, with a record of what it did" "" @hyperlink["fhir-mcp/index.html"]{fhir-mcp}))]

Worked examples that use several of these together are in
@hyperlink["https://oloveluck.github.io/fhir-examples/"]{fhir-examples}.

@section{Install}

There are no downloads yet, so you build the tools once. You need
@hyperlink["https://racket-lang.org"]{Racket 9} to build them; the result runs without Racket on any
machine of the same kind.

@verbatim{
for r in fhir fhirpath vcl cql fml fsh sql-on-fhir; do
  git clone https://github.com/oloveluck/$r.git
done
raco pkg install --link --auto --batch --no-docs \
  fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx fhir/fhir-validation \
  cql fml fsh fhir/fhir-server fhir/fhir-lsp fhir/fhir-mcp sql-on-fhir
fhir/build-tools.sh dist
export PATH="$PWD/dist/bin:$PATH"
}

The first two commands fetch the source and install it as Racket packages; after them every tool
already works as @tt{raco <tool>} (@tt{raco fsh}, @tt{raco cql}, …). @tt{build-tools.sh} builds the
standalone tools (@tt{fsh}, @tt{cql}, …) into @tt{dist/}, about 380 MB with the HL7 packages they
read. The two forms take the same arguments; these pages write @tt{raco <tool>}.
@tt{fhir/tools-smoke-test.sh dist} then asks each of the twelve for one piece of real work, with
nothing but the tools on the path, and prints a line for each.

@tt{fhir-server} needs the system's SQLite library. A tool also looks for FHIR packages in the
directories named by the environment variable @tt{FHIR_PACKAGE_PATH}.

@section{First steps}

Pick the one closest to what you came for. Each is a few lines and takes a few minutes.

@itemlist[
@item{@bold{Check a resource.} @tt{raco fhir-validate patient.json} reads a FHIR resource and lists
what is wrong with it: a code that is not allowed, a date that is not a date, a required field left
out. See @hyperlink["fhir-validation/index.html"]{fhir-validation}.}
@item{@bold{Write a rule for your data.} A @italic{profile} says what a valid resource looks like
in your setting ("every lab result names its patient"). You write it in FHIR Shorthand, with an
example, and @tt{raco fsh check} tells you whether the example passes, pointing at the line that
does not. Start with the @hyperlink["https://oloveluck.github.io/fsh/"]{fsh} quick start.}
@item{@bold{Ask a question of patient data.} A CQL library such as "who has had an HbA1c test, and
was the latest above 9 %?" runs over a folder of patient resources. See
@hyperlink["https://oloveluck.github.io/cql/"]{cql}.}
@item{@bold{Run a server.} @tt{raco fhir-server serve-ig hl7.fhir.us.core} starts a FHIR server
that follows a published Implementation Guide: it accepts the resources the guide describes,
refuses invalid ones and answers the searches the guide requires. See
@hyperlink["fhir-server/index.html"]{fhir-server}.}
@item{@bold{Work through an AI agent.} @tt{raco fhir-mcp init my-workspace} makes a folder that
Claude (or another agent) can work in: it writes the languages, checks them, stores data and
answers questions, and every change it makes is recorded with who, when and why. See
@hyperlink["fhir-mcp/index.html"]{fhir-mcp}.}
@item{@bold{See it all together.} @tt{fhir-examples/screening} is one small program written in seven
of the languages, from an intake form to a screening result. See
@hyperlink["https://oloveluck.github.io/fhir-examples/"]{fhir-examples}.}]

@section{How the pieces fit}

@itemlist[
@item{@bold{Everything is a FHIR resource.} A profile, a value set, a map, a library of logic are
themselves FHIR resources; each language is a shorter way to write one. So what one language
produces another can use: a profile written in FHIR Shorthand checks the patient a map produced; a
CQL library reads the same records a SQL on FHIR view turns into a table.}
@item{@bold{Things find each other by address.} Every definition has a web address (its
@italic{canonical url}). When one file refers to a value set or a profile by that address, the
tools find it, whether it is in another of your files, in a published package or in a store.}
@item{@bold{Mistakes are reported where they are.} Every tool reports a problem as
@tt{file:line:column}, with the line and a marker under the place. The same report is available as
JSON or as a FHIR OperationOutcome (@litchar{--format json|outcome}), so an editor or an agent can
read it too.}
@item{@bold{FHIR's operations are ordinary functions.} FHIR names its services with a dollar sign:
@tt{$validate}, @tt{$expand}, @tt{$transform}, @tt{$evaluate-measure}. Here each is a function you
can call from a program, and the same function is what the server answers with over HTTP.}
@item{@bold{For programmers: each file is a module.} In Racket, a file in one of the languages can
be required like any other module: @racket[(require "profile.fsh")] gives its compiled resources,
@racket[(require "screening.cql")] a function over a patient's data. A mistake in the file stops
the build, at its line. The @hyperlink["fhir/index.html"]{fhir} page has the details.}]

@section{The packages in this repository}

Each language lives in a repository of its own (the links in the table above). This repository
holds what they share and the tools around them.

@itemlist[
@item{@hyperlink["fhir/index.html"]{fhir}: the foundation. FHIR resources read, checked and written
as JSON, for FHIR versions R4, R5 and R6; the machinery the other packages build on. @tt{raco fhir}.}
@item{@tt{fhir-spec}: the HL7 packages the tools read (the FHIR specification itself and the
Implementation Guides the tests use). Data only.}
@item{@hyperlink["fhir-validation/index.html"]{fhir-validation}: the validator. @tt{raco fhir-validate}.}
@item{@hyperlink["fhir-tx/index.html"]{fhir-tx}: the terminology service: which codes a value set
holds, whether a code is in it, what a code means. @tt{raco fhir-tx}.}
@item{@hyperlink["fhir-server/index.html"]{fhir-server}: FHIR servers, generated from an
Implementation Guide or declared in a short file, over a SQLite store. @tt{raco fhir-server}.}
@item{@hyperlink["fhir-lsp/index.html"]{fhir-lsp}: a language server, so an editor underlines
mistakes in the five text languages as you type. @tt{raco fhir-lsp}.}
@item{@hyperlink["fhir-mcp/index.html"]{fhir-mcp}: the workspace an AI agent works in.
@tt{raco fhir-mcp}.}]

@section{Words used here}

@itemlist[
@item{@bold{Resource}: one FHIR document, such as a Patient or an Observation, written as JSON.}
@item{@bold{Profile}: a set of rules a resource must follow in some setting, on top of FHIR's own
(a StructureDefinition resource).}
@item{@bold{Implementation Guide} (IG): a published set of profiles, value sets and examples for
one purpose, such as US Core or the International Patient Summary. It is distributed as a
@italic{package}, a @tt{.tgz} file.}
@item{@bold{Value set}: a named set of codes, such as "the codes that mean a blood-pressure
reading". A @bold{code system} is where the codes come from (LOINC, SNOMED CT).}
@item{@bold{Canonical url}: the web address that names a definition, such as
@tt{http://hl7.org/fhir/ValueSet/administrative-gender}. It is a name; nothing needs to be served
there.}
@item{@bold{Operation}: a named service FHIR defines, written with a dollar sign (@tt{$validate}).}
@item{@bold{Terminology}: everything to do with codes: value sets, code systems, and the maps
between them.}]

@section{Limits}

Each page ends with a list of what its package does not do. The largest across the project:

@itemlist[
@item{FHIR is read and written as JSON only, never XML.}
@item{The server does not do conditional create, update or delete by a search, or SMART
authorization.}
@item{The validator does not follow references to check what they point at.}
@item{The terminology service only knows the code systems in the packages it is given. SNOMED CT and
LOINC are not shipped, so a value set defined by a rule over them cannot be listed out, though a
value set that lists its codes works.}
@item{CQL computes proportion measures for FHIR Measure resources; the other kinds of scoring are
available for measures in the cqm-models format.}
@item{The mapping language runs every transform but @tt{dateOp}.}
@item{FHIR Shorthand reproduces most, not all, of what the reference compiler (SUSHI) writes for the
published guides it is tested on; @tt{TESTING.md} in each repository has the numbers.}]
