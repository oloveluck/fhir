#lang scribble/manual
@(require (for-label racket/base racket/contract fhir/mcp/tools fhir/mcp/server fhir/mcp/workspace fhir/mcp/verbs))

@; tt : code inside a sentence, exactly as typed (scribble's own tt would turn -- into a dash and
@; 'x' into curly quotes)
@(require (only-in scribble/core element))
@(define (tt . text) (element 'tt text))

@title{fhir-mcp: a FHIR workspace for an AI agent}

An AI agent such as Claude can do real work with health data, if it has the right place to do it:
somewhere to write things down, a way to check them, a store for the data, and a record of what it
did. @tt{fhir-mcp} is that place. You say what you want ("record these lab results", "who has an
HbA1c above 9 %?", "no result may be entered without a patient"); the agent writes it in one of
FHIR's languages, the tools check it and run it, and every change to the data is kept with who made
it, when, why and from what.

The name: the @hyperlink["https://modelcontextprotocol.io"]{Model Context Protocol} (MCP) is the
standard way an agent is given tools. This is an MCP server whose tools work on a
@italic{workspace}, a folder on your machine.

Part of the @hyperlink["https://oloveluck.github.io/fhir/"]{fhir} family of FHIR languages and tools.

@table-of-contents[]

@section{What you can do with it}

Things you can ask an agent that has a workspace, and what happens:

@itemlist[
@item{@bold{Record data.} The agent writes the resources (a patient, a result), each is validated,
and nothing invalid is stored.}
@item{@bold{Ask questions of the data}: find records by FHIR search, compute per patient with CQL
("the latest HbA1c for each patient"), turn records into a table and summarise it with SQL.}
@item{@bold{Make rules the data must keep.} A rule is a FHIR profile; once it is in force, a change
that breaks it is refused, with the value that broke it.}
@item{@bold{See why.} Why one patient got the answer they did; who changed a value, when, why, and
what it was before.}
@item{@bold{Convert data}: a filled-in form into a Patient, one shape into another, with a map.}
@item{@bold{Publish definitions}: profiles, value sets and libraries with versions, kept in the same
store, mirrored as text for git.}
@item{@bold{Stand up a server}: a FHIR server over the same data, declared in a short file.}]

@section[#:tag "first"]{A first example}

@bold{1. Install} the tools as the @hyperlink["https://oloveluck.github.io/fhir/"]{family's front
page} describes.

@bold{2. Make a workspace.}

@verbatim{
$ raco fhir-mcp init clinic
wrote clinic/workspace.yaml
wrote clinic/.mcp.json
wrote clinic/CLAUDE.md
wrote clinic/.gitignore
}

@tt{workspace.yaml} is its settings; @tt{.mcp.json} is what tells Claude Code how to start the
server; @tt{CLAUDE.md} is a short note telling the agent where to begin. The data will live in
@tt{clinic/fhir.db}, created the first time something is stored.

@bold{3. Open the folder with your agent.} With Claude Code, run @tt{claude} inside @tt{clinic/}: it
reads @tt{.mcp.json} and starts the server. For another client, the entry is:

@verbatim|{{ "mcpServers": {
    "fhir": { "command": "raco",
              "args": ["fhir-mcp", "--workspace", "/path/to/clinic"] } } }}|

@bold{4. Ask for something.} For example: @italic{"Record a patient, Ann Lee, born 25 December 1974,
and her HbA1c of 9.4 % on 1 September 2025. It is from the lab report."} The agent writes the two
resources in FHIR Shorthand:

@verbatim|{Instance: ann
InstanceOf: Patient
* name.given = "Ann"
* name.family = "Lee"
* gender = #female
* birthDate = "1974-12-25"

Instance: a1c-1
InstanceOf: Observation
* status = #final
* code = http://loinc.org#4548-4 "Hemoglobin A1c"
* subject = Reference(Patient/ann)
* effectiveDateTime = "2025-09-01"
* valueQuantity = 9.4 '%'}|

It then @italic{stages} them, which checks each one and says what would change, and @italic{commits}
the stage, which writes them:

@verbatim|{stage  -> {"changes":[{"action":"create","resource":"Patient/ann"},
                       {"action":"create","resource":"Observation/a1c-1"}],"errors":0, …}
commit -> {"agent":"Dr Ng","reason":"entered from the lab report",
           "written":[{"version":"Patient/ann/_history/1", …},
                      {"version":"Observation/a1c-1/_history/1", …}], …}}|

@bold{5. Add a rule.} @italic{"An HbA1c must be between 3 and 20 %."} The agent writes a profile with
that rule and puts it in force. From then on:

@verbatim|{stage (an HbA1c of 94 %) ->
  "errors": ["bad.fsh:7: Observation: a1c-range: An HbA1c is between 3 % and 20 %
              (found valueQuantity.value = 94)"]}|

The change is refused. The message names the rule, the value it found, and the line that wrote it.

@bold{6. Correct something, and look back.} A result entered as 9.9 % should have been 8.9 %. The
agent stages the correction (@tt{"changed": ["valueQuantity.value: 9.9 → 8.9"]}) and commits it
with the reason. The history of that result (@tt{describe ref=Observation/a1c-2/_history}) then
says, in short:

@verbatim|{version 2  Dr Ng  "typing error: the report says 8.9"  value: 9.9 → 8.9
version 1  Dr Ng  "November result"                    created}|

Nothing is overwritten: every version is kept, each with who made it, when, why, and the text it
was written from.

@section{What is in a workspace}

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{In the folder} @bold{What it is})
      (list @tt{workspace.yaml} @elem{the settings (@secref["config"])})
      (list @tt{fhir.db} "the store: a SQLite database holding every resource, every earlier version of it, and the record of each change")
      (list "your files" @elem{programs in the languages (@secref["files"]); they can be deleted and got back from the store})
      (list @tt{sushi-config.yaml} "optional: the implementation guide, which gives your definitions a name, a version and a status")
      (list @tt{export/} "the definitions in the store written out as text, for git (a SQLite file cannot be compared or merged)")
      (list @tt{.fhir-mcp/} "what the tools remember between calls: results and stages")
      (list @elem{@tt{.mcp.json}, @tt{CLAUDE.md}, @tt{.gitignore}} "how an agent starts, and what git should leave out (the store)"))]

@section[#:tag "tools"]{The nine tools}

The agent has nine tools, the same nine whatever the language. A person can run any of them from
the shell too (@secref["shell"]).

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{Tool} @bold{What it does})
      (list @tt{write} "saves a file and answers its problems in the same call, each at its line; can also bring a stored definition back as a file")
      (list @tt{check} "lists every problem in the workspace; with the data too, every stored resource that breaks a rule")
      (list @tt{run} @elem{runs a file against the data and keeps the result under a name (@tt{result://…})})
      (list @tt{query} "asks once without a file: a FHIRPath or CQL expression, a FHIR search, a value set, or SQL over the views and earlier results")
      (list @tt{explain} "says why one patient or one resource got the answer it did, step by step")
      (list @tt{describe} "reads anything back: a result, a resource (as JSON or as FHIR Shorthand), its history, a definition, what an element or an operation is")
      (list @tt{apply} @elem{applies a FHIR operation (@tt{$validate}, @tt{$expand}, @tt{$transform}, @tt{$evaluate-measure} …)})
      (list @tt{stage} "prepares a change to the data: each resource checked and compared with what is stored")
      (list @tt{commit} "writes a stage, all of it or none, and records who, when, why and from what"))]

The split between @tt{stage} and @tt{commit} is deliberate. Staging shows what would change and
whether it is allowed, and changes nothing; only a stage with no errors can be committed.

@section[#:tag "files"]{The files an agent writes}

The file's ending says which language it is in.

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{File} @bold{Language} @bold{Running it gives} @bold{Explaining it gives})
      (list @tt{*.fsh} "FHIR Shorthand: profiles, value sets, example resources" "the resources it defines, each example checked" "a resource's problems, each at the rule that caused it")
      (list @tt{*.cql} "Clinical Quality Language: logic over a patient's record" "every definition's value for every patient, with counts" "one patient's answer, down to the records that were used")
      (list @tt{*.fhirpath} "one FHIRPath expression" "its value over each resource" "the value of each part of it")
      (list @tt{*.vcl} "one VCL expression: a value set" "the codes it holds" "which part of it holds a given code")
      (list @elem{@tt{*.map}, @tt{*.fml}} "FHIR Mapping Language: a conversion" "each source converted, the result checked" "one conversion, its problems at the map's rules")
      (list @tt{*.view.json} "a SQL on FHIR view: a table over resources" "its rows" "the rows one resource gives, and why")
      (list @tt{*.json} "any FHIR resource" "its validation" "its problems")
      (list @tt{sushi-config.yaml} "the implementation guide" "what the workspace defines, as a list" "")
      (list @tt{*.capability.rkt} "a FHIR server, declared" "the server, started over the workspace's store" "what it supports"))]

What one file defines, the others can use by its address: a CQL library reads a value set written
in VCL; examples are checked against the profiles beside them; what a map produces is checked as it
is produced.

@section{Rules the data must keep}

A rule is a FHIR @italic{profile}, written in FHIR Shorthand: "an HbA1c is between 3 and 20 %", "a
blood pressure has a systolic and a diastolic value in mm[Hg]", "every result names its patient".
Putting it in force is one line in @tt{workspace.yaml} (@tt{profiles:}), or
@tt{write … enforce:=true}, or a @tt{global:} line in the implementation guide.

Once in force, a rule is applied whenever data is staged, so a change that breaks it cannot be
committed. @tt{check data:=true} applies the rules to everything already stored and counts what
breaks which rule: the way to find out what a new rule would catch. The workspace guide
(@tt{raco fhir guide workspace}) has a cookbook of common rules, each one tested.

@section{The record of every change}

Each commit leaves two FHIR resources in the store beside the data: a @italic{Provenance}, which
says which versions it wrote, who the agent was, the reason given, and the source text it wrote
them from (kept whole, with its fingerprint); and an @italic{AuditEvent}, the plain log line that it
happened. With @tt{audit: all} in the settings, every run and query leaves an AuditEvent too.

Because the record is data, it can be asked about like any other:

@verbatim|{$ raco fhir-mcp call query language=sql \
    text="SELECT type, id, versionId, agent, reason, at FROM trail ORDER BY recorded" as=csv
type,id,versionId,agent,reason,at
Patient,ann,1,Dr Ng,entered from the lab report,../results.fsh:1
Observation,a1c-1,1,Dr Ng,entered from the lab report,../results.fsh:14
Observation,a1c-2,1,Dr Ng,November result,../good.fsh:7
Observation,a1c-2,2,Dr Ng,typing error: the report says 8.9,../fix.fsh:7}|

@tt{trail} is one row for each version a commit wrote; @tt{at} is the file and line it came from.
@tt{describe ref=Observation/a1c-2/_history} gives one resource's versions with what changed in each.

@section{Definitions, versions and git}

Profiles, value sets, libraries and maps are FHIR resources too, and the store keeps them with the
data. An @italic{implementation guide} (@tt{sushi-config.yaml}) gives them a shared name, version
and status: @tt{draft} while you work, @tt{active} once released. A released definition does not
change; changing it means a new version, and the old one is kept.

The files are working copies. Delete one and the definition is still in the store;
@tt{write path=lab.fsh ref=<its address>} brings it back as text. Because git cannot compare a
database, every commit of a definition also rewrites @tt{export/}: the same definitions as text
files, which is what you put in git. @tt{raco fhir-mcp export --check} tells a build whether that
folder is up to date.

@tt{raco fhir guide ig} is the full account: versions, pinning a version, what depends on what.

@section{Guides the agent reads}

The server carries guides written for an agent: short, dense, every example tested. An agent reads
them as @tt{learn://<topic>}; you can print the same text with @tt{raco fhir guide <topic>}.

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @tt{fhir} "FHIR itself: which resource holds which fact, the shapes that recur, the usual code systems")
      (list @tt{workspace} "the workspace: the tools, which language for which question, rules, the record of changes")
      (list @elem{@tt{fsh}, @tt{cql}, @tt{fhirpath}, @tt{vcl}, @tt{fml}, @tt{sql-on-fhir}} "each language: a cheat sheet, a worked example, common problems")
      (list @tt{ig} "the implementation guide: definitions, versions, the store in git")
      (list @tt{capability} "FHIR servers you declare")
      (list @tt{search} "FHIR search")
      (list @tt{racket} "the same languages in a Racket program, with no server"))]

The @tt{fhir} skill in the repository (@tt{.claude/skills/fhir/SKILL.md}) is where an agent starts:
which tool for which job, and a whole session from creating data to a table.

@section[#:tag "config"]{Settings: workspace.yaml}

Every line is optional.

@verbatim|{fhirVersion: 4.0.1                 # or 5.0.0; every language follows it
canonical: http://example.org/fhir # where the addresses of your definitions begin
data: fhir.db                      # the store; or a folder of JSON, or a FHIR server
export: export/                    # where the definitions are written as text for git
packages:                          # published FHIR packages to work against
  - hl7.fhir.us.core-6.1.0
profiles:                          # the rules in force, by resource type
  Observation: http://example.org/fhir/StructureDefinition/a1c-result
audit: commits                     # or all: also record every run and query
parameters:                        # values for CQL parameters
  Measurement Period: Interval[@2025-01-01T00:00:00.000, @2025-12-31T23:59:59.999]
allowRemoteWrites: false           # a FHIR server is only written to when this is true
models:                            # a CQL data model made from your own logical models
  Clinic: http://example.org/fhir patient=Member birthDate=born version=1.0}|

When there is a @tt{sushi-config.yaml}, the FHIR version, the canonical, the packages and the rules
it states are taken from it, since they belong to the guide.

A FHIR server that needs a token reads it from the environment variable @tt{FHIR_AUTHORIZATION}
(the whole header value). A token is never kept in a file.

@section[#:tag "shell"]{Without an agent: from the shell}

Every tool can be run by hand, which is how you check what an agent did, or script it.

@verbatim|{raco fhir-mcp call stage fsh=@results.fsh     # one tool; @file passes a file's text
raco fhir-mcp call commit stage=latest reason="from the lab report" agent="Dr Ng"
raco fhir-mcp call describe ref=Observation/a1c-2/_history
raco fhir-mcp batch session.txt                # many calls in one go, one per line
raco fhir-mcp tools                            # the nine tools and their arguments
raco fhir-mcp export --check                   # is export/ up to date?}|

Run them inside the workspace folder, or add @litchar{--workspace <dir>}. An argument is
@tt{name=value}; @tt{name=@"@"file} gives a file's contents; @tt{name:=<json>} gives a number, true or
false, or a JSON object. A call that finds errors exits with status 1.

@section{Words used here}

@itemlist[
@item{@bold{MCP} (Model Context Protocol): the standard by which an AI agent is offered tools.}
@item{@bold{Workspace}: the folder an agent works in, with its settings, files and store.}
@item{@bold{Store}: the SQLite database (@tt{fhir.db}) that holds the resources and their history.}
@item{@bold{Resource}: one FHIR document, such as a Patient or an Observation.}
@item{@bold{Profile}: a set of rules for a kind of resource. Here, the rules the data must keep.}
@item{@bold{Stage}, @bold{commit}: a change prepared and checked, then written.}
@item{@bold{Provenance}, @bold{AuditEvent}: the FHIR resources that record who changed what and
why, and that something happened.}
@item{@bold{Implementation guide}: the named, versioned collection of a workspace's definitions.}
@item{@bold{Canonical}: the web address that names a definition.}
@item{@bold{View}: a SQL on FHIR ViewDefinition, which turns resources into the rows of a table.}]

@section{Limits}

@itemlist[
@item{One workspace to a server, one request at a time, over standard input and output.}
@item{CQL's FHIR model is version 4.0.1; a library that uses FHIR in a 5.0.0 workspace is told so at
its @tt{using} line.}
@item{Listing a value set's codes uses the code systems in the packages. SNOMED CT and LOINC are not
shipped, so a value set defined by a rule over them cannot be listed, though one that lists its
codes works.}
@item{An update replaces the whole resource. The staged change lists every path that differs,
including what the new version leaves out.}
@item{SQL is one reading statement (@tt{SELECT}, @tt{WITH}, @tt{VALUES}); it cannot change the data.}
@item{FHIR search over a store or over files does not follow chains between resources
(@tt{_has}, @tt{subject.name}); such a search is refused rather than answered wrongly. The same
question is a CQL library.}
@item{A server declared in the workspace (@tt{*.capability.rkt}) runs in a process of its own and
speaks FHIR R6; it stops when the workspace's server stops.}
@item{Data kept as a folder of JSON files or on a FHIR server can be read, searched and written, but
the history of versions and SQL over the stored resources themselves need the store
(@tt{data: fhir.db}).}]

@section{How it is tested}

Every session in the guides and in the @tt{fhir} skill is replayed by a test exactly as written:
the commands, and the answers they quote. Each rule in the cookbook is tested with a resource that
passes and one that is refused. A further test runs every command these documents name.

@section{Reference}

@subsection[#:style 'unnumbered]{@tt{fhir/mcp/workspace}}
@defmodule[fhir/mcp/workspace]
@defproc[(open-hub [dir path-string?] [#:data data (or/c string? #f) #f] [#:packages packages (listof string?) '()]) hub?]{
The workspace in @racket[dir]: @tt{workspace.yaml} read, the packages and the core package of its FHIR
version found, the data source opened, the operation modules loaded.}
@defproc[(with-hub [h hub?] [thunk (-> any)]) any]{Runs @racket[thunk] with the hub's packages and data source in context.}
The verbs' procedures (@racket[hub-write!], @racket[hub-check], @racket[hub-run], @racket[hub-query],
@racket[hub-explain], @racket[hub-describe], @racket[hub-apply], @racket[hub-stage!],
@racket[hub-commit!]) answer JSON or raise. Each language is reached through its @tt{<id>/workspace}
module, under the contract in @tt{fhir/lang/workspace}.

@subsection[#:style 'unnumbered]{@tt{fhir/mcp/verbs}}
@defmodule[fhir/mcp/verbs]
@defproc[(workspace-tools [h hub?]) list?]{The nine tools over a hub.}

@subsection[#:style 'unnumbered]{@tt{fhir/mcp/tools}}
@defmodule[fhir/mcp/tools]

@defstruct*[tool ([name string?] [description string?] [input-schema hash?] [run procedure?])]{
A tool: @racket[(run arguments)] answers @racket[(values text error?)].}
@defproc[(call-tool [t tool?] [arguments hash?]) (values string? boolean?)]{Runs a tool; never raises.}
@defproc[(tool->jsexpr [t tool?]) hash?]{The protocol's tool description.}
@defproc[(load-operations!) (listof symbol?)]{Loads each operation module whose package is installed, so its operations register; the modules loaded.}
@defproc[(apply-json [o operation?] [inputs hash?] [resource (or/c hash? #f)]) hash?]{An operation applied to inputs by name; the resource fills its subject input, or is what it applies to.}
@defproc[(element-info [type string?] [path (or/c string? #f)]) (or/c list? string?)]{An element's definition from a type or profile in the packages (@tt{valueQuantity} finds @tt{value[x]}); without a path, the type's top-level elements; a string says why there is none.}
@defproc[(find-definitions [fragment string?] [resource-type (or/c string? #f)] [limit exact-positive-integer?]) list?]{Definitions in the packages whose id, name or url contains the fragment.}

@subsection[#:style 'unnumbered]{@tt{fhir/mcp/server}}
@defmodule[fhir/mcp/server]

@defproc[(serve [tools (listof tool?)] [in input-port? (current-input-port)] [out output-port? (current-output-port)]) void?]{The loop: one JSON message per line, until the stream ends.}
@defproc[(dispatch [message hash?] [st state?]) (values (or/c hash? #f) state?)]{One message: the response (none for a notification) and the next state. Pure.}
@defstruct*[state ([tools (listof tool?)] [initialized? boolean?])]
@defthing[protocol-version string?]
