#lang scribble/manual

@title{fhir: FHIR as a family of Racket languages}

FHIR's specifications as @hash-lang[]s: a profile, a value set, a quality measure, a mapping or a
query is a file in its own language, checked when it compiles, and a value a Racket program can use.
Around the languages sit a validator, a terminology service, servers generated from Implementation
Guides, and command-line tools that report every problem as @tt{file:line:col}.

@section{The languages}

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{language} @bold{you write} @bold{file} @bold{run it})
      (list @hyperlink["https://oloveluck.github.io/fsh/"]{fsh} "profiles, extensions, instances, value sets (FHIR Shorthand)" @tt{.fsh} @tt{raco fsh check ig/})
      (list @hyperlink["https://oloveluck.github.io/cql/"]{cql} "clinical logic and quality measures (CQL)" @tt{.cql} @tt{raco cql lib.cql --data patient/})
      (list @hyperlink["https://oloveluck.github.io/fml/"]{fml} "maps between structures (FHIR Mapping Language)" @elem{@tt{.fml}, @tt{.map}} @tt{raco fml map.map --transform in.json})
      (list @hyperlink["https://oloveluck.github.io/vcl/"]{vcl} "a value set's compose as one expression" @tt{.vcl} @tt{raco vcl expr.vcl})
      (list @hyperlink["https://oloveluck.github.io/sql-on-fhir/"]{sql-on-fhir} "tabular views over FHIR data (ViewDefinitions)" @tt{.sof} @tt{raco sql-on-fhir run view.sof data/})
      (list @hyperlink["fhir/index.html"]{fhir/r6} "a resource as a form, checked as it compiles" @tt{.fhir6} @tt{racket patient.fhir6})
      (list @hyperlink["https://oloveluck.github.io/fhirpath/"]{fhirpath} "expressions over resources (a library, no file type)" "" @tt{raco fhirpath 'name.given' p.json}))]

Every file is a Racket module: @racket[(require "profile.fsh")] gives the compiled resources,
@racket[(require "screening.cql")] a procedure over a patient's data, @racket[(require "intake.fml")]
the map as a function. A mistake is reported where it is, in the file, when the module compiles.

@section{Start here}

The packages are not on the Racket package server yet. Clone the repositories side by side and
install from source (Racket 8.10 or later):

@verbatim{
git clone https://github.com/oloveluck/fhir      # also: fhirpath vcl cql fml fsh sql-on-fhir fhir-examples
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx fhir/fhir-validation cql fml fsh fhir/fhir-server fhir/fhir-lsp fhir/fhir-mcp sql-on-fhir fhir-examples
}

Then one of these, each a few lines:

@itemlist[
@item{@bold{Write a profile and check an example against it}: a @tt{.fsh} file, then
@tt{raco fsh check}. The problem is positioned on the FSH line that caused it. Start with the
@hyperlink["https://oloveluck.github.io/fsh/"]{fsh} quick start.}
@item{@bold{Validate a resource}: @tt{raco fhir-validate patient.json}, or against a profile with the
IG's package in context (@hyperlink["fhir-validation/index.html"]{fhir-validation}).}
@item{@bold{Serve an Implementation Guide}: @tt{raco fhir-server serve-ig hl7.fhir.us.core}, a
whole server from the package, every write validated (@hyperlink["fhir-server/index.html"]{fhir-server}).}
@item{@bold{Run a measure}: a @tt{.cql} library over a directory of patient resources
(@hyperlink["https://oloveluck.github.io/cql/"]{cql}).}
@item{@bold{See them together}: @tt{fhir-examples/screening}, one program composed of seven
language files (@hyperlink["https://oloveluck.github.io/fhir-examples/"]{fhir-examples}).}
@item{@bold{In your editor}: @tt{raco fhir-lsp} is a language server for all five languages; the
@hyperlink["fhir-lsp/index.html"]{fhir-lsp} page has the three-line setup for VS Code, Neovim and
Emacs.}
@item{@bold{For an agent}: @tt{raco fhir-mcp} offers every FHIR operation and the languages' checks as
MCP tools (@hyperlink["fhir-mcp/index.html"]{fhir-mcp}).}]

@section{The other packages}

This repository holds the foundation and the tools; each language is a repository of its own.

@itemlist[
@item{@hyperlink["fhir/index.html"]{fhir}: the typed node model, JSON in and out, the R4, R5 and R6
towers, @hash-lang[] @tt{fhir/r6}, StructureDefinition tooling, FHIR operations as procedures,
diagnostics. @tt{raco fhir}.}
@item{@tt{fhir-spec}: the HL7 packages the tools read (core R4, R5, R6 and the IGs the tests use). Data only.}
@item{@hyperlink["fhir-tx/index.html"]{fhir-tx}: the terminology service, @tt{$expand},
@tt{$validate-code}, @tt{$lookup}, @tt{$translate} over any FHIR package. @tt{raco fhir-tx}.}
@item{@hyperlink["fhir-validation/index.html"]{fhir-validation}: the validator. @tt{raco fhir-validate}.}
@item{@hyperlink["fhir-server/index.html"]{fhir-server}: servers generated from IGs, @hash-lang[]
@tt{fhir/capability}, the HTTP server and SQLite store. @tt{raco fhir-server}.}
@item{@hyperlink["fhir-lsp/index.html"]{fhir-lsp}: a language server for the five languages, so an
editor shows each problem as you type. @tt{raco fhir-lsp}.}
@item{@hyperlink["fhir-mcp/index.html"]{fhir-mcp}: a Model Context Protocol server, so an agent can
validate, expand, transform, compile and check through the same tools. @tt{raco fhir-mcp}.}
@item{@hyperlink["https://oloveluck.github.io/fhir-examples/"]{fhir-examples}: worked examples and
@tt{raco spec-bench}, a benchmark for writing profiles from prose.}]

@section{How the pieces fit}

@itemlist[
@item{@bold{One value model.} Every language produces FHIR resources as JSON or typed nodes, so the
output of one is the input of another: an FSH profile validates what an FML map produced; a CQL
library runs over the same resources a SQL on FHIR view reads.}
@item{@bold{Operations as procedures.} @tt{$validate}, @tt{$expand}, @tt{$transform},
@tt{$evaluate-measure} and the rest are applied by name with keyword arguments and threaded with
@racket[~>]; the same values are served over HTTP by fhir-server.}
@item{@bold{The module system is the registry.} Requiring a @tt{.fsh}, @tt{.vcl}, @tt{.fml} or
@tt{.cql} module registers what it defines (profiles, value sets, maps, libraries), so anything that
resolves by canonical url finds it.}
@item{@bold{Terminology.} Codes are checked when a resource form compiles (required bindings that
expand offline), when a resource is validated (through the terminology service when given one), and
at run time by the service itself. CQL takes value set expansions as data; FSH records bindings and
checks no codes.}
@item{@bold{One diagnostic shape.} Every tool reports @tt{file:line:col: lang phase severity:
message} with the source line and a caret, or the same as JSON or an OperationOutcome
(@litchar{--format json|outcome}), so an editor or an agent can read it.}]

@section{Limits}

Each document ends its usage section with a @italic{Limits} list taken from the code. The largest:
nothing reads or writes XML; resource forms exist for R6 only; the server has no chaining,
conditional requests or SMART; the validator checks no references or extension contexts and leaves
invariants off; the terminology service cannot see external code systems such as SNOMED CT; CQL
scores proportion measures only; FML runs every transform but @tt{dateOp}, @tt{escape} and
@tt{pointer}; FSH reproduces most but not all of what SUSHI writes for two real IGs.
