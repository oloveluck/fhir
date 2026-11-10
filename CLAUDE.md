# CLAUDE.md — working notes for this repo

FHIR as a framework for spec-driven development: FHIR's specs (profiles, value sets, invariants,
measures, maps) as Racket `#lang`s and the tools that check them, so a person or an LLM goes from a
requirement to a validated FHIR artifact with positioned feedback (language-oriented programming;
JSON only, no XML). Worked examples, and the spec-driven benchmark, live in the `fhir-examples` repo.

## Package map (the family)
Thirteen Racket packages in seven git repos, plus `fhir-examples` (examples and the benchmark). The foundation keeps
the `fhir` collection; each language is its own collection (`#lang cql`, `(require cql/compile)`).
Rule that makes directories movable: **cross-directory imports use collection paths** (`fhir/model/node`),
never `../model/node.rkt`. Dependency order (base first):

| package | repo / dir | contents | depends on |
|---|---|---|---|
| `fhir` | `oloveluck/fhir` → `fhir/` | foundation: `result/ contracts.rkt model/ primitives/ kernel/ lang-gen/ serialize/ foundation/ codegen/ sd/ r4/ r5/ r6/ spec-package.rkt package.rkt registry.rkt data-source.rkt operation.rkt diagnostic.rkt subcommands.rkt cli.rkt` (`raco fhir`), foundation `tests/` and `examples/` | base |
| `fhir-spec` | `oloveluck/fhir` → `fhir-spec/` | the vendored HL7 NPM packages (`*.tgz`) — data only, located via `fhir/spec-package` | base |
| `fhirpath` | `oloveluck/fhirpath` | the FHIRPath engine (with UCUM, `print.rkt`), `raco fhirpath` | fhir |
| `vcl` | `oloveluck/vcl` | `#lang vcl`, `raco vcl` | fhir |
| `fhir-tx` | `oloveluck/fhir` → `fhir-tx/` | `terminology/service.rkt` ($expand, $validate-code, $lookup, $translate over packages or resources; the tx-service handle for %terminologies), `terminology/operations.rkt` (the same as fhir/operation values), the tx-ecosystem suite, `tx-cli.rkt` (`raco fhir-tx`) | fhir, fhir-spec, fhirpath, vcl |
| `fhir-validation` | `oloveluck/fhir` → `fhir-validation/` | `conformance/validate.rkt`, the validation corpora and tests, `validate-cli.rkt` (`raco fhir-validate`) | fhir, fhir-spec, fhirpath, fhir-tx |
| `cql` | `oloveluck/cql` | `#lang cql` (CQL → ELM + interpreter) over any data model (a ModelInfo + a representation, both data; FHIR 4.0.1, QI-Core and US Core (compiled to ELM over FHIR through their mappings) and QDM (cqm-models JSON; `cql/cqm` computes measure documents' populations) shipped; models from logical StructureDefinitions), `raco cql` | fhir, fhirpath |
| `fml` | `oloveluck/fml` | `#lang fml` (FHIR Mapping Language), `raco fml` | fhir, fhir-tx (`translate`), fhirpath |
| `fsh` | `oloveluck/fsh` | `#lang fsh` (bidirectional), projects + packaging, `check.rkt`; `raco fsh`, `raco fsh check` | fhir, fhirpath, fhir-validation |
| `fhir-server` | `oloveluck/fhir` → `fhir-server/` | `capability/ http/ store/` (SQLite), IG-generated servers, `$evaluate-measure`, `server-cli.rkt` (`raco fhir-server`), server tests | fhir, fhir-spec, fhirpath, fhir-tx, fhir-validation, cql, db-lib |
| `fhir-lsp` | `oloveluck/fhir` → `fhir-lsp/` | the Language Server Protocol server for the five languages: `lsp/jsonrpc.rkt` (framing), `lsp/diagnostics.rkt` (fhir/diagnostic -> LSP), `lsp/languages.rkt` (the catalogue over `fhir/lang/support`), `lsp/server.rkt` (state, dispatch, loop; hover/definition/completion/symbols handed to the document's language support with its project), `lsp-cli.rkt` (`raco fhir-lsp`, `check`) | fhir (+ the languages' `support` modules at run time) |
| `fhir-mcp` | `oloveluck/fhir` → `fhir-mcp/` | the Model Context Protocol server over a WORKSPACE (below): `mcp/workspace.rkt` (the hub: config, packages, data source, artifacts registered, results, stages), `mcp/verbs.rkt` (the nine tools), `learn/*.md` (`learn://` guides with the official references for the workspace, search and the languages that do not ship their own yet; a language's own guide comes from its repo, below; their examples compile in the test), `mcp/tools.rkt` (the Tool struct; operations loaded and applied to JSON; elements and definitions in the packages), `mcp/resources.rkt` (guides, packages, definitions, learn, results; prompts), `mcp/server.rkt` (dispatch, one JSON line per message), `mcp/init.rkt` (`raco fhir-mcp init`: workspace.yaml, data/, .mcp.json, CLAUDE.md), `mcp/search-index.rkt` (FHIR search over data that is files, through fhir-server's store, loaded on demand), `mcp/sql.rkt` (SQL over views and results, and over the workspace's store read-only), `mcp-cli.rkt` (`raco fhir-mcp [--workspace d]`, `init`, `guide`, `tools`, `call`) | fhir, fhir-lsp (+ the operations and languages at run time) |
| `sql-on-fhir` | `oloveluck/sql-on-fhir` | `#lang sql-on-fhir`: ViewDefinition model and operation definitions GENERATED from the IG package (`target.rkt`, `model/`), the view engine, `$sql-run`/`$sql-export` as operations; `raco sql-on-fhir` | fhir, fhirpath (fhir-spec to regenerate) |
| `fhir-examples` | `oloveluck/fhir-examples` | `examples/` (operations applied as procedures), `bench.rkt` (prose → FSH tasks from a published IG, scored), recorded runs; `raco spec-bench` | fhir, fhir-spec, fhir-validation, fsh, fml |

`fhir`, `fhir-tx`, `fhir-validation` and `fhir-server` all contribute to the `fhir` collection and must stay
module-disjoint (module paths like `fhir/conformance/validate` did not change when the packages split).
`fhir` does NOT depend on `fhir-spec`: `fhir/spec-package.rkt` locates the tarballs through the
collection search path (`spec-package-path`, `#:optional? #t` for callers that can degrade).
`fhir/package.rkt` (`read-package`, `#:exact-decimals?`, `#:select` by file name) is the one reader of
FHIR NPM packages (sd-index, codegen and the tx harness keep specialised streaming readers).
OMOP and the DuckDB analytics were removed on 2026-11-02 (git history has them). SQL on FHIR returned
as its own repo, `sql-on-fhir` (below).

**Editor support is a contract in the foundation** (`fhir/lang/support`, `fhir/lang/declared`):
a LangSupport (diagnose, project-files, entities, hover, definition, complete) that each language
provides from its own `<id>/support` module (`fsh/support`, `cql/support`, `fml/support`, `vcl/support`,
`fhirpath/support`), tested with the language. fhir-lsp loads a support by its collection name
(`language-support`), keeps running when a language is absent (one "not installed" diagnostic), and
knows no language internals; what an agent runs is the language's `<id>/workspace` (below): a change to a language and its editor support
live and test in one repo. `current-language-supports` lets a test or an embedder supply a support by
hand; `lang/declared.rkt` serves a language whose declarations a line regexp finds (CQL, FML).

**A workspace is the agent-facing contract** (`fhir/lang/workspace`, served by fhir-mcp): a directory
of files in the languages and FHIR JSON, configured by `workspace.yaml` (fhirVersion, canonical,
packages, data = a directory | a JSON file | a FHIR server's base url, CQL parameters as CQL
expressions, allowRemoteWrites). Each language provides `<id>/workspace` (a WsSupport: `artifacts`
— what its files define, as resources, with every problem; `run` — a file or ad-hoc text against the
data -> a RunResult of kind/columns/rows/summary; `explain` — one subject's answer, positioned in the
source); `sql-on-fhir` is the sixth (`*.view.json`). The hub registers every language's artifacts in
fhir/registry under `(workspace <lang>)` (`unregister-source!` forgets a changed file), so the
languages compose by canonical exactly as `#lang` modules do: CQL resolves a VCL value set, FSH
examples validate against FSH profiles, includes resolve across `.cql` files (FHIRHelpers 4.0.1 is
bundled in `cql/libraries/`), and workspace.yaml's `models` makes a CQL data model from the
workspace's FSH logical models (`using Clinic version '1.0'`; cql/CLAUDE.md "Any data model"). Nine verbs, whatever the number of languages: write (problems in the
same call), check, run (-> `result://rN`), query (fhirpath/cql/vcl/search/view, no file), explain,
describe (results paged and diffed, Type/id, canonicals, elements, operations), apply (any
operation), stage (validated, diffed against the data) and commit (a data directory, or a FHIR
server only when allowed; a stage with errors is refused). `fhir/rest-data-source` is a FHIR server
as a data source (paged searchsets, `patient` then `subject` learned per type, `rest-write!`); a
server that cannot answer a ValueSet or Library search is treated as holding none. Tool definitions:
~6 KB for the nine verbs (the 25 per-operation and per-language tools they replaced were ~53 KB).

Seams (each a one-module move):
- `kernel/operation-entry.rkt` (fhir) holds the struct generated `operations.rkt` files need, so the
  towers don't depend on `capability/`; `capability/runtime` re-exports it.
- `fhirpath/print.rkt` — the store narrows search-param expressions with it.
- `sd/{sd-index,snapshot,element-index}.rkt` — pure SD machinery in the foundation, so `fsh` compiles
  without the validator. `sd-index` reads fhir-spec's core package when present (`current-sd-packages`).
- `fhirpath/tests/run-r5.rkt` `dynamic-require`s `fhir/terminology/service` (the %terminologies
  backend, in fhir-tx) and lowers its floor to 1041 when it is absent — fhir-tx depends on fhirpath
  (the `tx-service` handle lives there), so the TCK runner injects it at run time.
- `raco fsh check --capability` loads `fhir/store/ig-server` on demand (fsh does not depend on
  fhir-server) and says to install it when absent.
- codegen writes a tower to `(collection-path <collection> <out-root>)`: a `gen-target`'s `collection`
  is "fhir" for the core towers and an IG package's own collection otherwise — sql-on-fhir's
  `target.rkt` generates `sql-on-fhir/model` from HL7's published package (`#lang sql-on-fhir/model`,
  delegating to the R6 tower; banners name that package's own check command).

Each language repo carries its own `CLAUDE.md` with the architecture notes for that language, and
three documents for its users, one source each (all six languages: cql, fsh, fhirpath, vcl, fml,
sql-on-fhir; fhir-mcp's `learn/` keeps only `workspace.md` and `search.md`, and its test requires
every workspace language to provide its guide):
- `guide.md` — the language for agents: what it is, the official references, a cheat sheet and a
  worked example, how to run it (command line, module, workspace), common problems. Its
  `<id>/workspace` module provides it as `guide`; `fhir/lang/workspace`'s `workspace-guide` loads
  it and fhir-mcp serves it as `learn://<id>` (else the hub's own `learn/<id>.md`). The repo's
  `tests/guide-test.rkt` translates every example and checks the claims the text makes.
- `.claude/skills/<id>/SKILL.md` — the workflow WITHOUT MCP: the command-line loop, the module and
  Racket API, measures/operations; it points to `guide.md` rather than repeating it. Every command
  in it was run.
- `scribblings/<id>.scrbl` — the human manual and API reference; `tests/docs-test.rkt` renders it
  and fails on a broken reference to the package's own sections or bindings.
The family-wide skills (`fhir-authoring`, `fhir-cli`, `fhir-serving`, here) keep the cross-language
material and point to a language's own skill.

## Package setup
From `~/Projects` with the repos side by side (dependency order):
```sh
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx fhir/fhir-validation cql fml fsh fhir/fhir-server fhir-examples
raco setup --check-pkg-deps --pkgs fhir fhir-spec fhirpath vcl fhir-tx fhir-validation cql fml fsh fhir-server fhir-examples
```
This repo's root holds the family README/LICENSE and these notes; `fhir/`, `fhir-spec/`, `fhir-tx/`,
`fhir-validation/` and `fhir-server/` are its five packages. Commands: `raco fhir` (foundation),
`raco fhir-tx`, `raco fhir-validate`, `raco fhir-server`, and per language `raco fhirpath|cql|fsh|vcl|fml`.

**Standalone tools** (`build-tools.sh`): the twelve command-line tools as executables that run without
Racket — the READMEs lead with them, Racket and `#lang` come second. Each is `raco exe` of a one-line
launcher that requires the tool's raco command module BY COLLECTION (a file path to `cli.rkt` would
make `raco exe` see a module both as a library and as a path), with `++lib` for every module the tool
loads by name at run time (the FHIR towers, the languages' `<id>/support`, the operation modules,
optional features — the table in the script; a tool that adds a `dynamic-require` must add it there),
then one `raco distribute` into `dist/{bin,lib}`, and fhir-spec's packages into
`dist/share/fhir-packages`. Three things make the executables work: `fhir/spec-package` also searches
`FHIR_PACKAGE_PATH` and `<exe>/../share/fhir-packages` (no collections in a standalone build);
`fhir/parallel` runs sequentially when there is no Racket executable to start workers on; and no
module may declare a runtime path to a directory it does not read at run time (`raco distribute`
copies runtime paths — sql-on-fhir's `fetch` destination was one). Out of the executables by nature:
the conformance runners, the generators, and anything that loads a user's `.rkt` file.

## Diagnostics: machine-readable feedback (`fhir/diagnostic`)
Every language reports errors as one value, `(diagnostic lang phase severity message loc)` with
1-based line/column, the character position and span, and the source file. It renders three ways:
`file:line:col: fsh parse error: …` plus the source line and a caret; JSON; and a FHIR
OperationOutcome with the standard `operationoutcome-issue-line`/`-col`/`-source` extensions.
- Lexers keep brag tokens but fill their positions (`lexer-srcloc` + `positioned`). Text no rule
  matches is a positioned `lex` diagnostic.
- `exn->diagnostic` turns a parser's exception into one: brag's message becomes words ("unexpected
  caret sequence `^short`"). When the failure sits on the LAST token, a probe re-parses with a copy
  of that token appended; if the error moves past it, the input ran out ("the entity ends after
  `=`"), otherwise the token itself is unexpected.
- Carriers: FSH and FHIRPath raise `exn:fail:diagnostic` (a subtype of `exn:fail`, with
  `prop:exn:srclocs`); CQL puts it in `cql-error-diagnostic`, FML in `fml-error-diagnostic`; VCL attaches it to its
  `invalid-encoding` payload (`attached-diagnostic`). CQL definitions remember where they start
  (`attach-loc!`), so translation errors point at the enclosing `define` and name it.
- CLIs (`raco fsh|cql|vcl|fml|fhirpath`, `raco fhir-validate`) take `--format text|json|outcome`.
  Text goes to stderr; json/outcome go to stdout; exit 1 on an error. `-h`/`--help` (on any
  `raco fhir` subcommand too) prints usage to stdout, exit 0; a usage error, unknown option or
  unreadable input file is one line on stderr, exit 2 (never a stack trace). A leading `#lang` line is
  blanked, not removed, so line numbers stay true. FSH parses per file (positions name the file),
  reports every file's errors, and positions compile errors at the failing entity's header.
  `validate` reports malformed JSON where reading stopped.
- The published-package oracle (every example HL7 published validates) caught a validator false
  positive: a value/pattern discriminator whose path ends at a repeating element (`category.coding`)
  was compared against the list, not its members. `json-at` fans out at the path's end now.
- Servers generated from a package resolve its `dependencies` from fhir-spec (validation context
  and search catalog: IG, dependencies, core).
- The FSH -> package -> server loop found its last gaps on both sides (250 -> 283/283). Snapshot
  generation (`sd/snapshot.rkt`) merged an element INSIDE a slice (`component:a.code`, same path as
  `component.code`) into the unsliced element: it is now matched by id, built from the unsliced
  definition, placed under its slice (skipped ancestors and slices created first), and the datatype
  expansion walks ids — snapshot conformance card 143/148 -> 476/478 (108 more elements now exist
  to compare). FSH: see the fsh repo's CLAUDE.md (required values built recursively, `System#code` on
  a `code`, `valueX` on a choice narrowed to X, named-slice positions).
- Errors accumulate. CQL: `compile-library/errors` translates every statement, records each failing
  definition once (positioned at its `define`), and a reference to a failed definition does not
  report again; `raco cql` lists them all. FSH: each rule remembers its position (the token after
  its `*`); `compile-doc/diagnostics` adds rule-level checks (an element path whose first step is not
  an element of the base type: "`nmae` is not an element of Patient", at the rule), and the entity
  still compiles. The check is gated by zero diagnostics on IPS, mCODE and the golden corpus.

## The spec-author's loop (`fsh/check.rkt`, `raco fsh check`; fhir-examples's `bench.rkt`)
`check-fsh-project dir [#:capability id]` runs everything this repo knows about one FSH project and
reports it as `fhir/diagnostic`s positioned in the FSH: compile + rule-level diagnostics
(fsh/project), every `#example` instance validated against its base type and claimed profiles (the
project's own artifacts packed as a package ahead of its dependencies and core — the context the
compiler used, `project-sd-packages`), and with a CapabilityStatement the generated server's unmet
requirements (SHALL = error). A validation issue (`Observation.component.value[x]`) is traced to the
instance rule that wrote that element (`trace-rule`: the type root dropped, brackets and choice
suffixes normalised, the longest leading run of steps wins; a datatype-rooted path matches anywhere)
and names the profile rule that constrains it. It lives in fsh (`fsh/check`), which depends on
fhir-validation. mCODE checks clean (179 examples, 0 diagnostics, 0 unmet for its sender CS);
fsh's `tests/check-r4-test.rkt` pins three planted mistakes to their lines.
It exposed a validator recall gap: an entry matching exactly ONE slice (pins decidable) is held to
the slice's own children — cardinality, fixed/pattern, required bindings — recursion stays with the
unsliced walk. A choice variant the slice does not allow (`valueString` in a slice whose
`value[x] only Quantity`) is an error. Found writing fsh's guide (2026-11-09): it went unreported
whenever ANOTHER slice of the element pinned nothing at the discriminator, because one undecidable
slice switched off every slice's member checks. Now only a slice whose constraint there we cannot
read does (`slice-unconstrained?`: a slice with no fixed/pattern value, required or extensible
binding or type profile at or below its discriminator paths claims no entry). Gates unchanged: fp=0,
0 over-reported, IG validation 260 clean, published mCODE 283/283.
`raco spec-bench` (the fhir-examples repo) turns a published IG into prose -> FSH tasks (one leaf profile and its examples
removed; the prompt gives the IG's words about it and names every element it constrains, never the
constraint values) and scores a candidate four ways: `check` errors; facet fidelity against the
published differential; the published examples accepted by the candidate's profile; the candidate's
examples valid under the published profile. `run --model '<cmd>' --rounds n --timeout s` asks any
shell command (prompt and answer through files; past the timeout its process group is killed) and
feeds `check`'s diagnostics back between rounds. Baselines: the IG's own FSH (TumorSize 28/34
facets — the compiler's ceiling) and empty (0). Results: that repo's README and `results/`.

## Operations as procedures (`fhir/operation`, `fhir/data-source`)
A FHIR operation is an OperationDefinition plus an implementation, with nothing about HTTP: a
procedure whose keyword arguments are the definition's parameters. Three ideas carry the API:
```racket
(apply-operation "StructureMap/$transform" qr #:srcMap fml)    ; apply by reference
(define transform (operation "StructureMap/$transform"))       ; a reference resolves to a procedure
(~> qr (transform #:srcMap fml) (ensure-valid) ($snapshot))    ; thread a value through operations
```
Applying is `(op [subject [parameters]] #:name value …)`: the subject is the resource the operation
applies to (what `~>` threads), a Parameters resource carries inputs known only at run time, and a
list value gives several values. A reference is the canonical (a `|version` is ignored), the
OperationDefinition, `"$code"`, or `"Type/$code"` when a code is ambiguous. Inputs are checked against
the definition (an unknown keyword is an error listing the parameters it takes; cardinality); strings
for integer/decimal/boolean parameters are converted (HTTP query values). The result is the `return`
resource, or a Parameters of the outputs; a failure raises `exn:fail:operation` with an
OperationOutcome (`apply-operation/outcome` returns it). `invoke op subject inputs` is the host form
(the server's request Parameters as an inputs hash).
Implementing one: `(make-operation od run #:subject name)` — `run : inputs subject -> result`;
`subject` names the input the subject fills (`resource` for $validate, `content` for $transform), or
is #f when the operation applies to the subject itself (instance level: a ValueSet into $expand);
`register-operation!` makes it resolvable (each implementing module registers when it loads).
Context comes from parameters: `current-data-source` — FHIR data as a value: in memory / Bundles
(`resources->data-source`), a directory (`directory->data-source`), or the store (fhir-server's
`store->data-source`, which also does real FHIR search) — and `current-sd-packages` (profiles,
value sets). Implemented, each by the package that does the work, under the core OD canonicals:
`$snapshot` (fhir, `fhir/sd/operations`), `$validate` and `ensure-valid` (fhir-validation,
`fhir/conformance/operations`), `$expand`, `ValueSet/$validate-code`, `$lookup`, `$translate`
(fhir-tx, `fhir/terminology/operations`; the service's `tx-*` functions answer FHIR JSON,
FHIRPath's `%terminologies` closures wrap it), `$transform` (fml, `fml/operations`: runs FML given as
`#:srcMap`), `$evaluate-measure` (cql, `cql/measure`: over any data source; the R4 OD, which returns a
MeasureReport). fhir-server serves every registered operation its IG's ODs name, at every level they
declare (operations on Resource on every served type), with the store as data source; US Core
`$docref` is built there from the IG's own OD (it needs the store's search).
`fhir-examples/examples/pipeline.rkt` maps a QuestionnaireResponse to a Patient with FML,
validates it and checks its gender against the core value set — by reference, no server.
**A StructureMap is a value the same way** (fml/registry): `(structure-map "http://…/StructureMap/x")`
resolves by canonical (maps registered in the process, `current-data-source`, the packages — `sd-index`
indexes StructureMap and ConceptMap too) into a typed procedure from its source structure to its
target (`smap-source`/`smap-target`; `compose-maps` checks the types); `$transform` takes `source`
(a canonical) and `sourceMap` (a resource) as well as `srcMap`. `raco fml check` is the
spec-author's loop for maps (findings positioned in the FML; examples transformed and validated),
and a project of FSH structures runs it on its `.map` files under `raco fsh check` — the worked
project is `fhir-examples/examples/intake-maps` (a logical model, a profile, the map between them, an
instance; packed as one package; the map applied by canonical from it).
**The module system is the FHIR registry** (`fhir/registry`): a `#lang fsh` module registers its
profiles, value sets and code systems when instantiated, `#lang vcl` its value set, `#lang fml` its
StructureMap (`register-resources!` with the module as source; a canonical defined differently by two
modules is an error naming both). Every resolver looks there between the data source and the packages
— `sd/operations` `resolve-structure-definition` (`#:profile`), the profiles a resource claims in
`meta.profile` (fhir-validation), `sd/logical` (FML's `uses`), the terminology resolver (fhir-tx),
`resolve-structure-map` (fml) — so requiring a module is enough for what it defines to be found;
`current-data-source` is for DATA. A `#lang cql` module registers its Library (`cql/library`:
name, version, the source as text/cql content, url `<base>/Library/<name>`), and measure
evaluation's library and include lookups see registered libraries after the data source's.
`.fhir6` instances are data, not conformance resources, and are not registered.
**An inline capability operation is an operation value too** (`declared-operation`, capability/
operations.rkt): `(operation $screen … #:handler h)` in `#lang fhir/capability` defines `$screen` as a
fhir/operation value — the same handler with an in-process request, a typed result returned as JSON,
registered by its canonical (`urn:fhir-capability:operation:screen`) and provided — so a pipeline is
declared once, served and applied in-process (fhir-examples/screening/app.rkt's `$screen`).
**Over HTTP, the CapabilityStatement follows from what is served** (fhir-server's
`capability/operations.rkt`): `(serve-operations (list $validate $expand) #:port 8080)` serves just
operations, `(operations-app ops)` is that app; in `#lang fhir/capability`, `(operation "ValueSet/$expand")`
(a reference) or `(operation $validate)` (a value in scope) exposes an existing operation beside the
declared resources and inline `(operation $ping #:system … #:handler h)` declarations. All share one
adapter, `operation->entries` (ig-server uses it too): routes at every level and type the definition
declares, the request Parameters as inputs, the stored resource as the instance-level subject (the
app's repository through `current-app`, or `#:read`), `#:around` for context. Each served operation's
CapabilityStatement entry (`operation->rc`) carries its own canonical, and derive-capability-statement
advertises every routed operation: one on Resource under each declared type (at rest.operation when
there are none — FHIR has no `Resource` rest.resource), one on an undeclared type under a
rest.resource entry of its own. Dispatch falls back to an operation's `Resource` route for any type.
`examples/operations-server.rkt`; `tests/operations-http-test.rkt` (both paths, through the router).

## The terminology server (fhir-tx)
The service is a resolver (`(url [version]) -> resource | #f`) over per-package indexes (`index-of`,
one lazy table per .tgz, shared) with a per-CodeSystem concept index (`cs-index`: code -> concept,
parent, children, weakly cached on the resource) and an expansion cache per resolver. The sources
are `terminology/index.rkt` (the package and resource indexes, versioned resolution, the concept
tree's questions, the Member of an expansion with its accessors) — pure jsexpr, tested without the
tower or VCL; `service.rkt` is the operations over them. `$expand`
follows `compose.include.valueSet` (intersection; a system include narrowed by it), a pre-expanded
ValueSet (expansion, no compose), every FHIR filter operator including `generalizes` and
`descendent-leaf`, `useSupplement` designations/properties, and the server-level version policy.
Operations: `$expand`, ValueSet and CodeSystem `$validate-code`, `$lookup`, `$subsumes`,
`$find-matches` (properties, exact or substring), `$translate`, `$closure` (tables in the process),
`terminology-operations` lists them; `current-terminology-capabilities` derives a
TerminologyCapabilities from the packages' CodeSystems. The operations' data-source resolver asks a
searching data source (the store) for the url instead of scanning. `raco fhir-tx serve` puts it all
over HTTP through fhir-server's operations app, which now answers `GET /metadata?mode=terminology`
(an `app`'s `metadata` hash) and routes a batch Bundle entry by entry when the app has no
transaction processor. FHIRPath's `expand()` takes a Parameters, `validateVS()`/`translate()` a
Coding or CodeableConcept and a system. CI runs the service, operations and router tests and
`raco fhir-tx tck` on every push. The includes-by-value-set and pre-expanded fixes took the suite
from 463 to 473/553 (floor 473).

## How-to-use docs
User-facing usage/how-to lives in `.claude/skills/` — `fhir-authoring` (write/run the langs, `raco fsh
check`), `fhir-cli` (`raco fhir`, `raco fhir-validate`), `fhir-serving` (`raco fhir-server`: store + HTTP).
This file is the architecture reference; keep the how-to in the skills.

## Conventions
- Contracts on module boundaries (`contract-out`); `match` over multi-branch `cond`.
- Every module has a `module+ test` with living examples; `raco test` runs them.
- Prefab `field-spec`/`choice-group` embed in generated form macros (read back without the defn).
- **Leaf helpers live in `model/leaf.rkt`** (`pv`/`listify`/`node-str`) — never re-define them in a
  consumer. The fhirpath-flavored collapse (`item->system`-based `leaf->string`) stays with its
  users (capability/runtime, http/router) since model/ must not depend on fhirpath/.
- `now()`/`today()`/`timeOfDay()` read ONE clock (local + real utc offset); temporal tz
  normalization applies only when BOTH operands carry a time, and minute shifts carry the day
  through the calendar (`fhirpath/temporal-ops.rkt` — both were real, test-caught bugs).

- **Parallelism is worker processes, not places or threads** (`fhir/parallel`): `parallel-map`
  over a named function, items dealt as workers finish, results in order; ship paths and shard
  numbers, not data. Racket CS places share a heap (a GC stops them all) and made the round-trip
  corpus slower; processes made it 2.4x faster on four cores. `FHIR_WORKERS=1` is the sequential
  switch. Used by `raco fhir roundtrip-tck` and `raco fhir check`.

## Design style — HTDP + beautiful Racket
This codebase is written in the **How to Design Programs** idiom; keep new code in the same style:
- **Data definitions first.** Before the code, state the data as an itemized comment ("An ELM-Expr is one
  of: literal | nary | … / A CqlValue is one of: …", see `cql/value.rkt`, `cql/interp.rkt`). Each variant
  gets a prefab struct.
- **Functions follow the recipe.** Signature + one-line purpose above every function
  (`;; f : A B -> C   purpose`); examples/tests live in `module+ test`. Prefer many small, named,
  individually-testable functions over one big branch.
- **Structural recursion from the data.** A function over a data definition is a `match` with one clause
  per variant, recurring on sub-parts — e.g. `eval-elm`/`compile` are the templates for ELM/CQL ASTs.
- **Represent the catalogue as data.** When a set grows large (operators, field specs), make it a
  table/registry keyed for O(1) dispatch rather than an ever-growing `case` — the CQL operator registry
  (`def-op!`/`apply-op`) and `fhirpath/functions.rkt`'s `fn` registry are the models. This is both more
  HTDP (the set is data you can count/document/test) and more performant.
- **Beautiful-Racket touches:** immutable prefab values, `match`, contracts at boundaries, reuse existing
  primitives (don't reimplement decimal/temporal/UCUM — thread through `fhirpath/`), and fail-open where
  a result is genuinely undecidable. Guard performance with the relevant bench/coverage harness.
- When adding a language feature, add its **data variant + emitter clause + interpreter clause together**
  (one schema, two directions) and a `module+ test`; then re-run the conformance harness and ratchet the
  floor — never regress.

## Verify
```sh
raco test -p fhir fhir-spec fhirpath vcl fhir-tx fhir-validation cql fml fsh fhir-server fhir-examples
racket fhir/examples/patient.fhir6       # prints FHIR JSON
racket fhir/examples/demo.cql            # #lang cql — prints ELM JSON
raco fhir check all                      # determinism guard (r6 r4 r5)
raco fhirpath --tck r5                   # FHIRPath conformance (or r4); raco fhirpath --ucum-tck
raco cql --tck                           # CQL expression conformance; raco fml --tck
raco fhir roundtrip-tck r5               # parse+serialize round-trip the whole R5 corpus (or r4)
raco fhir-tx tck                        # the terminology suite
raco fsh check ../fsh/tests/vendor/mcode-4.0.0 --capability mcode-sender-patients-in-group   # exit 0
```

## Round-trip conformance corpus (`tests/example-roundtrip-r{4,5}.rkt`, `tests/example-harness.rkt`)
A broad serializer/type-tower test: `roundtrip-result` parses a resource leniently (`from-json
#:lenient?`), serializes (`node->jsexpr`), re-parses, and requires the serializer be **idempotent**
(stable + re-parseable). `run-dir` drives the vendored HL7 `fhir-test-cases` examples
(`tests/vendor/fhir-examples/r{4,5}/`); `run-package` streams every resource in a core `.tgz`. Current:
**R5 77 examples + 2968 package, R4 72 + 4581 — all round-trip** (unknown resource types, e.g. a
resource renamed across versions, are skipped via `type-registered?`). R4 and R5 run in separate
processes so the towers don't double-register. This drove a `from-json` robustness fix: a nested value
whose JSON shape isn't an object (an R4-style string where R5 expects a complex type) now returns `err`
(dropped under lenient) instead of throwing — lenient parsing never crashes.

## Capability / operation lang (`#lang fhir/capability`, fhir-server's `capability/`)
Declare-and-derive: a module DECLARES what a FHIR app supports and the lang DERIVES the
CapabilityStatement (the `/metadata` artifact) + one OperationDefinition per operation, so metadata
reflects exactly the installed capabilities and can't drift (fhir4s's key idea). Top forms —
`(server #:mode …)`, `(resource Type #:interactions (…) #:search-params ([n type]…) #:repository r)`,
`(operation $code #:on Type|#:system #:in ([n type min max]…) #:out (…) #:handler h)` — are
**partitioned from plain Racket code** (handler `define`s / `require`s) by a custom `#%module-begin`
(`capability/module-begin.rkt`) and validated at **phase 1** against the R6 registry
(`type-registered?`, interaction/search-param code sets in `capability/interaction-codes.rkt`,
param types). The emitted body puts pass-through forms first, then the derived nodes + the assembled
`app`, in one module body so declaration→handler forward refs resolve (handlers must not depend on
`app`). `capability/derive.rkt` builds each node via jsexpr→`from-json` (`op-code->canonical` is the
`rest…operation.definition` ⇄ `OperationDefinition.url` join key). `capability/runtime.rkt` is the
in-process app: `repository`/`operation-handler`/`app`/`request` structs (struct-of-closures like
`tx-service`), `dispatch` (routes an interaction or `$op` over typed nodes; undeclared → an
`OperationOutcome`; validates operation inputs against the derived OperationDefinition via `navigate`),
and OperationOutcome/Bundle constructors. A `request` is plain data, so the `http/` layer (below) serves
it with no changes here. Runs like other langs (`racket examples/patient-app.rkt` prints /metadata).
Phase note: `module-begin.rkt` requires `fhir/r6/types` for-syntax (registry) and the runtime bindings
at phase 0; `declare.rkt` requires the emitted `rc-*`/`operation-entry` constructors **for-template**
so they resolve at the user module's phase 0.

`#:repository` is now **optional**: a resource declared without one gets `make-default-repository`
(`capability/runtime.rkt`) — a generic in-memory store implementing exactly the declared interactions,
with **search** that evaluates each declared search-param's FHIRPath expression against stored
resources. A search-param is `[name type]` or `[name type "FHIRPath"]` (the expression drives search,
not the CapabilityStatement, which advertises only name/type). Search-params flow as `(list name type
expr)` triples through declare→derive→runtime.

## HTTP layer (fhir-server's `http/`, `raco fhir-server serve`)
A small from-scratch HTTP/1.1 server over `racket/tcp` (web-server-lib isn't in this minimal Racket) that
serves a capability `app`. `http/router.rkt` is a **pure** function `handle : app method path query body →
(values status jsexpr)` mapping the FHIR REST grammar onto `capability/runtime`'s `dispatch`:
`GET /metadata`→CapabilityStatement; `GET/POST /{Type}` → search/create; `GET/PUT/DELETE /{Type}/{id}`;
`GET /{Type}/{id}/_history/{vid}`→vread; `GET|POST /${op}`, `/{Type}/${op}`, `/{Type}/{id}/${op}`→invoke
(GET query → a Parameters input, POST → the body). It maps the returned node to a status (OperationOutcome
`issue.code`→404/400/500, create→201). `http/server.rkt` `serve-app : app #:port → shutdown-thunk` parses
request line + headers + Content-Length body, one request per connection (Connection: close), each on its
own thread. `raco fhir-server serve <app.rkt> [port]` dynamic-requires the module's `app` and serves it.
`tests/http-test.rkt` starts the example server and drives it over a real socket. Because the capability
lang is R6, served resources/search evaluate against the R6 tower.

## Snapshot generation + validation (`fhir/sd/`, fhir-validation's `conformance/`)
`sd/sd-index.rkt` (`resolve-sd-raw`, moved from `fsh/`) resolves base/profile SDs from the R5
core package. `sd/snapshot.rkt` (`generate-snapshot`) is a reduced-ProfileUtilities merge:
re-root the base snapshot, element-by-path merge (diff overrides; `constraint` **accumulates**),
`ensureBase`, and named-slice re-rooting (a slice inherits the base element at its path). Deferred:
reslicing, discriminator inference, choice-`[x]` slice expansion, contentReference. `sd/element-index.rkt`
turns a snapshot into `child-elements`/`slices-of`/`by-id` lookups + `type-index` (the datatype jump,
cached; `opaque-type?` guards Resource/Element/…). `conformance/validate.rkt` validates a **raw jsexpr**
resource (lenient parsing would hide unknown elements — the typed node is used only for invariants)
against its base type + `meta.profile` + supplied profiles (snapshots generated on demand): a
`walk` recursion applying pure rules — cardinality, unknown-element (lenient on choice
variants), primitive format (reuses `primitives/` ctors), fixed[x]=/pattern[x]⊆, required binding (via a
`tx-service`; only fires when the VS demonstrably expands offline), value/pattern-discriminator
slice `min` (multi-discriminator and `$this` supported; the pinned value is fixed[x]/pattern[x] on
the slice's `<slice-id>.<disc-path>` element; any non-value/pattern discriminator or unresolvable
pin → fail-open — this was a silent stub until the quality loop made it real and test-pinned); plus
FHIRPath invariants (`#:invariants?`, **on by default** since 2026-11-05). The cardinal rule is
**fail-open — never report on anything undecidable** (unresolvable type/profile/VS, unparseable
expression). Each constraint runs at its element with `%resource`/`%rootResource` = the resource and
`%context` = the focus (without that binding `%resource.type` fell to the focus and sdf-8/sdf-8a
"failed" on 593 of the core package's own StructureDefinitions), a violation is a singleton false
only, the universal base keys (`ele-1`, `ext-1`, `dom-*`) are denylisted, and a constraint defined on
a SLICE is left unchecked (its members are not decided here; US Core's us-core-16 "NPI must be 10
digits" would otherwise hold every identifier). `conformance/tests/invariants-corpus-test.rkt` runs the
whole R5 core package with invariants on and buckets the violations by key: 2957/2968 resources carry
no error-level one, and the 11 are the package's own — ten logical models with a baseDefinition and
no `derivation` (sdf-27), CodeSystem/fhir-types against the Shareable profile it claims (scs-1);
cnl-0 (a machine-usable name) and csd-2 are warnings the package breaks 1,286 times. The gates below
run with invariants on: the validator differential's recall went 17 -> 18/26 at fp 0. Result is an `OperationOutcome` (via `from-json`). CLI: `raco fhir-validate
<resource.json> [profile.json…]` (exit 1 on error), `raco fhir snapshot <sd.json>`. Tests:
`conformance/tests/validate-test.rkt` (authored case per check, asserted by `{code, path}`),
`validate-corpus-test.rkt` (the **never-over-report gate**: 0 errors over 200 valid R5 resources), and
`snapshot-test.rkt` (property checks vs the R5 base snapshots). Because the official validator manifest
records the Java validator's exact messages + line/col (unreproducible from scratch),
`tests/validate-diff-test.rkt` runs a **case-level recall differential** over a curated R5,
dependency-free subset of `fhir-test-cases/validator` (`tests/vendor/validation/` + the recorded
`outcomes/java`): compare our error verdict vs the reference per case (clean/dirty), hard-gate
**false-positives = 0**, and ratchet **recall** (currently **9/16** dirty cases caught; the rest are
choice-type narrowing, invariants, JSON-duplicate detection, decimal-regex edges — advanced/risky).
This recall number is the real coverage signal (authored cases + the valid-corpus gate cover
correctness + never-over-report). Recall is now **14/16** (fp still 0). **Duplicate JSON keys** are
caught: `serialize/read-json.rkt`'s `read-fhir-json/duplicates` returns the jsexpr *and* the dotted
paths of any collapsed duplicate keys (default `read-fhir-json` is untouched — the roundtrip corpus
path is unchanged); `validate-issues #:duplicates` turns each into one `invalid` error (a fact the
reader observed, so never a false positive — the CLI reads via this path). The last **2 misses are the
`ctm-1` CareTeam cases and stay deferred by design**: the constraint is `onBehalfOf.exists() implies
(member.resolve() is Practitioner)`; `member.resolve()` is empty offline and our engine returns empty
for `empty is Practitioner` (**spec-correct**, `is`-on-empty = `{}`), so `true implies {}` = `{}` =
holds. The Java reference flags it only via a **non-spec `is`-on-empty = false** quirk. Catching it
would (a) break FHIRPath spec-conformance (the TCK-1044/1044 engine) and (b) risk over-reporting —
forcing invariants on across all types over-reports on **307/2968** valid R5 resources (`sdf-8`/`sdf-8a`
StructureDefinition constraints dominate), violating fail-open. Not worth 2 metric points; both cardinal
invariants (spec-conformance + never-over-report) win. **Choice types (`value[x]`) are validated**: a
matched `value<X>` key is narrowed to its concrete type against the element's `type[]`
(`variant-type`/`matched-type`/`allowed-key?`); a disallowed variant is an unknown element and doesn't
satisfy the required `value[x]` (bad2), the narrowed type drives the primitive check (bad3 boolean) and
recursion into the chosen complex type (obs-decimal → Quantity.value); it fails open when the element
declares no types. **Decimals are validated on their lexeme**, not a stripped number (validate no longer
strips jnum at entry; `primitive-issues` feeds `make-decimal` the `jnum-lexeme`, or `number->string` for
plain-number input from the CLI/authored paths — checking a stripped number would flag every valid
decimal). Also: canonical values ending in `|`, resource-`id` grammar, empty-array. Perf (behavior-
preserving): `parse-fhirpath` is memoized; `make-element-index` precomputes O(1) `children`/`slices`
lookups; the base target index is fetched via the cached `type-index`. `drop-false` lives in
`serialize/jsexpr-util.rkt` (shared).

## Persistence engine (fhir-server's `store/`, tests/fhir-store-test.rkt)
An embedded, in-process FHIR store on **SQLite** (transactional CRUD/versioning/search):
- `store/fhir-sqlite.rkt` — a `fhir-store` (path + db-lib connection-pool), every pooled connection
  configured `WAL`/`synchronous=NORMAL`; schema: `fhir_resources` (current version, PK
  (resource_type,id)), `fhir_history` (immutable, + SHA-1 content_hash), `fhir_token_index`,
  `fhir_reference_index` (+ covering indexes). Writes only through `call-with-store-transaction`;
  no global state — handles are explicit everywhere.
- `store/fhir-engine.rkt` — `fhir-create!/read/vread/update!/delete!/history/search` (delete removes
  the current row + indexes; history is immutable and survives; vread reads it). The search-param catalog is
  DATA (`default-search-params`, per-type `search-param` records with FHIRPath paths, extensible per
  call); the indexer evaluates each path with the repo's FHIRPath engine over the leniently-parsed
  typed node and decomposes CodeableConcept/Coding/Identifier → token rows, Reference → reference
  rows — reindexed inside the SAME transaction as the write, so indexes can't drift. Search:
  `system|code` tokens, `Type/id` references, `_lastUpdated` with ge/gt/le/lt prefixes; multiple
  params AND via EXISTS subqueries. Meta stamping: `meta.versionId`/`lastUpdated` on every write.
- `tests/fhir-store-test.rkt` — end-to-end: batch insert, indexed search, WAL snapshot isolation +
  parallel writers. Deps: `db-lib`.

### IG-driven serving (`store/ig-params.rkt`, `store/serve.rkt`)
The IG/core package is the single source of truth for search: `search-params-from-package` streams
`package/SearchParameter-*.json` from a `.tgz` and builds the per-type catalog from the resources'
own `code`/`type`/`expression`. Multi-base expressions (`Patient.name | Person.name`) are narrowed
**at the AST level** (parse → split `union` branches → keep those whose chain-head is the base type
(seen through `.where(…)` wrappers) or unrooted → re-print via `fhirpath->string` — never string
surgery). The reference-param `.where(resolve() is X)` guard is dropped (`drop-resolve-guard`): the
reference index stores the target type, so the restriction is enforced by the search value
(`Patient/id`), not by resolving at extraction time (which would drop references to not-loaded
resources). `merge-search-params` layers overrides per (type, name).

**Transaction/batch Bundles** (`store/bundle.rkt`): `process-bundle!` implements the FHIR
transaction semantics — `urn:uuid` fullUrls get server ids up front and every reference to them is
rewritten to `Type/id` BEFORE applying; entries apply in spec order (DELETEs, POSTs, PUTs);
`transaction` runs in ONE store transaction (the engine's `create-in!`/`update-in!`/`delete-in!`
connection-taking variants — any failure rolls back everything), `batch` per-entry with error
response entries; the response is a `transaction-response`/`batch-response` Bundle mirroring
request order. `load-bundle!` also accepts `collection` (a batch of creates — the Synthea shape); with `#:tower`
(the store's type tower) a bulk load of 32+ entries extracts every resource's index rows on every
core first (`index-ahead` -> the engine's pure `index-rows`, `fhir/parallel`) and the transaction
only writes;
`raco fhir-server load <store.db> <bundle.json|dir>` prepopulates a store from files. The version chain is
CONTINUOUS across delete/recreate (create/update read `MAX(version_id)` from the immutable history
— writing v1 again would collide with the retained history row; caught by the bundle tests). The
`app` struct carries a `#:transaction` handler; the router routes `POST /` to it (400 on failure,
not-supported for apps without one).

**Audit + Provenance** (`store/serve.rkt` `#:audit? #t`): every committed write records an
AuditEvent (action C/U/D, restful-interaction code, recorded, outcome success, agent, entity → the
target) and creates/updates also a Provenance (target, recorded, activity CREATE/UPDATE, agent) —
written INTO the same store post-commit (never inside the audited transaction: WAL writer-lock),
so with AuditEvent/Provenance in `#:types` the trail is served + searchable over REST
(`GET /AuditEvent?action=C`). Writes to AuditEvent/Provenance themselves are exempt (no
recursion). Bundle writes are audited post-hoc from the request/response entry pairs.
`tests/audit-bundle-test.rkt` covers it all over a real socket (incl. rollback leaves no audit).

`store/serve.rkt` closes the chain package → catalog → CapabilityStatement → endpoints:
`store-repository` adapts the engine to `capability/runtime`'s `repository` (typed nodes at the
boundary via `from-json #:lenient?`/`node->jsexpr`); `make-store-app` derives the
CapabilityStatement from the catalog (`derive-capability-statement` — advertised searchParams ARE
the indexed ones, no drift) and `build-app`s store-backed repositories, so the existing `http/`
layer serves it unchanged: `racket examples/store-app.rkt` prints the derived /metadata,
`raco fhir-server serve examples/store-app.rkt` exposes CRUD + vread + IG-param search over SQLite.
`tests/store-http-test.rkt` drives it over a real socket (advertised params from the package;
token/reference searches hit the indexes; delete → 404 while history remains).

## Vendored conformance corpora (the ratchet table)
Every suite is vendored VERBATIM with a SOURCE.txt (url + retrieval date + what is skipped and
why), driven by an execution harness, and gated by a floor that only rises:

| suite | source | harness | current |
|---|---|---|---|
| FHIRPath | HL7 R4/R5 XML suites | `raco fhirpath --tck r5\|r4` | 1044/1044, 932/934 |
| CQL | cqframework/cql-tests | `raco cql --tck` | 1820/1823 |
| FML | fhir-test-cases r5/structure-mapping | `raco fml --tck` | 6/6 exec, 15/15 parse |
| **FML corpus 2** | **ahdis/matchbox's maps + the FHIR mapping-language tutorial (13 steps over logical models); FHIR/interversion R3/R4 maps parsed in CI** | `raco fml --tck` (fml repo, `tests/matchbox-harness.rkt`) | **43/43 parse, 17/17 run, tutorial 37/37** (2 stale result files set aside with evidence); interversion 332/332 parse |
| **FML StructureMap form** | **every corpus map through its StructureMap and back; the tutorial run from the emitted resources by canonical; our StructureMap vs matchbox's rule by rule** | `raco fml --tck` | **58/58 round trip; 37/37 from our resources** (30/37 from the reference's, several predate their .map); **21/31 rules equal** |
| **FML check** | **every corpus map checked against its structures** | `raco fml --tck` | **55/58 without an error finding** — the 3 are real (R4 elements R5 dropped; a typo in syntax.map) |
| **UCUM** | **FHIR/Ucum-java UcumFunctionalTests.xml** | **`raco fhirpath --ucum-tck`** | **573/573** (all sections) |
| VCL | the spec page's 60 examples | `raco test vcl/` | 60/60 parse + fixpoint |
| round-trip | HL7 examples + R4/R5 core packages | `raco fhir roundtrip-tck r5\|r4` | 2968+77, 4581+72 |
| **IG examples** | **US Core 9.0.0, IPS 2.0.1 packages** | `tests/ig-examples-r4-test.rkt` | **274/274 parse+round-trip** |
| **IG validation** | **US Core 9.0.0, IPS 2.0.1: every example vs the IG profiles it claims** | `tests/ig-validation-r4-test.rkt` | **260/260 clean** (0 false positives) |
| **IG search** | **US Core 9.0.0 examples, R4 core + US Core SearchParameters: each example found by its own values** | `tests/ig-search-r4-test.rkt` | **2368/2368 probes** |
| **IG server** | **a server generated from US Core 9.0.0: all 255 resources load through validation** | `tests/ig-server-r4-test.rkt` | **0 unmet requirements** (SHALL/SHOULD/MAY; auth aside) |
| **IG FHIRPath** | **the same IGs: profile invariants on their examples + SearchParameter expressions** | `tests/ig-fhirpath-r4-test.rkt` | **6082 invariant checks, 0 fail** (2 dom-3 spec-conflict errors); **1330/1330 search** |
| **snapshot** | **fhir-test-cases rX/snapshot-generation** | `conformance/tests/snapshot-conformance-test.rkt` | **paths 80/80, card 476/478, types 235/236** (id-matched) |
| validator | fhir-test-cases validator + java outcomes | `tests/validate-diff-test.rkt` | **fp=0**, recall 18/26 (67 cases) |
| FSH | SUSHI golden corpus (hand-authored pairs) | `fsh/tests/golden-test.rkt` | 22/22 fwd + round-trip |
| **FSH real IG** | **IPS 2.0.1's own FSH vs its published package** | `fsh/tests/ig-ips-test.rkt` (fsh repo) | **0 compile errors; 94/114 exact, 108/114 complete; 438/438 differential elements** |
| **FSH -> package -> server** | **mCODE 4.0.0's FSH compiled and packed here, served by a generated server: its examples vs its profiles** | `tests/fsh-ig-server-r4-test.rkt` | **283/283 validate** (as the published package); 0 unmet requirements |
| **FSH real IG 2** | **mCODE 4.0.0's own FSH (dependencies US Core 6.1.0 + Genomics Reporting 2.0.0 from sushi-config.yaml) vs its published package** | `fsh/tests/ig-mcode-test.rkt` (fsh repo) | **0 compile errors; 311/349 exact, 339/349 complete; 472/473 differential elements** |
| **FSH real IG 3** | **Da Vinci PDex Plan-Net 1.2.0's own FSH vs its published package, both fetched from packages.fhir.org (US Core 3.1.1 through its version-alias stub)** | `fsh/tests/ig-plannet-test.rkt` (fsh repo) | **0 compile errors; 84/109 exact, 99/109 complete; 321/321 differential elements** |
| **FSH real IG 4** | **Da Vinci HRex 1.1.0's own FSH vs its published package (three US Core versions in context, version-pinned Parents)** | `fsh/tests/ig-hrex-test.rkt` (fsh repo) | **0 compile errors; 31/46 exact, 46/46 complete; 138/138 differential elements** |
| **GoFSH (FHIR -> FSH -> FHIR)** | **the published IPS 2.0.1 package decompiled to FSH, compiled back, compared the same way** | `fsh/tests/gofsh-ips-test.rkt` (fsh repo) | **117/117 paired, 117 exact; 438/438 differential elements** |
| **FSH real IG 5** | **HL7 Genomics Reporting 2.0.0's own FSH (the commit whose ids match the package) vs its published package — OperationDefinitions, ConceptMaps, Bundle examples** | `fsh/tests/ig-genomics-test.rkt` (fsh repo) | **0 compile errors; 121/141 exact, 129/141 complete; 254/259 differential elements** (SUSHI-2 type-slice shape, post-publication drift named) |
| **GoFSH 2** | **the published mCODE 4.0.0 package decompiled, recompiled, compared** | `fsh/tests/gofsh-mcode-test.rkt` (fsh repo) | **349/349 paired, 341 exact, 345 complete; 472/473 differential elements** |
| **SUSHI importer** | **SUSHI 3.21.0's own importer tests (515 FSH texts, 111 with the error/warning SUSHI logs) as a parse + lint oracle: errors where SUSHI errs (same line), parses where it accepts** | `fsh/tests/sushi-importer-test.rkt` + `fsh/lint.rkt` (fsh repo) | ****514/515 verdicts agree (95 on SUSHI's line); 0 missed errors, 0 over-reports, 0 crashes**** |
| **invariants on valid resources** | **the whole R5 core package with invariants on, violations by key** | `fhir-validation/conformance/tests/invariants-corpus-test.rkt` | **2957/2968 with no error-level violation; the 11 are the package's own (sdf-27, scs-1)** |
| **Measure server** | **a server generated from CQF Measures 5.0.0: $evaluate-measure over its store, 2 eCQMs, 65 test patients** | `tests/measure-server-r4-test.rkt` | **60/65 individual reports** (5 named); 0 unmet requirements |
| **CQL execution** | **4 eCQMs over 76 test patients (cqframework/ecqm-content-r4-2021): populations vs expected** | `cql/tests/measure-test.rkt` (cql repo) | **71/76** (5 named corpus disagreements) |
| **CQL real libraries** | **32 published libraries (FHIRHelpers, CQF Measures, CQL IG) vs the reference ELM** | `cql/tests/elm-corpus-test.rkt` (cql repo) | **32/32 parse + compile; 770/803 defs ELM-equal** |
| **CQL over QI-Core** | **cqframework/ecqm-content-qicore-2024: 98 libraries vs the reference ELM (3.25.0); 4 eCQMs over 190 MADiE test cases vs their MeasureReports** | `cql/tests/qicore-elm-corpus-test.rkt`, `qicore-measure-test.rkt` (cql repo) | **98/98 compile, 1854/2144 defs ELM-equal; 188/190 cases** (2 named) |
| **CQL over QDM** | **cqm-execution's fixtures: 42 QDM libraries vs their ELM; 19 measures over 33 cqm-models patients vs cqm-execution's own assertions and the stored expected values** | `cql/tests/qdm-elm-corpus-test.rkt`, `qdm-measure-test.rkt` (cql repo) | **41/42 compile, 555/723 defs ELM-equal; 31/31 assertions, 16/26 stored** (10 named) |
| **SQL on FHIR** | **the shared suite from FHIR/sql-on-fhir.js, over the model generated from the 3.0.0-ballot package** | `raco sql-on-fhir tck` (sql-on-fhir repo) | **144/144** |
| **terminology** | **hl7.fhir.uv.tx-ecosystem 1.9.3** | **`raco fhir-tx tck`** (fhir-tx) | **473/553** |

A later pass closed every remaining gap that needs no external terminology — the corpora drove
these fixes, each one a real defect:
- **tx** (441→**473/553**, and the denominator is now honest): wildcard version pins (`1.x.x`) keep
  the PATTERN as the member version so any matching version validates; expansion members dedup and
  exclude by (system, code, **version**) so two versions of a system coexist; a CodeableConcept is
  invalid when a coding names an unknown code in a *complete* CodeSystem, while still echoing the
  coding that DID resolve; server-level version parameters (`system-version` /
  `force-system-version` / `check-system-version`, carried by 145 tests in a `profile` file) flow
  through BOTH validation and expansion; hierarchical expansion (`excludeNested: false` nests
  children under parents — absent means flat); and **undecidable cases are skipped, not failed** —
  a ValueSet resting entirely on a code system we cannot see (SNOMED/LOINC/OHDSI) is unanswerable
  offline, so counting it as a loss was dishonest.
- **UCUM** reached **573/573** — display-name generation was the last skipped section, implemented
  from the essence's `<name>` data (including XML-entity resolution, so `A2` renders `(ampère ^ 2)`).
- **validator**: the corpus grew 33→**67 cases** (adding the manifest's R5 cases with supporting
  profiles, loaded through a 3rd manifest column) and recall 16→17 via a **JSON-shape check** (a
  decimal written as a JSON *string* is invalid FHIR JSON however well the lexeme parses — a fact
  about the document, so never a false positive). The widened corpus immediately exposed a real
  **fail-open violation**: a profile whose baseDefinition we cannot resolve produced a near-empty
  snapshot, and validating against it flagged every element as undefined. Such an index is now
  discarded. FALSE-POSITIVES back to 0.
- **snapshot**: the comparison now matches elements by `id` (which encodes slices), which exposed
  that a slice was inheriting its base element's `min` — a slice is optional unless its
  differential says otherwise. The residual 5 disagreements are version-induced (prov-fi is an R4
  profile; our resolver reads R5 bases) and documented, not chased.

Two suites drove REAL implementation work rather than just measuring:
- **UCUM** exposed that the engine had no validity notion separate from canonicalizability (a
  special unit like `Cel` is valid but has no linear canonical form) → `ucum-valid?`, plus the
  `10*`/`10^` arbitrary-power atom, numeric factors (`4.s/m`), ASCII-only annotations, and
  "a factor takes no exponent" (`10+3` invalid). 533→564/564. The harness compares at the
  suite's own SIGNIFICANT-DIGIT precision (`value="6.30"` → `outcome="0.160"`).
- **tx-ecosystem** grew the service from a 3-operation stub into most of a real terminology
  server (117/221 → **441/599** executed): `$validate-code`'s three input shapes (bare code /
  Coding / CodeableConcept, the last valid when ANY coding is), **display validation** against
  displays and designations with `lenient-display-validation` downgrading to a warning,
  **version semantics** end to end (a versioned index url→(listof resource) replacing the
  url→resource hash, coding `version`, `systemVersion`, `valueSetVersion`,
  compose.include.version pinning, and `1.x.x` wildcard patterns), **expansion parameters**
  (offset/count paging, activeOnly, filter, displayLanguage, includeDesignations, property — the
  service handle's `expand` closure now takes `(url [version] [params])`, which also closed a
  latent FHIRPath gap where `expand()`'s second argument was parsed and discarded), and the
  CodeSystem-level operations **`$lookup`** and **cs-validate-code**. `$translate` already
  existed and was merely unwired. It also drove `compose.include.filter` support in `$expand` — is-a / descendent-of /
  is-not-a / child-of / = / in / not-in / regex / exists over the CodeSystem's concept tree and
  properties — which VCL needed too (a VCL expression compiles to filters, so before this every
  filter-shaped VCL expression expanded to nothing). Also: `compose.inactive:false`, enumerated
  concepts validated against their CodeSystem, and Java-flavoured filter regexes translated for
  Racket's pregexp (which rejects `\t\r\n\f` inside a character class). 104→117/221. The
  harness SKIPS, and counts, everything unimplemented (external terminologies, other operations,
  expansion parameters like offset/count) rather than scoring it — and a 5s per-test budget keeps
  one unbounded expansion from stalling the run. `make-terminology/table` was added so a suite can
  be served from its OWN setup resources instead of a core package.
- **snapshot-generation** exposed the missing ProfileUtilities step: where a profile DIVES INTO a
  complex element the reference expands that datatype's whole element set under the path
  (`Provenance.meta.*`). `expand-dived-datatypes` (fixed-point, so `agent.who` → `.identifier` →
  its children) plus `fill-missing` (a differential states only what it changes, so the datatype
  definition supplies `type` — without which we could not dive further). Path coverage 51→80/80.

## IG corpora (real Implementation Guides as test oracles)
A published IG is an oracle for free: its examples are valid against the profiles they claim, and
its profiles' invariants hold on them. `fhir-validation/tests/ig-*-harness.rkt` (and fhir-server's search harness) read any IG package and
check that, with the SD index parameterised as `(current-sd-packages (list ig.tgz core.tgz))` (IG
first, then the core it builds on). Defects these corpora found and fixed:
- Resource.language/implicitRules were typed as raw strings (`inherited-field-ftype`), so FHIRPath
  `hasValue()` was false on them and `ele-1` failed; they are `code`/`uri` primitives now (towers regenerated).
- FHIRPath rejected an ANCESTOR type as the path head (`Resource.meta.lastUpdated` on a Condition —
  how FHIR's own `_lastUpdated` SearchParameter is written); navigate + analyze now accept it.
- The SD index resolved a bare type code by name/id, and R4 core has an extension NAMED
  "FamilyMemberHistory"; bare codes now resolve to `http://hl7.org/fhir/StructureDefinition/<code>` first.
- element-index treated elements INSIDE a slice (`component:systolic.code`) as plain children, applying
  slice-only patterns/mins to every repetition; they are now excluded (matched by discriminator only).
- Cardinality ignored extension-only primitives (`_performedDateTime` + data-absent-reason); they
  count as present, per the JSON format.
Known and deliberate: dom-3 uses multi-item `as()`, an execution error per the FHIRPath spec and TCK.

Search is TYPE-DRIVEN (`store/search-index.rkt`): each parameter's declared SearchParameter.type
picks its index table (token / reference / string / date / number / quantity / uri) and its
matching rules — string = case+accent-folded starts-with (`:exact`, `:contains`), date = the value's
implicit RANGE with eq/ne/gt/lt/ge/le/sa/eb/ap (zoned values shifted to UTC), number/quantity =
precision-aware eq + prefixes, comma = OR, `:missing`, token `:not`, `_id`, `_lastUpdated`, `_count`.
`_sort` (by `_id`, `_lastUpdated` or any indexed parameter, `-name` descending, a repeating value
by its smallest) and `_offset` with `_count` page. Unknown parameters and unsupported modifiers are
ignored (FHIR's lenient default) and reported by `fhir-search/ignored`; the derived CapabilityStatement advertises only executable kinds (composite and
special are not). Before this, search guessed token-vs-reference from the VALUE's shape and string/
date/number/quantity parameters silently matched nothing.

## Servers generated from an IG (fhir-server's `store/ig-server.rkt`, `raco fhir-server serve-ig`)
Three modules along the seams: `store/ig-plan.rkt` READS the package as the specification of a
server (the IgPlan: tower, core package, the server CapabilityStatement with search implied, the
IgResources; the dependency packages) — pure over the package, tested on US Core; `store/ig-capability.rkt`
holds the IG's statement against WHAT THE SERVER EXECUTES — an `executes` value of four predicates
(interaction, search parameter, include, operation) — and answers the gaps (`plan-gaps`) and the
instance statement for `/metadata` (`instance-capability`), pure over jsexpr and tested on a small
statement; `store/ig-server.rkt` builds the app (the validating repositories, the operations, the
loader) and supplies the predicates. `make-ig-server store ig.tgz` derives the whole server from the IG package: package.json
`fhirVersions` picks the tower (fhir/r4|r5|r6) and the core package; the IG's server
CapabilityStatement (rest.mode = server) gives the types, interactions, search parameters, includes,
supported profiles and operations; the search catalog is the core SearchParameters overlaid by the
IG's; every create/update (API and example loader alike) is validated against its base type and
claimed profiles over `(current-sd-packages (list ig core))` — errors -> 422. `/metadata` is the IG's
OWN CapabilityStatement as `kind: instance`, trimmed to what this server executes; everything
trimmed is a `gap` (type, what, name, SHALL/SHOULD/MAY, reason). IG operations are a table keyed by
OperationDefinition canonical (the registered operation values, see "Operations as values") — the OD itself comes
from the package and drives input validation. `raco fhir-server serve-ig hl7.fhir.us.core [--db f] [--port n]`
loads the IG's examples and serves; `--gaps` prints the unmet requirements. The loader validates
the examples on every core (`fhir/parallel`: the workers load the server's tower and the packages,
only the JSON text and the issue rows cross) and then writes them in order.
Reading the IG's statement: a server resource that lists search parameters or includes but omits
the `search-type` interaction is read as searchable (`with-implied-search`: mCODE, IPA and SDC all do
this); a bare include name (`formulary-coverage`) is the resource's own (`includes-of`); `Type:*`
includes follow every reference parameter; search parameters and includes are advertised only where
search is (`searchable-only`). Dependencies are resolved transitively, in `current-package-directories`
(fhir/spec-package) before fhir-spec, version patterns (`3.3.x`) included. Six more IGs are held to
their own examples, search parameters, includes and profiles in fhir-examples's `ig-servers/`.
US Core status: NO unmet requirement at any level (SHALL, SHOULD, MAY) except authorization (SMART is
not modelled in the CapabilityStatement's resources). Implemented for it: history-instance/-type
(`GET /T/id/_history`, `GET /T/_history`, `_since`, `_count`; Bundle type history), PATCH as JSON Patch
(RFC 6902, `capability/json-patch.rkt`; read -> apply atomically -> the repository's validated update,
so a patched resource is checked like a PUT; failing `test` / profile violation -> 422; a separate
read/update pair so PATCH does not open PUT), and `ValueSet/$expand` at type and instance level (the
registered operation, over the stored ValueSets, then the IG, its dependencies and core; the core
OperationDefinition drives input validation; unknown ValueSet -> an OperationOutcome). The loader also stores the IG's ValueSets/CodeSystems.

## Measure evaluation: CQL over a data source (`cql/measure.rkt`, `$evaluate-measure`; fhir-server's `store/measure.rkt`)
`evaluate-measure measure periodStart periodEnd [#:subject]` (cql/measure) runs a Measure's CQL
(cql/run.rkt) over `current-data-source` — fhir-server's `store/measure.rkt` binds it to the store: the Measure's Library by url (or the canonical's last
segment = Library.name, so locally loaded CQL serves a published Measure), included libraries by CQL
name, their CQL from Library.content (text/cql, base64; compiled once per library); value sets from
stored ValueSets, then the server's IG + core packages; each patient's data per type through its
`patient`/`subject`/`beneficiary` search parameter (strict patient context; a full scan filtered by
reference when the type has none). Output: an individual MeasureReport with a subject, a summary
(counts over every stored Patient + the proportion measureScore) without. The Measurement Period is
whole days, end inclusive; the evaluation timezone is periodStart's offset, else the server's
(`#:offset`, default UTC).
The server serves the registered `Measure-evaluate-measure` at type (`measure` = url or id) and
instance level, so a server generated from an IG that declares it gets it: CQF Measures 5.0.0's
`measure-calculation-service-example` (`make-ig-server … #:capability <id|url>`, chosen because that IG
ships four server CapabilityStatements) has 0 unmet requirements. System-level CapabilityStatement
operations now count in the gap report. `store/load.rkt` loads Bundles, resources and `.cql` files
(-> Library). CLI: `raco fhir-server serve-ig hl7.fhir.us.cqfmeasures-5.0.0.tgz --capability
measure-calculation-service-example --load <dir> --tz-offset -07:00`, `raco fhir-server load <db> <file|dir>`,
`raco fhir-server evaluate-measure <db> <Measure id|url> --period-start D --period-end D [--subject Patient/x]`.
`tests/measure-server-r4-test.rkt`: two eCQMs and 65 test patients loaded through the generated
server's transaction endpoint, `$evaluate-measure` per patient: **60/65** as expected — the five named
(two cases whose resources reference a bare id / a sibling patient, which a server rightly leaves out
of the patient's data; the three corpus disagreements the cql package documents).

## Quality and performance pass (2026-11-09)
Held to a behaviour dump of everything the foundation and fsh produce over the corpora (fsh's IPS,
mCODE, Genomics and golden projects compiled; `fsh check` on mCODE; the published IPS package
decompiled; every US Core and IPS example validated against its own profiles AND against every other
profile of its type; their profiles' snapshots; R4 and R5 core round-tripped; the validator's
differential corpus): identical before and after, byte for byte. What the profiles showed and what
changed:
- **`sd/sd-index.rkt` indexes lazily.** It parsed every StructureDefinition, CodeSystem and ValueSet
  JSON of every package up front (2-4 s per process; a compile touches tens). `skim-keys` reads a
  resource's top-level url/name/id from its bytes, skipping nested values by bracket depth; the
  resource is parsed when a lookup first reaches it. fsh's golden corpus 6.1 -> 2.6 s, US Core's
  snapshots 3.5 -> 1.9 s. `sd-context` is memoised per package list (it re-normalised every path on
  every datatype jump).
- **String-like primitives match in O(1).** `^(?:[\s\S])+$` walked every character of every string
  (0.5 ms per 5 KB narrative div); `^[\s\S]` is the same set (non-empty). With `from-json`'s field
  index cached per type schema (it was rebuilt for every node) and `_field` keys memoised, the R5
  core round trip went 12.7 -> 1.7 s (profiled).
- **The validator caches what depends only on the profile:** a claimed profile's element index (its
  snapshot was regenerated for every resource claiming it), the elements that carry checkable
  invariants (`invariant-sites`; every element of the index was re-split and re-filtered per
  resource), the primitive constructors by code. US Core's examples against every profile of their
  type 15.9 -> 8.9 s; the differential corpus 5.2 -> 2.2 s.
- Bugs found on the way, each with a test that fails without the fix: `read-fhir-json` crashed on a
  `😀` surrogate pair (legal JSON); `sd/snapshot.rkt`'s base-type cache was keyed by the
  type code alone, so a process that changed packages got the first context's datatype (R4's
  Attachment for R5); `model/introspect`'s `full-field-specs` did not climb a constraint type's
  generated parent (Age, Duration: no fields at all, not even `value`). One helper,
  `fhir/canonical` (`canonical-url`, `canonical-version`), replaces ten spellings of "drop the
  `|version`" (the `string-split` ones failed on "" and read "|v" as "v").
- Quality: the framework's inherited fields are one table (`framework-field`, was four parallel
  `case`s); `shipped-snapshot` and `opaque-type?` have one definition (`sd/snapshot`); validate.rkt
  states its data (Issue, ElementDef, Index, Pin, Membership, InvariantSite) and every function has a
  signature; unused requires dropped across the foundation and fsh (fsh's modules each carried the
  same 20-line block).
- **The ceiling is brag.** fsh lexes 140,000 tokens in 0.3 s and parses them in ~10 s: brag's general
  CFG parser costs ~70 µs a token, and FHIRPath's brag grammar ~1 ms an expression (1,353 distinct
  SearchParameter expressions: 1.35 s, most of `fsh check --capability`'s server step). Parsing is
  now 60-70% of an fsh compile (mCODE: RuleSet bodies re-parsed per distinct instantiation are 3.6 s
  of a 5.2 s compile). A parser derived from the same grammar files (kept as the specification and
  the error reporter) would remove most of it; not done in this pass.

## Claude as the user (2026-11-09)
Two rounds of working a workspace through fhir-mcp the way an agent does (setting it up, writing each
language, reading every reply) drove these. The aim: an agent sets up in one step, states FHIR
compactly, and gets back one precise line per problem.
- **Setup.** `raco fhir-mcp init [dir] [--fhir-version]` (`mcp/init.rkt`) writes what is missing,
  never overwriting: `workspace.yaml`, `data/`, `.mcp.json` (the `fhir` server: the standalone
  `fhir-mcp` when on PATH, else `raco fhir-mcp`), and a three-line `CLAUDE.md` pointing to
  `learn://workspace`. The README's "For agents" section covers it and `claude mcp add`.
  `fhir/lang/workspace` no longer lists the data directory's files as sources (`data: data/`, with
  its slash, was compared as a file path).
- **Replies.** A problem is one line, `file:line:col severity: message`, not an object (a check of 10
  problems went from ~1050 tokens for 4 to ~500); `write` mentions `config` only when it wrote
  workspace.yaml. Suggestions everywhere a name can be wrong (`fhir/suggest`'s `did-you-mean`):
  elements, Parents, InstanceOfs, CQL identifiers and functions, resource types. JSON validation is
  positioned at the key (`fhir/serialize/json-position`).
- **FHIR as compact text.** `describe(ref, as: "fsh")` answers a resource as an FSH Instance (a
  blood-pressure Observation: 480 characters, 692 as JSON; a small Patient of plain values is not shorter) — fsh's decompiler now writes a Coding, single-coding CodeableConcept, UCUM Quantity or
  plain Reference as one rule when that rule compiles back to exactly the JSON. `stage(fsh: …)` takes
  FSH Instances written in the call (compiled as a file of the workspace's project, so its profiles
  apply; the temporary file is removed); its own compile errors refuse the stage, each as
  `fsh:line:col error: …` (an instance that failed to compile used to be dropped silently).
- **Fail-open is for the undecidable, not the misspelt.** The validator reported nothing for
  `{"resourceType": "Observaton"}`: now `` `Observaton` is not a resource type (did you mean
  `Observation`?) `` whenever the packages in context define the base types and nothing (packages,
  towers, logical models) defines that name. fsh reports an `InstanceOf` nothing defines (SUSHI does),
  except an R5 resource in an R4 project (SUSHI allows it; the IG Publisher makes it a Basic — IPS's
  ActorDefinitions). FHIRPath's static check now enters operators' operands (`activ = true`,
  `where(famly = 'x')` were unchecked); `trace`'s projection sees its input's type. TCK floors hold.

## FHIR as a tool for agents (2026-11-09)
The third round: the whole cycle an agent wants — create, store, search, compute, analyze — in one
workspace, and the fhir repository as the place an agent learns it.
- **Search over files** (`mcp/search-index.rkt`). `query("search")` refused a data directory ("files
  have no search engine"). The first search now loads the data into a fhir-server store (a SQLite
  file in the temporary directory) as one transaction of PUTs — ids kept, so references still
  resolve — indexed by the packages' own SearchParameters (core, then the workspace's IGs; the
  catalogue memoised per package list), and answers the ORIGINAL resources by type and id. The index
  is keyed by the hub's data source, which `configure!` replaces when the data is read again (a
  commit), so it follows the data. fhir-server is dynamic-required (a build dependency only).
  It found a search bug in fhir-server: a number or quantity prefix compared against the value's
  PRECISION RANGE (`gt8` meant "above 8.5", so 8.4 was missed); FHIR defines gt/lt/ge/le/sa/eb
  "regardless of precision", the range is for eq/ne/ap (`number-bounds`, store/search-index.rkt).
- **Analysis** (`mcp/sql.rkt`): `query("sql", "SELECT …")` over the workspace's ViewDefinitions as
  tables (by file stem and by `name`) and every earlier result whose rows are a table (`r1`, …: a CQL
  run's defines per patient), so a cohort joins with a view's columns. A throwaway in-memory SQLite
  database per query; one reading statement (SELECT/WITH/VALUES, no `;` outside strings — ATTACH
  would write a file); only the tables the statement names are computed; a list cell is its JSON text,
  a boolean 1/0. `describe(result, as: "csv")` answers a table as CSV (default 1000 rows, a last line
  says how to read on). fhir-mcp now depends on db-lib.
- **Where an agent starts** — in this repository: the `fhir` skill (`.claude/skills/fhir/SKILL.md`:
  setup, the guides, the tools, a whole session from FSH data to SQL, what to do when an answer
  surprises); `fhir-mcp/tests/skill-test.rkt` replays that session as written, in a workspace made
  by `init` (```call blocks, "<the FSH above>" placeholders, ```answer blocks matched as a subset).
  `learn://fhir` (`fhir-mcp/learn/fhir.md`) is FHIR itself for agents — which resource holds which
  fact, the recurring shapes, the code systems, the links — with an FSH example and a FHIRPath line
  the workspace test compiles. `raco fhir-mcp guide [topic]` prints any `learn://` guide (every
  language's own, from its installed package) with no server running. `fhir-authoring` is now
  scoped to writing the languages as Racket modules.
- fsh's decompiler writes a `code` element as `#code` (`* status = #final`), FSH's own idiom; GoFSH
  IPS 117/117 and mCODE 341/349 exact, round trip 22/22, unchanged.

## Everything in SQLite; servers as a workspace language (2026-11-09)
- **The store keeps JSONB** (fhir-server's `store/`): `fhir_resources.resource` and
  `fhir_history.resource` are SQLite JSONB (`jsonb(?)` on write, `json(resource)` on read; SQLite
  3.45.1 here), so SQL reads a resource in place (`resource ->> '$.gender'`). A store with the old
  `raw_resource` TEXT column is migrated when it opens (`migrate-to-jsonb!`). Deleting a resource now
  removes every index row of it (string/date/number/quantity rows used to stay).
- **A workspace's data is a store** (fhir-mcp): `data: fhir.db` (`init` writes it) opens it once per
  process with the packages' search parameters; `commit` is one FHIR transaction (PUT with an id, POST
  without); every language, search and `query("sql")` read it — SQL on a READ-ONLY connection to the
  store, a TEMP view per stored type (`id, versionId, lastUpdated, resource`) and `resources`, the
  workspace's views and results as TEMP tables; a JSONB cell answers as JSON. `describe as fsh` drops
  the store's meta.versionId/lastUpdated. The fhir skill's session runs over it.
- **Capability apps store in SQLite**: `current-repository-factory` (capability/runtime) makes the
  repository of a resource declared without `#:repository`; `capability/store.rkt`'s
  `store-repository-factory` makes store repositories restricted to the declared interactions, the
  declaration's own `[name type "FHIRPath"]` search parameters added to the catalogue. Set by
  `(server #:store "fhir.db")` (beside the module), `raco fhir-server serve app.rkt --store f`, or a
  workspace running the app; outside wins. Without any, in memory as before.
- **`capability` is a workspace language** (`*.capability.rkt`; support `fhir/capability/workspace`,
  mapped in fhir/lang/workspace's `support-module`): the app is compiled and served in its OWN
  process — the capability language types with R6 and a workspace process holds its FHIR version's
  tower; two towers in one process register over each other. `artifacts` = `racket <file>` (the
  derived CapabilityStatement, or the compile error at its line), cached by text; `run` = `raco
  fhir-server serve <file> <port> --store <workspace store>` on a free port (killed when the file runs
  again or the process ends — a plumber flush callback); `explain` = the statement's entry for a type
  or an operation. fhir-mcp's `apply` forwards an operation it cannot resolve to the running apps (a
  Parameters POST). `capability/guide.md` is `learn://capability`; `fhir-mcp/tests/capability-test.rkt`
  runs its worked example: the quoted problem at its line, served over the store (committed data
  found by the app's search, the app's writes seen by the workspace's SQL), `$bmi` applied, explained.

## Constraints and the trail: traceable, computable (2026-11-09)
The goal: Claude as the interface to health data — traceable, precise, token efficient — with
constraints on the data as the standard, repeatable way to do complex things.
- **Constraints are profiles** (fhir/lang/workspace `ws-config-profiles`; workspace.yaml `profiles:
  {Type: canonical…}`). `stage` claims the type's profiles in `meta.profile` (`with-profiles`) before
  validating, so `$validate` holds the resource to them — FSH profiles of the workspace (registered)
  or an IG's; a broken rule (an invariant's human text, a cardinality, a pattern) is the change's
  error and the stage cannot commit. `check(data: true)` (`check-data`) validates every stored
  resource the same way: checked, invalid, by rule (counted), the first problems as lines.
- **The trail** (`mcp/trail.rkt`, pure builders, R4 and R5 shapes): every commit writes, after its
  transaction, a Provenance — targets the versions written (`Type/id/_history/v`, from the
  transaction's locations), `recorded`, the agent (`current-agent`: the MCP client's clientInfo from
  initialize, "claude-code 2.0 via fhir-mcp"), `reason` (commit's new `reason` argument), activity
  CREATE/UPDATE, and the source (`stage-source`: FSH text, a file, a result with its file and define)
  CONTAINED as a DocumentReference with the text base64 and its SHA-1 — and an AuditEvent of the
  transaction. `audit: all` (`ws-config-audit`) adds an AuditEvent per run, query and apply
  (`audited`: outcome, the text as `entity.query`). Written where the data is (`write-trail!`: the
  store, a directory's files; a FHIR server keeps its own). The store indexes a versioned reference
  by type and id, so `Provenance?target=Observation/a1` finds every version's.
- **Computing over it**: SQL's `history` view (fhir_history: every version, JSONB) beside the
  `Provenance` and `AuditEvent` type views; `describe("Type/id/_history")` (`describe-history`:
  versions newest first, `changed` paths since the previous version, the Provenance's agent, reason
  and source); `describe(result)` has `source` (file, SHA-1, entry, over, the data and the store's
  latest write). `fhir-mcp/tests/trail-test.rkt` runs it all: an FSH invariant refusing 64 mmol/mol,
  two commits with reasons, the history, SQL joining versions to Provenance, search, audit counts,
  `check(data: true)` over the store (the trail's own resources validate).

## New users, tested (2026-11-09)
Four fresh agents learned the toolkit from the `fhir` skill alone (a cohort query, a constraint
with SQL and history, a FHIR server with an operation, a Racket pipeline) and logged their friction;
every finding below has a test that reproduces what the agent did.
- **Wrong answers and lost data, fixed.** A capability app's store searched with the engine's few
  built-in parameters, so `[birthdate date]` indexed nothing and `?birthdate=lt1900` answered every
  patient: store-backed apps now search with the core package's SearchParameters (R6;
  `core-search-params`), a `[name type]` FHIR does not define (or types otherwise) is an error at load
  with the nearest name, and a parameter the store cannot apply is reported in the searchset (an
  OperationOutcome entry, mode outcome — `search-result/ignored`). The HTTP layer keeps the body as
  sent (`current-request-json`): `$validate` reads it (the lenient node had dropped a misspelt element
  and a bad date, so the server said "All OK"; a bare resource body is the subject), and store-backed
  apps and IG servers validate it before writing (`store/validated.rkt`, 422 with every issue — a
  create used to store `"femme"` and drop unknown fields silently). An inline operation's inputs are
  typed by its declaration, the same over GET and POST (`typed-inputs`; the guide's `$bmi` broke on
  POST). `#lang fml` runs `check-map` and `#lang cql` translates every define when the module COMPILES
  (the readers; a map writing `tgt.gendr` compiled and produced `{"gendr": …}`).
- **The shell route works.** Stages and results are kept in the workspace (`.fhir-mcp/`), so one
  `raco fhir-mcp call`'s stage is committed by the next (two agents had written their own JSON-RPC
  clients); results and stages count apart; `call` takes `key=value`, `key=@file`, `key:=<json>`, `-`.
- **Docs and messages.** `#lang fsh` compiles with the nearest sushi-config.yaml and provides
  `canonical-of`; `raco fsh check` on a missing path exits 2; stage errors from FSH name the instance's
  line; `ensure-valid` lists every error; a CQL module's run-time error is an `exn:fail`; CQL's `render`
  prints FHIR values as JSON; PUT-creates answer 201, creates carry `Location`, a body of the wrong
  type is a 400. New: a FHIR-versions table (learn://fhir), recipes (a rule for some resources of a
  type, the latest value per patient, the Provenance's fields), `fhir-examples/examples/intake-pipeline`
  (FML + FSH + CQL in one `main.rkt`, tested). `fhir-mcp/tests/docs-commands-test.rkt` runs every
  `raco <tool> [sub]` the skills, guides, READMEs and CLAUDE.md files name with `--help` (it found three
  subcommands of `fhir` the notes still named — the FHIRPath and FML TCK runners and VCL — gone for
  months; a document must not name a command that does not exist, even as an example).

## New users, round 3 (2026-11-09)
The same four agents' second rerun named what still cost them time; each fix has a test that does
what the agent did.
- **A capability server searches with what it declares** (capability/store.rkt `declared-search`):
  FHIR's `name` on an app declaring only `gender` was answered though /metadata did not advertise it;
  it is now ignored and reported in the searchset like any other unsupported parameter. The store
  still indexes with the whole core catalogue, so the workspace's search over the same store loses
  nothing to the app's writes. `_` parameters are every type's.
- **Constraints reach the FSH examples** (`check-fsh-project #:profiles`, fsh/workspace passes
  workspace.yaml's `profiles`), and two Instances of one type (or profile) with one id are an error
  naming the first (`duplicate-id-diagnostics`; data files kept in the workspace beside its examples).
- **The trail reads as values**: a history's and a stage's `changed` lines are `path: old → new`
  (`added`/`removed`; values cut at 60 characters); `describe(Provenance/x, as: "source")` decodes the
  source text; `raco fhir-mcp call key=@file` passes the file's name (`files`), so stage errors read
  `a1c.fsh:12: …` and the Provenance names the file.
- **Messages**: `ensure-valid` names the profiles it held the resource to; a CQL module's
  `evaluate #:define` with a misspelt name suggests the nearest; a `code`/`concept`/`valueset` naming a
  terminology definition the library lacks is a translation error at its line (it failed per patient
  at run time); `#:now`/`--now`/`current-evaluation-time` fix CQL's clock. Docs: the CQL cheat sheet
  sorts by `(effective as dateTime)` as the recipe does; the fhir skill's session asks the
  latest-value question (a search answers "any"); an FML recipe splits one text into several elements.

## New users, round 4 (2026-11-09)
The third rerun of the four agents: every task solved first time, no source read; what remained:
- **Speed of the shell route** (`raco fhir-mcp call`, 4.8–6.6 s a call): the search-parameter
  catalogue (1,714 core SearchParameters parsed and narrowed: ~4.5 s per process) is kept between
  processes in the user's cache directory (fhir-server `store/ig-params.rkt` `cached-catalog`;
  `FHIR_CACHE_DIR`, else Racket's cache-dir; keyed by the package's path, size, mtime and the reader's
  version; unusable cache = not used), and the operation modules load the first time an operation is
  looked up (`fhir/operation`'s `add-operation-loader!`). A SQL query or check: ~1 s; describe of a
  type ~2.4 s; a stage (FSH compile + validation) ~4.6 s.
- **The shell's answers**: a call exits 1 when its answer counts errors (`"errors": n` — a stage that
  cannot commit), 2 for usage; `describe("stages")` lists the stages not committed, `stage(drop:)`
  discards one; a create's `changed` is `"created"`; `… | head` ends quietly (EPIPE).
- **Ad-hoc CQL** (`query("cql", …)`) includes every workspace library over FHIR 4.0.1 by its name
  (`Diabetes."Latest Value"`); its translation error is about the query (line 1 of its text, not the
  wrapper's `define "Query"`) and suggests a workspace library's define (cql/workspace `query-error`).
- **What a lenient read dropped is said** (`fhir/serialize/lenient`: `lenient-drops` compares the JSON
  given with the node read back): FML's `transform`, `raco fml --transform` and a workspace run name
  each value the map never saw (`item[0].answer[0].valueDate ("01/05/1950") not read`); `#:strict?`.
- **Messages**: `exn:fail:diagnostic` is an `exn:fail:user`, so a `#lang` build error is its line
  alone, no stack trace; `ensure-valid` names the FHIR version it validated in (`(FHIR R5 (5.0.0))`).
- **Capability servers**: an undeclared interaction on a served type is 405; an operation whose
  definition returns an OperationOutcome answers it 200 (`$validate` was 200 bare, 400 in Parameters —
  `operation-result?`); an input the declaration does not name is a 400 with the nearest name (it was
  dropped); `GET /OperationDefinition[/<code>]` serves the app's definitions; `Location` is absolute
  (from the Host header); `raco fhir-server sql <db> "SELECT …"` reads a store read-only as CSV.
- CQL's `Combine` joins a model's primitives by their System value (`Combine(name.given, ' ')` gave
  `"Ann" "Marie"` with the quotes); docs: a complete blood-pressure rule (one invariant per
  requirement, tested in `fhir-mcp/tests/bp-rule-test.rkt`), object cells and booleans in SQL, the
  latest-value recipe's number/unit and a patient's name, FHIR versions per step of a Racket
  pipeline, checking FSH examples under `raco test`.

## New users, round 5 (2026-11-09)
The fourth rerun: every task first time, 10–21 calls, no source read. What remained, fixed:
- **A `#lang fsh` typo fails the build** (fsh's reader runs the rule checks; fsh/CLAUDE.md), and
  `exn:fail:operation` is an `exn:fail:user` too, so an uncaught `ensure-valid` prints its message.
- **The trail, finer**: `describe(Type/id/_history)` gives each version's `at` — the source file and
  the line its FSH Instance begins (`source-line`, from the source the Provenance contains); a query's
  result records the file its text came from (`textFile`) and, for SQL, the earlier results it read
  (`reads`); a commit answers the `agent` it names (with a note when the shell left it unnamed); a
  stage WARNS about a literal reference to a resource neither stored nor staged (`dangling-references`).
- **A dropped stage's id is never reused** (kept as `dropped-stage-N`; the rerun found the bug).
- **Rules**: learn://workspace has a tested cookbook (range, unit, not-in-the-future; what is a binding
  or a cardinality instead) and the correction recipe (describe as fsh, edit, stage, commit) —
  `fhir-mcp/tests/bp-rule-test.rkt` runs both. A refusal still quotes the rule, not the value found.
- **Servers**: `serve` prints the store file(s) in use (`opened-store-files`) and its pid; `--log`
  prints one line per request. Docs: `$validate`'s levels, stopping a server, `--workspace` defaults to
  the current directory, `Coalesce` for "never tested", deliberately invalid FSH examples kept apart.

## New users, round 6 (2026-11-09)
The fifth rerun (every task first time, 10–22 calls) found a loophole in our own guide and a few gaps:
- **The guide's blood-pressure rule** checked that SOME systolic was in mm[Hg] (`X.where(…).exists()`),
  so a second one in kPa passed: it is `X.exists() and X.all(…)` now, the guide says why, and
  `bp-rule-test` stages the mixed reading.
- **Capability operation inputs bound to a value set**: `[sex code 1 1 #:binding "<ValueSet url>"]`
  (declare.rkt → `rc-param`'s `binding` → the OperationDefinition's `parameter.binding`, required);
  `validate-inputs` refuses a code outside the expansion (`value-set-codes`, `$expand` through fhir-tx,
  once per url; a value set that does not expand checks nothing). `rc-param` keeps its 5-argument
  constructor (the struct is `rc-param-struct`).
- **`raco fsh check <dir> --context <dir>`** (`check-fsh-project`/`compile-project #:context`): another
  folder's definitions in context, its instances and problems left out — examples meant to fail live
  apart without copying the profile (which made `check .` report duplicate ids).
- **Suggestions**: a qualified CQL name (`Diabetes."Latest Valu"` → `` `Diabetes."Latest Value"` ``)
  and an unknown included function (`unknown function FHIRHelpers.ToStrng (did you mean ToString?)`);
  an FSH unit written bare (`7.1 %` → "a quantity's UCUM unit is quoted"; `hinted` in fsh's parse.rkt);
  a dangling reference's nearest stored id.
- **The trail as a table**: SQL's `trail` view, one row per version a commit wrote (type, id, versionId,
  recorded, agent, reason, source, provenance). `stage drop=all`. `Prefer: handling=strict` makes a
  capability server refuse an unsupported search parameter (400; `current-search-strict?`).
- Docs: the CQL recipe's "No HbA1c", text answers print as text, the shell's `write … text=@file`.
Not done, named: operation canonicals under the server's `#:url` (the
`urn:fhir-capability:operation:<code>` join key is used in several places).

## New users, round 7 (2026-11-10)
The sixth rerun (every task first time) named what still cost a step; each fix has a test doing it:
- **A refusal quotes what it found, at the rule that wrote it.** The validator's invariant issue
  ends with ` (found value.ofType(Quantity) = 300 '/min')` (`found-text`, validate.rkt: the paths the
  rule tests — the consequent of a top-level `implies`, each chain without its final
  `exists`/`all`/… and the `where` it tests — evaluated on the focus and printed compactly: a Quantity
  `300 '/min'`, a Coding `system#code`, an object `{k: v}`). The stage points at the instance's rule
  writing that element (`rule-line`; `fsh:7:` for `* valueQuantity = …`, not the header), errors
  listed once; `raco fsh check` traces it the same way (check.rkt, `tests/invariant-trace-test.rkt`).
- **Server `$validate`**: an Observation POSTed to `/Patient/$validate` is a 400 saying where to send
  it (it was "All OK"; only for operations FHIR defines on Resource, so `$transform`'s content is
  not held to StructureMap); `{}` is no body; a resource given at instance level is the one checked.
  A request's own failure is marked (`refused!`, runtime.rkt) so it is never mistaken for the
  operation's OperationOutcome result (200).
- **Results by name** (fhir-mcp): a run is named by its file (`diabetes.cql` -> `diabetes`), a query by
  `name`; `result://<name>` and SQL's `FROM diabetes` read the latest of the name (saved SQL with
  `r4` read whatever r4 was). `reads` records the numbered result a name meant. Result numbers sort
  numerically (r10 after r9).
- **FML in a pipeline names the rule**: `#lang fml`'s `(transform src #:validate spec)` validates
  the result and raises with each problem at the map rule that wrote the element, or "no rule of
  <group> writes `x`" (fml's `validate-result`; the module keeps its source text, since the quoted
  AST loses positions). `raco fml check --profile` takes an FSH project or a canonical
  (`profiles-from`), applied to results of the profile's type. fhir-examples' intake pipeline uses it.
- Smaller: `write` of FSH notes a profile workspace.yaml's `profiles` does not list (not enforced
  until it is); SQL's unknown column suggests the nearest and lists the named tables' columns; a
  reference parameter takes FHIR's type modifier (`subject:Patient=123`, store/search-index.rkt);
  `_include` on store-backed capability apps documented and tested; CQL explain omits empty
  `retrieves`/`uses`; "must be an integer"; the guide's `bp` view shown and the trail ⋈ history join
  tested from the guide's text.

## New users, round 8 (2026-11-10)
The seventh rerun (every task first time, 11–20 calls) named these; each has a test doing it:
- **A create's id is the server's** (http/router.rkt `without-id`): an id POSTed is ignored, as FHIR
  says; the same id POSTed twice answered a 500 naming `fhir-create!`. PUT creates with a chosen id.
  `POST /$validate` says where `$validate` is served (`served-at`, runtime.rkt).
- **`apply` takes a server's `url`** (fhir-mcp): from the shell each call is a process, so an app `run`
  served is gone with it; `apply(operation, url: …)` POSTs to a server started with `raco fhir-server
  serve`, and an operation found nowhere says so.
- **Refusal evidence follows the rule's structure** (validate.rkt `evidence`, replacing the flat
  selections): `implies` -> its consequent, `and` -> its false parts, `X.where(c).exists()` -> X's
  values when they are values, else `no component matching '8462-4'` (the condition's literals),
  `X[.where(c)].all(p)` -> p's evidence on each failing item by index (`component[0].valueQuantity =
  20 'kPa'`). Selections are named as the JSON names them (`valueQuantity`, `effectiveDateTime`).
  The stage's `rule-line` and fsh's check match a whole path (`component[0].valueQuantity`, or the
  validator's `component.value[x].code` against `* component[0].valueQuantity`), shortening it until
  a rule writes it; "found no …" stays at the instance's header.
- **A Quantity coded in UCUM carries a UCUM code** (validate.rkt `ucum-issues`, through fhirpath's
  `ucum-valid?`): `130 'mmHg'` is a WARNING `` `mmHg` is not a UCUM unit (mercury is written mm[Hg]) ``,
  with the nearest common clinical unit otherwise; a stage lists validation warnings beside its
  errors, at their rules. A warning, because the gate caught it as an error: mCODE's published
  body-surface-area example writes `m^2` (283 -> 282/283 until it was one). Gates unchanged: IG
  validation 260 clean, validator fp 0 / recall 18, published mCODE 283/283.
- **Why nothing was written**: fml's `validate-result` says `(the rule here wrote nothing: its source
  matched nothing in the input)` when the traced rule's element is absent from the result; `raco fsh
  check` says `(no rule of <instance> writes `birthDate`)` for a required element nothing wrote.
- **Results and the trail**: a result name is matched as asked or as kept and in any case
  (`result://a1c-table` reads `a1c_table`, and the answer notes the change); a missing result lists the
  results with their names; `commit stage=latest`; `describe(Type/id/_history)` gives each version's
  `recorded`; `trail.provenance` is `Provenance/<id>`; `check(data: true)` counts `byType`.
- Docs: a route table at the top of the fhir skill; the shell example uses names and `latest`; a
  served app from the shell; `render`'s type; when FHIR versions matter in a pipeline; 140/90 read as
  systolic OR diastolic; why a view's paths use `.first()`.

## New users, round 9 (2026-11-10)
The eighth rerun (every task first time, 12–19 calls); each fix has a test doing what the agent did:
- **What a capability app derives about itself is valid FHIR** (capability/derive.rkt,
  `tests/derived-valid-test.rkt` validates the statement and every OperationDefinition): `drop-absent`
  dropped `#f`, so an OD lost its required `type`/`instance: false`; the OD's `name` is machine-usable
  (`operation-name`: `evaluate-measure` -> EvaluateMeasure, cnl-0); the instance statement carries an
  `implementation` (cpb-2, cpb-14). `(server #:name … #:description …)` (rc-server keeps its six-argument
  constructor, as rc-param did). `raco fhir-validate --fhir-version 4.0.1|5.0.0|6.0.0`, and the version a
  resource names (`fhirVersion`) when none is asked: an app's R6 `/metadata` validates as R6.
- **Messages**: `transform #:validate`'s error names what it held the result to and in which version
  (`invalid against IntakePatient (http://…) (FHIR R5 (5.0.0))`); fsh check cites a profile rule only
  when it imposes the kind of constraint broken (`constraint-kinds`: a cardinality for a minimum, a
  binding for a value set, an assignment for a pattern, an `only` for a type — it cited `* gender 1..1`
  for "femme"); `raco fsh check` prints the canonical it used (the default `http://example.org` too).
- **Workspace**: a `Reference(name)` of no instance (a bare name) is warned with the id it most likely
  meant; staging what is stored unchanged makes no stage; `write(…, enforce: true)` lists the file's
  profiles in workspace.yaml (`enforce-profiles!`); history's `recorded` is the Provenance's (one time,
  as the trail says it); stage answers drop the repeated `target`; CQL explain's `of-type` is
  `patientHas`.
- **`raco fhir-mcp batch [file|-]`**: many calls in one process, one per line, quoted as a shell would
  (`shell-words`), each answer under `### <line>`; every line runs, exit 1 if any failed.
- Docs, each tested: the capability guide's Quantity output and a standalone curl smoke test
  (`tests/capability-guide-test.rkt` runs the guide's block); fhir-examples' intake pipeline laid out as
  a template (`fsh/`, `fsh-invalid/`; the test checks both) with a copy command in fhir-authoring; CQL's
  recipe variations (a window, the last two, their mean). Writing that recipe found a crash: `Take(X
  sort by Y desc, 2)` reads `2` as a second sort item (as cql.g4 does), and `Take` with one argument was
  a `cadr` error; it now says to parenthesize the query.

## New users, round 10 (2026-11-10)
The ninth rerun (every task first time); each fix has a test doing what the agent did:
- **The trail answers what it wrote**: `commit` gives each resource's `version`
  (`Patient/fay/_history/1`) and takes `agent` (`commit … agent="intake desk"`, over
  FHIR_MCP_AGENT and the client's name; the note asking for one shows from `batch` too). A source
  file is named relative to the workspace when inside it, else by its absolute path (`file-label`:
  `../a1c.fsh` named nothing anyone could open). learn://workspace says when a fact happened
  (`effectiveDateTime`, `issued`) versus when it was recorded (the Provenance).
- **Querying**: a search's preview rows are `Type/id` and the columns, no JSON (`describe` gives it);
  CQL explain names a code filter (`code ~ http://loinc.org|4548-4`); every view is also
  `<view>_history` in SQL (the view over every stored version, `history-resources` in mcp/sql.rkt).
- **Errors at the cause**: a capability declaration error is one line at the form
  (`clinic.capability.rkt:7:2: operation: unknown parameter type …`, `decl-error` in declare.rkt; it
  was a syntax error printing the whole form), a lone declaration in a module says the module needs
  its `(server …)`; fsh's `canonical-of` with an unknown name suggests the nearest and lists the
  names; `raco fsh check` names profile rules relative to the current directory; FML's "wrote
  nothing" names the source values the lenient read dropped when that is why.
- **Operation parameters say what they mean**: `[creatinine decimal 1 1 #:documentation "Serum
  creatinine, mg/dL"]` is the derived OperationDefinition's `parameter.documentation` (`rc-param`
  keeps its 5-argument constructor). The capability guide's Quantity output is a real conversion
  (creatinine mg/dL -> µmol/L), tested with the documentation it declares.
- Docs: each language guide shows a `#lang` file and the error Racket gives without the line; a
  `batch -` example with `--workspace`; the store views' columns in the capability guide; dropped
  stage ids are not reused; fhir-authoring runs the intake pipeline's pieces one at a time before
  `main.rkt`, whose template lost requires it did not need (`transform #:validate` loads `$validate`).

## New users, round 11 (2026-11-10)
The tenth rerun (every task first time, 10–16 calls, no source read) found two real defects and a
half-right fix; each change has a test doing what the agent did:
- **A search answers valid FHIR**: a searchset (and history) Bundle carries each entry's `fullUrl`
  (`[base]/Type/id`, a urn:uuid for an OperationOutcome entry) and a `self` link — http/server.rkt's
  `bundle-with-urls`, from the request's Host (the router has no base); it failed bdl-15/bdl-18 under
  the toolkit's own validator. `derived-valid-test` validates a searchset now.
- **No store means a temporary store, not memory** (capability/store.rkt `temporary-store-factory`, the
  module's fallback): the in-memory repository matched parameters by string equality, so
  `patient=Patient/x`, `birthdate=lt1980` and every parameter declared without an expression matched
  every resource or none; it now reports what it cannot apply too (`store-search`). The file is removed
  when the process ends (the default plumber).
- **`(server #:search-handling "strict")`**: every search strict, whatever the client prefers (the app's
  metadata, `strict-search-app?`) — an undeclared `subject` on a research server answered every
  patient's Observations.
- **Inline code subsets**: `#:binding "(http://hl7.org/fhir/administrative-gender)(female;male)"` is
  VCL, turned into FHIR's implicit value set url at compile time (`binding-url`, a VCL that does not
  parse is a declaration error); fhir-server depends on vcl.
- **Paths as given, trail resolvable**: a message names a file as the user wrote it (`argument-file`);
  the Provenance keeps it relative to the workspace or absolute, resolved where the call was made
  (`argument-source`: a bare name relative to the shell's directory was kept bare); history's `at` and a
  result's `file` are shown relative to the current directory when shorter (`shown-path`).
- **Answers for the shell**: hints are written as the shell takes them (`commit stage=stage-2`, not
  `commit("stage-2")`; `call-style`, `call-text`); a table's rows list their keys in column order
  (verbs.rkt `answer-json`); a stage's create no longer repeats `changed: "created"`; `agent=` may be a
  reference (`Practitioner/dr-ng` -> `who.reference`; `trail.agent` reads either).
- **One error for an invalid result**: fml's `transform #:validate` raises `exn:fail:operation` (with an
  OperationOutcome), as `ensure-valid` does, so fhir-authoring's one handler catches both.
- Docs: learn://workspace's "each stored value with where it came from" (a type joined to `trail`,
  tested) and the correction reason reworded; learn://fhir's common UCUM codes (each checked with
  `ucum-valid?`); fhir-authoring's FHIR-version table and what `render` gives for a CQL null; the
  capability guide's strict handling, VCL bindings, temporary store and `urn:` operation canonicals.

## New users, round 12 (2026-11-10)
The eleventh rerun (every task first time, 8–16 calls, no source read, no wrong answer); each fix has
a test doing what the agent did:
- **Declaration errors, all and at their forms**: module-begin checks every declaration before raising
  (`collected`) — a bad interaction and a bad parameter type are two lines, each at its form; a search
  parameter FHIR does not define (decided only when the app is built, from the core package) is
  `study.capability.rkt:3:0: resource Patient: search parameter `birthDate`: … (did you mean
  `birthdate`?)` with every problem of the type (`exn:fail:declaration`, `with-declared-locations`;
  it was a stack trace through store.rkt, and `serve` died without a word).
- **VCL bindings percent-encoded** in the OperationDefinition, as the VCL spec requires
  (`uri-unreserved-encode`); messages show the expression decoded (`shown-value-set`).
- **One path form in the trail**: a source file is kept relative to the workspace up to two levels
  above it (`../src/bad.fsh`), else absolute; history's `source` and `at` are shown alike
  (`shown-display`). Each Provenance target carries the source line that wrote it (an extension,
  `urn:fhir-mcp:source-line`), so SQL's `trail` has an `at` column.
- **Leaner answers**: a change has `errors` only when there are some; `more` only when there is more;
  `describe as=fsh` leaves out the profiles staging claims by itself (workspace.yaml `profiles`); a
  bare reference's suggestion names every near id; answers write `resourceType`, `id`, `meta` first.
- **FHIR JSON as FHIR writes it**: `fhir/serialize/fhir-json` (`fhir-json->string`, `write-fhir-json`
  with `#:indent`, `key-order`); `raco fml --transform` and the intake pipeline print with it.
- Docs: the fhir skill points the Racket route at fhir-authoring's pipeline section (the workspace
  not needed) and names the rules cookbook, the blood-pressure rule, the correction recipe and
  `enforce:=true`; the capability guide's declaration errors, common UCUM codes and decimal inputs
  (a Racket number already); learn://workspace's `trail` column types, `at`, and a view-history ⋈ trail
  join (tested); the CQL recipe adapted to another lab and a yes/no table (run against a workspace).

## New users, round 13 (2026-11-10)
The twelfth rerun (every task first time, 9–17 calls, no source read, no wrong answer); each fix has a
test doing what the agent did:
- **FML: a primitive element takes a primitive** (fml/CLAUDE.md): a Coding assigned to `gender` is an
  error at the rule naming the part that fits (`(a.value.code)`); it was written as an object and
  validation blamed `code.code` with no line.
- **Refusal evidence for a value that is there**: a typed selection (`value.ofType(Quantity)`) that
  fails its condition shows what it holds (`found component[0].valueQuantity = 120 (no unit)`), at the
  rule that wrote it; "no component matching '8462-4'" stays for a list none of whose items match.
- **Capability inputs**: every problem with a request's inputs at once (unknown, missing, mistyped,
  outside a binding or a range: `input-problems`, `typed-inputs/problems`); `#:min`/`#:max` on a
  number (FHIR's minValue/maxValue extensions on the OperationDefinition parameter, `range-problems`);
  a handler that raises answers 500 naming the handler and how to refuse instead; strict search's
  refusal lists what the type does search on (`advertised-search-names`).
- **Messages**: the validator's required-binding error quotes the code (`code `femme` not in required
  value set …`); HTTP answers write `resourceType` first (`fhir-json->string`).
- **The trail**: SQL's `trail` has `source` (the file) and `sha1` apart.
- Docs: the correction recipe writes its file beside the workspace; `init`'s CLAUDE.md and output name
  the shell commands for the guides and tools; fhir-authoring says what `evaluate` returns (`#t`, a
  hash of defines) and that `render` is for printing; `apply url=` needs no workspace; the capability
  guide's ranges and all-at-once input errors.

## New users, round 14 (2026-11-10)
The thirteenth rerun (every task first time, no source read, no wrong answer); each fix has a test
doing what the agent did:
- **One path form in the trail**: history's `source` and `at` are the trail's own (relative to the
  workspace, else absolute — the same text SQL's `trail` has, from any directory), the SHA-1 apart
  (`sha1`); a correction's `at` is the rule it changed (`rule-line` on the first changed path; the
  Provenance target's `urn:fhir-mcp:source-line`, matched by its full versioned reference), not the
  instance's header. `describe ref=Observation/a1[/_history] as=source` answers the FSH that wrote it,
  through its newest Provenance (no id to copy).
- **The shell**: `write text=@../a.fsh` says it keeps a copy (`copied`: later edits go to the
  workspace's file); a refused stage's `next` says how to discard it (`stage drop=stage-3`); `batch`
  marks a failing line in its header (`### [exit 1] …`) and ends with a count naming them.
- **Servers**: `raco fhir-server serve app.rkt --port 0` takes a free port and prints it (serve-app's
  `#:on-listen`; `--port n` as well as the positional port); a port in use is one line, exit 1; the
  banner names the temporary store (it said memory). An app's store is opened lazily (`open-fhir-store
  #:lazy?`: the schema is made by the pool's first connection), so `racket app.rkt` prints the
  statement — now as FHIR writes it, `resourceType` first, indented — and creates no `fhir.db`.
  An operation's input problems are one OperationOutcome issue each, the input in `expression`
  (`inputs-outcome`).
- Docs: fhir-authoring shows `main.rkt` whole (fhir-examples' intake-pipeline-test compares its forms
  with the file) and says every required file starts with its `#lang` line (and the error Racket gives
  otherwise); `raco cql --now` takes a date; the capability guide on `--port 0`, the banner as the
  ready signal and issues per input.

## Known deferrals
- Full IG *package* generation (an IG as a `gen-target` with `delegate-base`) — the `#:delegate` seam
  and the sd profiling lang exercise delegation; whole-package IG codegen is not wired yet.
- FML: `dateOp`, `escape`, `pointer`; a map pinned to R4 (`uses …|4.0.1`) still runs on the R5
  tower (one tower per process).
