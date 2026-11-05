#lang scribble/manual
@(require (for-label racket/base racket/contract fhir/mcp/tools fhir/mcp/server))

@title{fhir-mcp: the FHIR family as tools for an agent}

A @hyperlink["https://modelcontextprotocol.io"]{Model Context Protocol} server over the family.
Every FHIR operation the installed packages implement is a tool whose input schema is its
OperationDefinition's parameters: @tt{fhir_validate}, @tt{fhir_expand}, @tt{fhir_validate-code},
@tt{fhir_lookup}, @tt{fhir_translate}, @tt{fhir_snapshot}, @tt{fhir_transform},
@tt{fhir_evaluate-measure}, @tt{fhir_sql-run} and the rest. The languages add their own:
@tt{diagnose_file} (any file of the five languages, as the family's positioned diagnostics),
@tt{fsh_check} (a project: compile and validate every example), @tt{fsh_compile}, @tt{fsh_decompile},
@tt{cql_elm}, @tt{cql_evaluate}, @tt{vcl_valueset}, @tt{fhirpath_evaluate}; and the packages in
context answer @tt{fhir_element} (what an element is) and @tt{fhir_find} (which profile, value set
or extension is called what), so an agent writing a profile can look things up the way an author
reads the specification. An agent writing FSH, CQL or maps gets
the same checks a person gets at the command line, and FHIR data in and out as JSON. Part of the
@hyperlink["https://github.com/oloveluck/fhir"]{fhir} family.

@table-of-contents[]

@section{Quick start}

@bold{1. Install} the server and whatever operations and languages you want it to offer (the
packages are not on the Racket package server yet; clone the repositories side by side):

@verbatim{
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx fhir/fhir-validation cql fml fsh fhir/fhir-lsp fhir/fhir-mcp
raco fhir-mcp tools | head -c 600        # the tools and their schemas
}

@bold{2. Point an agent at it.} The command is @tt{raco fhir-mcp}, speaking the protocol on stdin
and stdout, one JSON line per message. For Claude Desktop or Claude Code, an entry in the MCP
configuration:

@verbatim|{{
  "mcpServers": {
    "fhir": {
      "command": "raco",
      "args": ["fhir-mcp", "--package", "hl7.fhir.us.core-6.1.0.tgz", "--package", "hl7.fhir.r4.core.tgz"]
    }
  }
}}|

@litchar{--package} names the FHIR packages profiles and value sets resolve from (a @tt{.tgz} or a
file in @tt{fhir-spec}, repeatable, in order); @litchar{--data <dir>} is a directory of resources
the operations read as their data source (what @tt{$expand} finds a ValueSet in, what a measure runs
over).

@bold{3. Try a tool from the shell.} @tt{raco fhir-mcp call} runs one tool with JSON arguments and
prints its text:

@verbatim|{$ raco fhir-mcp call vcl_valueset '{"vcl": "(http://loinc.org)(85354-9;55284-4)"}'
{"resourceType":"ValueSet","url":"http://fhir.org/VCL?v1=(http://loinc.org)(85354-9;55284-4)", ...}
$ raco fhir-mcp call fhir_validate '{"resource": {"resourceType": "Patient", "gender": "florp"}}' --package hl7.fhir.r4.core.tgz
{"resourceType":"OperationOutcome","issue":[{"severity":"error","code":"code-invalid", ...}]}
$ raco fhir-mcp call fsh_check '{"directory": "ig/"}'}|

The exit code is 1 when the tool reports an error (an OperationOutcome with errors, diagnostics
with an error, a missing argument).

@section{The tools}

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{tool} @bold{arguments} @bold{result})
      (list @tt{fhir_<code>} "the operation's `in` parameters by name (a list for a repeating one); `resource` for an operation applied to a resource itself" "the operation's result as FHIR JSON; a failure is its OperationOutcome, isError")
      (list @tt{diagnose_file} @tt{path} "the diagnostics (JSON and text), isError when any is an error")
      (list @tt{fsh_check} @tt{directory} "the project compiled, every example validated: diagnostics positioned in the FSH")
      (list @tt{fsh_compile} @tt{fsh} "the FHIR resources (R5, the default canonical)")
      (list @tt{cql_elm} @tt{cql} "the ELM JSON")
      (list @tt{cql_evaluate} @elem{@tt{cql}, @tt{resources}, @tt{parameters}} "every definition's value over one patient's resources")
      (list @tt{vcl_valueset} @tt{vcl} "a ValueSet resource")
      (list @tt{fhirpath_evaluate} @elem{@tt{expression}, @tt{resource}} "the result collection as JSON")
      (list @tt{fhir_element} @elem{@tt{type}, @tt{path}} "an element's definition from a type or profile in the packages: cardinality, types, binding, short, definition (valueQuantity finds value[x]); without a path, the type's top-level elements")
      (list @tt{fhir_find} @elem{@tt{query}, @tt{resourceType}, @tt{limit}} "profiles, extensions, value sets, code systems, operations and search parameters in the packages whose id, name or url contains the query")
      (list @tt{fsh_decompile} @tt{resource} "FHIR JSON to FSH (a StructureDefinition, ValueSet or CodeSystem idiomatically; anything else an Instance)")
      (list @tt{data_resources} @elem{@tt{type}, @tt{id}} "the ids of a type in the data source, or one resource"))]

