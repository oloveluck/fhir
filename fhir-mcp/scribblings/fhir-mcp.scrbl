#lang scribble/manual
@(require (for-label racket/base racket/contract fhir/mcp/tools fhir/mcp/server fhir/mcp/workspace fhir/mcp/verbs))

@title{fhir-mcp: a FHIR workspace for an agent}

A @hyperlink["https://modelcontextprotocol.io"]{Model Context Protocol} server. An agent works in a
@italic{workspace}: a directory of programs in the FHIR languages and FHIR JSON. Nine tools write,
check, run and explain them against FHIR data. Each tool works the same way for every language: the
file's extension decides what it means. What one file defines, every other file sees by canonical.
A CQL library uses a value set written in VCL, examples validate against profiles written in FSH,
and a map's results are validated as they are produced. Every problem is reported at a file, line
and column. Part of the @hyperlink["https://github.com/oloveluck/fhir"]{fhir} family.

@table-of-contents[]

@section{Quick start}

@verbatim{
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx fhir/fhir-validation cql fml fsh sql-on-fhir fhir/fhir-lsp fhir/fhir-mcp
raco fhir-mcp --workspace my-workspace          # serve over stdio
}

For Claude Code or Claude Desktop, an entry in the MCP configuration:

@verbatim|{{
  "mcpServers": {
    "fhir": { "command": "raco", "args": ["fhir-mcp", "--workspace", "/path/to/my-workspace"] }
  }
}}|

A @tt{workspace.yaml} in the directory configures it. Every key is optional:

@verbatim|{fhirVersion: 4.0.1                 # or 5.0.0; every language follows it (CQL's model is 4.0.1)
canonical: http://example.org/fhir # the base of what the workspace defines
packages:                          # FHIR packages in context: a .tgz path, or a name in fhir-spec / FHIR_PACKAGE_PATH
  - hl7.fhir.us.core-6.1.0
data: data/                        # a directory, a JSON file (a Bundle), or a FHIR server's base url
parameters:                        # CQL parameters, as CQL expressions
  Measurement Period: Interval[@2025-01-01T00:00:00.000, @2025-12-31T23:59:59.999]
allowRemoteWrites: false           # commit may write to a FHIR server only when true
models:                            # CQL data models made from the workspace's FSH logical models
  Clinic: http://example.org/fhir patient=Member birthDate=born version=1.0}|

@litchar{--package} adds packages and @litchar{--data} overrides @tt{data}. A FHIR server that needs
a token reads it from the environment variable @tt{FHIR_AUTHORIZATION}, the whole header value. A
token never goes in a file. @tt{raco fhir-mcp call <tool> '<json>'} runs one tool from the shell
(exit 1 when it fails), and @tt{raco fhir-mcp tools} prints the schemas.

@section{The files}

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{file} @bold{language} @bold{run gives} @bold{explain gives})
      (list @tt{*.fsh} "FHIR Shorthand: profiles, extensions, value sets, examples" "the resources the file defines; every example validated" "an entity's problems, each traced to its rule")
      (list @tt{*.cql} "Clinical Quality Language" "every define's value for every patient, and counts" "one patient's define, down through the defines it uses to the retrieves: how many resources of the type the patient has, which were kept")
      (list @tt{*.fhirpath} "one FHIRPath expression" "its value over each resource it reads" "the value of every part of it over one resource")
      (list @tt{*.vcl} "one VCL expression: a ValueSet at <canonical>/ValueSet/<file>" "the expansion" "which part of the expression holds a code")
      (list @elem{@tt{*.map}, @tt{*.fml}} "FHIR Mapping Language" "each source resource transformed, the result validated" "one transform's result and its problems, traced to rules")
      (list @tt{*.view.json} "a SQL on FHIR ViewDefinition" "its rows" "the rows one resource produces, and whether each where holds")
      (list @tt{*.json} "any FHIR resource" "a Measure: $evaluate-measure; anything else: $validate" "its validation issues"))]

@section{The tools}

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{tool} @bold{arguments} @bold{does})
      (list @tt{write} @elem{@tt{path}, @tt{text}} "saves a file (empty text deletes it) and answers its problems in the same call; never outside the workspace or into the data")
      (list @tt{check} @tt{paths?} "every problem, and the configuration: FHIR version, packages, data")
      (list @tt{run} @elem{@tt{path}, @tt{entry?}, @tt{over?}, @tt{parameters?}} "a file against the data: a summary, the first rows, and a handle result://rN")
      (list @tt{query} @elem{@tt{language}, @tt{text}, …} "the same without a file: fhirpath, cql (an expression is evaluated per patient), vcl, search (Type?params, on a FHIR server), view")
      (list @tt{explain} @elem{@tt{ref}, @tt{subject}, @tt{entry?}} "why one subject's answer is what it is (a result or a file)")
      (list @tt{describe} @elem{@tt{ref}, @tt{offset?}, @tt{limit?}, @tt{against?}} "anything by reference: a result (paged, or compared with another), Type/id, a canonical, a type or element, an operation and its inputs, a fragment of a name")
      (list @tt{apply} @elem{@tt{operation}, @tt{inputs?}, @tt{resource?}} "any registered FHIR operation, in the workspace's context")
      (list @tt{stage} @elem{@tt{resources} | @tt{result} | @tt{path}} "a write prepared: each resource validated and compared with the data's copy (create, update and its changed paths, unchanged)")
      (list @tt{commit} @tt{stage} "a stage written: to a data directory (a file per resource), or a FHIR server when allowed; a stage with errors is refused"))]

Tool definitions are short (about 6 KB for the nine), and an operation's inputs are read only when an
agent asks for them with @tt{describe("$code")}.

@section{Resources}

@tt{learn://workspace} explains the workspace. @tt{learn://fsh}, @tt{learn://cql},
@tt{learn://fhirpath}, @tt{learn://vcl}, @tt{learn://fml}, @tt{learn://sql-on-fhir} and
@tt{learn://search} each give a cheat sheet, a worked example, common problems and links to the
language's official reference: the FHIR Shorthand specification, cql.hl7.org, FHIRPath N1, the VCL
page of the IG guidance, the FHIR Mapping Language, sql-on-fhir.org and FHIR search. A test compiles
every worked example. @tt{result://rN} is a run's whole result. @tt{fhir://guide/...},
@tt{fhir://packages} and @tt{fhir://definition/{kind}/{ref}} serve the guides, the packages in
context and their definitions. The prompts @tt{fsh-profile}, @tt{fsh-instance} and @tt{fix-workspace}
start an agent on common work.

@section{Limits}

@itemlist[
@item{One workspace per server, one request at a time, stdio only. Results and stages live in the
server's memory.}
@item{CQL's installed FHIR model is 4.0.1; a library that uses FHIR in an R5 workspace is told so at its
@tt{using}. Any other model works: one designed in the workspace as FSH logical models and named in
@tt{workspace.yaml}'s @tt{models}, or a ModelInfo document in a directory named by @tt{CQL_MODEL_PATH}.}
@item{A directory or file of JSON has no search engine. @tt{query("search")} needs a FHIR server, and
FHIRPath queries work everywhere.}
@item{Expansion uses the code systems in the packages. SNOMED CT and LOINC are not shipped, so a
filter over them does not expand, though enumerated codes still work.}
@item{An update replaces the whole resource (PUT). The staged diff lists every path that changes,
including elements the new resource leaves out.}]

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