Which operations appear depends on the packages installed: fhir (@tt{$snapshot}), fhir-validation
(@tt{$validate}), fhir-tx (the terminology operations), fml (@tt{$transform}), cql
(@tt{$evaluate-measure}), sql-on-fhir (@tt{$sql-run}, @tt{$sql-export}). Two operations sharing a
code are told apart by resource type (@tt{fhir_Patient_everything}).

@section{Resources and prompts}

Besides tools the server answers @tt{resources/list}, @tt{resources/templates/list} and
@tt{resources/read}: @tt{fhir://guide/authoring}, @tt{fhir://guide/cli} and @tt{fhir://guide/serving}
are the family's how-to guides as markdown (the repository's skills, served when the package is
installed from the repository), @tt{fhir://packages} the FHIR packages in context, and
@tt{fhir://definition/{kind}/{ref}} any StructureDefinition, ValueSet, CodeSystem, StructureMap or
ConceptMap in them by id, name or canonical url, as JSON. @tt{prompts/list} and @tt{prompts/get} give
three starting points an agent fills with arguments: @tt{fsh-profile} (a base and requirements: write
the profile, check it with the tools, prove it with a conforming and a violating instance),
@tt{fsh-instance} (a profile and a scenario) and @tt{fix-project} (a project directory: fix every
diagnostic at its line). Each carries the authoring guide when it is at hand.

@section{Limits}

@itemlist[
@item{No sampling or subscriptions; one request at a time; stdio only.}
@item{A language tool runs in the server's process with the context given at start; an FSH project
is checked from disk.}
@item{The protocol version answered is 2024-11-05; clients that insist on a newer one still work
with the same methods.}]

@section{Reference}

@subsection[#:style 'unnumbered]{@tt{fhir/mcp/tools}}
@defmodule[fhir/mcp/tools]

@defstruct*[tool ([name string?] [description string?] [input-schema hash?] [run procedure?])]{
(The struct is @tt{fhir/lang/support}'s, re-exported.)
A tool: @racket[(run arguments)] answers @racket[(values text error?)].}
@defproc[(operation->tool [o operation?] [all (listof operation?)]) tool?]{A registered FHIR operation as a tool: its OperationDefinition's @tt{in} parameters are the schema, those with min 1 required.}
@defproc[(operation-tools) (listof tool?)]{Every registered operation.}
@defproc[(language-tools) (listof tool?)]{@tt{diagnose_file}, then every installed language's own tools (from its @tt{<id>/support} module): @tt{fsh_check}, @tt{fsh_compile}, @tt{fsh_decompile}, @tt{cql_elm}, @tt{cql_evaluate}, @tt{vcl_valueset}, @tt{fhirpath_evaluate}.}
@defproc[(definition-tools) (listof tool?)]{@tt{fhir_element}, @tt{fhir_find}, @tt{data_resources}.}
@defproc[(all-tools) (listof tool?)]
@defproc[(call-tool [t tool?] [arguments hash?]) (values string? boolean?)]{Runs a tool; never raises.}
@defproc[(load-operations!) (listof symbol?)]{Loads each operation module whose package is installed, so its operations register; the modules loaded.}
@defproc[(tool->jsexpr [t tool?]) hash?]{The protocol's tool description.}

@subsection[#:style 'unnumbered]{@tt{fhir/mcp/server}}
@defmodule[fhir/mcp/server]

@defproc[(serve [tools (listof tool?)] [in input-port? (current-input-port)] [out output-port? (current-output-port)]) void?]{The loop: one JSON message per line, until the stream ends.}
@defproc[(dispatch [message hash?] [st state?]) (values (or/c hash? #f) state?)]{One message: the response (none for a notification) and the next state. Pure.}
@defstruct*[state ([tools (listof tool?)] [initialized? boolean?])]
@defthing[protocol-version string?]
