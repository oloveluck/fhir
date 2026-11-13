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
| `fhir-mcp` | `oloveluck/fhir` → `fhir-mcp/` | the Model Context Protocol server over a WORKSPACE (below): `mcp/workspace.rkt` (the hub's contracted interface over `hub.rkt` — config, packages, data source, artifacts registered, results, stages — and a module per verb: `check.rkt`, `run.rkt`, `describe.rkt`, `apply.rkt`, `stage.rkt`), `mcp/verbs.rkt` (the nine tools), `learn/*.md` (`learn://` guides with the official references for the workspace, search and the languages that do not ship their own yet; a language's own guide comes from its repo, below; their examples compile in the test), `mcp/tools.rkt` (the Tool struct; operations loaded and applied to JSON; elements and definitions in the packages), `mcp/resources.rkt` (guides, packages, definitions, learn, results; prompts), `mcp/server.rkt` (dispatch, one JSON line per message), `mcp/init.rkt` (`raco fhir-mcp init`: workspace.yaml, data/, .mcp.json, CLAUDE.md), `mcp/search-index.rkt` (FHIR search over data that is files, through fhir-server's store, loaded on demand), `mcp/sql.rkt` (SQL over views and results, and over the workspace's store read-only), `mcp-cli.rkt` (`raco fhir-mcp [--workspace d]`, `init`, `guide`, `tools`, `call`) | fhir, fhir-lsp (+ the operations and languages at run time) |
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
~12 KB for the nine verbs, held under a ceiling by `tests/tool-budget-test.rkt` (the 25
per-operation and per-language tools they replaced were ~53 KB).

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
sql-on-fhir; the implementation guide's guide is fsh's `ig-guide.md`; fhir-mcp's `learn/` keeps only `workspace.md` and `search.md`, and its test requires
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
feeds `check`'s diagnostics back between rounds. Baselines: the IG's own FSH (34/34, 20/20 and 8/8
facets on the three recorded tasks; it was 28/34, 14/20, 5/8 when they were recorded) and empty (0).
Results: that repo's TESTING.md and `results/`.

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

### Docs written for a person (2026-11-13)
Three kinds of document, each with one job:
- **README** (each repository): under about forty lines. What it is, in two plain sentences that name
  the standard and say what you get; one short example with its real output; how to install (the
  language repositories point to this repository's README, which has the build); links to the docs
  site, to `guide.md`/the skill for agents and to `TESTING.md`. Nothing else: detail lives on the site.
- **The docs site** (`scribblings/<id>.scrbl`, `docs/index.scrbl`; published from `main` by each
  repository's `docs.yml`), read by someone who has not used the tool. In this order:
  1. *What it is*: the problem in plain words, the standard and who uses it, what this package does.
     No test counts, no module names, no "as the reference implementation does" asides.
  2. *What you can do with it*: a short list of tasks.
  3. *A first example*: install, write, run; a sentence at each step saying what it is and what the
     output means; one mistake and the message it gets.
  4. *Guides by task*, in the order a newcomer needs them: one idea to a paragraph, an example
     before the rule, tables only for look-up material.
  5. *Words used here*: every term of art (ELM, profile, canonical, value set …), one line each.
  6. *Limits*: what it does not do, plainly.
  7. *How it is tested*: the conformance numbers, briefly, pointing to `TESTING.md`.
  8. *Reference*: the API, last.
  Sentences are short and active and say "you"; a term is explained where it first appears; why
  comes before how.
- **`guide.md`** and the skills stay as they are: written for an agent, dense on purpose.
Two things keep a page true to what a terminal shows. Each manual shadows `tt` with a literal
element (Scribble's own turns `--pack` into an en dash and `'x'` into curly quotes), and each
`docs.yml` builds with `++style <docs|scribblings>/manual.css`: a command's output is shown as
printed, however wide, and scrolls inside the text column (one small stylesheet, the same file in
every repository).
Accuracy is not negotiable in any of them: every command shown was run, every output is real,
nothing is promised that the code does not do; `tests/docs-test.rkt` renders each manual and
`fhir-mcp/tests/docs-commands-test.rkt` runs every command the documents name.

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
| **FML StructureMap form** | **every corpus map through its StructureMap and back; the tutorial run from the emitted resources by canonical; our StructureMap vs matchbox's rule by rule** | `raco fml --tck` | **58/58 round trip; 37/37 from our resources** (29/37 from the reference's, several predate their .map); **21/31 rules equal** |
| **FML printer** | **every corpus map and every StructureMap resource matchbox ships written as the specified language (fml/print): parses, means the same StructureMap, a fixpoint, nothing beyond the specification but `conceptmap` and `share <id>`; the inter-version R4 maps in CI** | `raco fml --tck` | **58/58 maps, 25/25 resources** (332/332 in CI) |
| **FML check** | **every corpus map checked against its structures** | `raco fml --tck` | **55/58 without an error finding** — the 3 are real (R4 elements R5 dropped; a typo in syntax.map) |
| **UCUM** | **FHIR/Ucum-java UcumFunctionalTests.xml** | **`raco fhirpath --ucum-tck`** | **573/573** (all sections) |
| VCL | the spec page's 60 examples | `raco test vcl/` | 60/60 parse + fixpoint |
| round-trip | HL7 examples + R4/R5 core packages | `raco fhir roundtrip-tck r5\|r4` | 2968+77, 4581+72 |
| **IG examples** | **US Core 9.0.0, IPS 2.0.1 packages** | `tests/ig-examples-r4-test.rkt` | **274/274 parse+round-trip** |
| **IG validation** | **US Core 9.0.0, IPS 2.0.1, CRMI 2.0.0: every example vs the IG profiles it claims** | `tests/ig-validation-r4-test.rkt` | **330/330 clean** (0 false positives) |
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

## New users, round 15 (2026-11-10)
The fourteenth rerun (every task first time, 11–16 calls, no source read) found one real defect;
each change has a test doing what the agent did:
- **A bare reference's suggestion names the patient it names**: `Reference(pat-a)` with `Patient/pat-a`
  stored suggested `Patient/pat-b` (`closest-names` leaves the exact name out); an id equal to the
  name now comes first, alone (`bare-suggestion`).
- **The trail**: `describe ref=Type/id as=source` answers the resource's own Instance
  (`instance-block`), the Provenance the whole file; the SHA-1 is all 40 digits; history names its
  fields as SQL's `trail` does (`agent`, not `by`); a change refused for its errors no longer lists
  its dangling references; `stage drop=latest`.
- **Servers**: the banner says the search handling (`search: strict …` / `lenient …`); the guide's
  worked example is strict and its smoke test runs on `--port 0`, reading the url from the banner
  (`capability-guide-test` runs it as written); the WAL files are explained; a value-set error names
  the codes once (`must be female or male, got "other" (value set …)`); input problems come in the
  order the inputs are declared (`in-declared-order`).
- **The Racket route**: the template's `main.rkt` takes `--now`; `raco fml check` names each example
  by its file and says what the results were held to; `raco fsh check` on a folder whose InstanceOf a
  sibling folder defines says `check with --context <dir>` (fsh `with-context-hint`); a CQL error
  about a name is positioned at the name (cql `at-the-name`, in `raco cql`, the `#lang cql` build, the
  editor and the workspace); fhir-authoring says `write-fhir-json` orders the other elements by name.

## New users, round 16 (2026-11-10)
The fifteenth rerun (every task first time, 13–18 calls, no source read, right answers) found one
real defect; each change has a test doing what the agent did:
- **Declaration errors, really at once**: `[age int 1 1 #:min 18]` said only that `#:min` bounds a
  number — the type is checked first now, with the nearest (`int`: "did you mean `integer`?", a
  prefix counts) and the primitives listed (declare.rkt `type-suggestion`); and a search parameter
  FHIR does not define, decided from the core package when the app is built, is checked at expansion
  too whenever other declarations already fail (module-begin `search-param-problems`), so both come in
  one answer.
- **Tables and the trail in one call**: `run`/`query … as=csv columns="Name,Latest Number"` answer the
  rows as CSV with those columns (`as-csv`, `result-csv #:columns`, an unknown column suggested);
  `describe ref=Observation as=trail` is every stored resource of a type at its current version with
  who, when, why and the file and line (`trail-sql`). cql's recipe has `"Above 9"` (`never tested`,
  `yes`, `no`), so the clinic's table is `run … as=csv columns=…`.
- **Refusals that say the fix**: a refused commit lists its errors (it gave a count) and how to drop
  the stage; "found no component matching '8462-4'" adds `: add a component with '8462-4'`
  (`with-missing-hint`); an MCP-style hint names a non-first argument (`stage(drop: "stage-2")`, it read
  as `stage("stage-2")`).
- **Servers' guide**: sub-headings, the operation input/output types, a UCUM code-and-display table.
- **The Racket route**: a quickstart at the top of the fhir skill (copy, the checks, run, `raco test
  tests.rkt` — run as written); the template ships `tests.rkt` (its one gate, run by `raco test -p
  fhir-examples`) and a FHIR-versions note in `main.rkt`; a `#lang` build error names its file
  relative to the current directory (fhir/diagnostic `with-shown-source`); `#:now` takes a date in
  cql's guide too; fhir-authoring says where the language repos are, what `evaluate` returns before
  `render`, and the order of a check report's diagnostics.

## New users, round 17 (2026-11-10)
The sixteenth rerun (every task first time, 12–18 calls, right answers) found one risk and one
defect; each change has a test doing what the agent did:
- **A correction is not undone quietly**: staging the original file again after a committed
  correction answered `140 → 150` as a plain update; the change now warns that it puts back version
  N−1's values on the paths the newest commit changed, naming that commit's reason and how to keep it
  (`reverted-correction`, from the store's history). A stage answers resources stored as they are as
  a count (`unchanged`), not a list burying the change.
- **A decimal is a number too**: `(valueDecimal 57.5)` was refused and `(real->decimal-string v 0)`
  gave "58.", which FHIR refuses — the handler crashed with a hint about refusing inputs. A decimal
  primitive now takes a Racket real (`#:coerce`, `decimal-lexeme` in fhir/primitives), and a 500 from a
  value the handler BUILT says so (`handler-crash-hint`), its regexp left out of the message.
- **Tables**: `describe ref=<Type> as=trail` has the subject, the value and its date beside the
  trail; CSV answers take `sort` (`-Name` descending); a CQL run's rows come in patient order and a
  define answering a few texts is tallied by text (cql `tally`); a wide run answer says how to have it
  as CSV (`table`). `enforce:=true` fills init's commented `profiles:` template (it appended a second
  key). learn://workspace's `bp` view has id, version, date and diastolic, and the 140/90 summary is a
  tested recipe (bp-rule-test runs both as written).
- **Docs**: the capability guide opens with the smallest server (store, two resources, an operation;
  capability-guide-test builds it), the R6 note and the restart loop; the fhir skill's Racket route
  says where to stop and what each of the four files is, and the versions in one sentence; the
  template's `main.rkt` catches `exn:fail:operation?` (exit 1, the message); `raco fsh check`'s
  summary counts in the singular when it is one and its canonical note is one short line.

## New users, round 18 (2026-11-10)
The seventeenth rerun (every task first time, 10–12 calls, right answers) found one real defect;
each change has a test doing what the agent did:
- **A day the calendar lacks is no date** (`fhir/primitives/temporal.rkt` `calendar-problem`): the
  spec's regex allows day 31 in every month, so `birthDate = "1940-02-30"` passed `raco fhir-validate`
  ("All OK") and `raco fsh check`, and CQL computed an age from it. date/dateTime/instant now check the
  day against the month (leap years by 4/100/400); the validator says why (`'1940-02-30' is not a
  valid date (February 1940 has 29 days)`), fsh check at the rule; CQL (literal: a translation error;
  `Date(…)`: a run-time error; `ToDate('…')`: null) and FHIRPath (literal: an error; `toDate()`:
  empty) agree. TCKs unchanged (FHIRPath 1044/1044 and 932/934, CQL 1820/1823).
- **The trail reads more**: `describe ref=<Type> as=trail` has the patient's `name` and a blood
  pressure's components as its `value` (`142 mm[Hg] / 91 mm[Hg]`; it was empty), takes `columns`/`sort`,
  and `ref=Type/id/_history as=trail|csv` is every version of one resource (`trail-sql type [id]`);
  history notes where `source`/`at` are relative to when called from elsewhere; `write`'s `copied`
  names both files from the current directory.
- **`batch`**: a line starting with `!` is expected to fail (`### [failed, as expected] …`; a misspelt
  tool still fails), counted apart in the summary.
- **Capability apps**: a misspelt search-parameter type is said once, with the nearest and the types
  (`tokn`: it was also reported as "a token in FHIR, not a tokn"); a server option given a symbol
  (`#:mode server`) or an unknown option is one line at the value (it was syntax-parse's "expected
  string" and a stack trace); an instance statement without `#:date` is dated when the server
  started (`started-at`, derive.rkt; it was 2025-01-01).
- **`raco fhir new pipeline <dir>`** copies fhir-examples' intake-pipeline template (without compiled/;
  refuses an existing dir) — the docs' copy command was a `racket -e` inside `cp`.
- Docs: the fhir skill opens with a question → recipe table and keeps the Racket quickstart in its own
  last section; its HbA1c example uses 9 % as the CQL recipe does; fhir-authoring has an API card for
  the pipeline, says the mapped Patient needs no id and that `raco make` stops at the first failing
  module (`compilation context...` is the chain of requires); learn://workspace says a stage is all or
  nothing, has a parameterized RuleSet for many readings (tested) and formats means with `printf`;
  the capability guide builds a decimal output from a Racket real and documents a bare-id reference
  search; cql's guide has `Ever Above 9`; `raco fsh check`'s default canonical note is one word.

## New users, round 19 (2026-11-10)
The eighteenth rerun (every task first time, 6–12 calls, right answers, no source read) found two
things close to defects; each change has a test doing what the agent did:
- **FML says which part wrote nothing** (fml/CLAUDE.md): when the rule's source matched but its value
  expression gave nothing (`(a.value.code)` over an answer written as `valueString`), the message
  says so with the value read; it said "its source matched nothing in the input".
- **A correction's source stages again**: `describe ref=Observation/x as=source` of a reading written
  through a parameterized RuleSet answered `* insert Reading(…)` alone, and staging it failed (RuleSet
  not found); the Instance comes with the RuleSets it inserts (transitively) and the Aliases it names
  (`used-definitions`). A create's `at` is its first `* insert` line when it has one (`insert-line`),
  where the values are.
- **Stages**: `describe ref=stages` lists refused stages apart (`refused`, with the call that drops
  them); `stage drop=refused` drops every one with errors.
- **Tables**: a wide run's CSV hint suggests the columns a person reads — text, numbers, booleans, not
  lists or `Type/id` references (`readable-columns`); cql's run summary gives a number define its
  `numbers`, `min`, `max`, `mean` (it read `{"other": 2}`); `describe ref=<Type> as=trail` called from
  another directory ends with a line saying its `source`/`at` are relative to the workspace.
- **Capability inputs**: an `integer` input written as a whole decimal (`60.0`) is that integer; a
  required input absent is `parameter 'x' is required`, naming a misspelt input given in its place
  (`` (`xx` was given: a misspelling of it?) ``).
- **cql**: a null prints as `#<cql:null>` (a REPL showed `(cql-null-type)` in `evaluate`'s hash).
- Docs: the fhir skill has a Racket-in-brief box under its route table (`raco fhir new pipeline`), given
  names in its FSH, rows for "ever above" and 140/90 (systolic OR diastolic), and how `#:store` and
  `--store` relate; the capability guide builds its Quantity output from a rounded real and shows how a
  script takes the id from `Location`; fml's guide filters gender by its code system (tested);
  fhir-authoring says how a hand-written project gets the FSH-examples gate.

## New users, round 20 (2026-11-10)
The nineteenth rerun (every task first time, 8–12 calls, right answers, no source read) found three
slips in round 19's own changes and one older defect; each fix has a test doing what the agent did:
- **The trail CSV is pure CSV**: round 19's `# source and at are relative to …` line after the rows was
  a junk row in a CSV tool, and it printed from inside the workspace too — `ws` and `ws/` compared
  as different directories (`at-root?`, workspace.rkt). History's `paths` note now shows only from
  elsewhere.
- **A correction made through a RuleSet** is at its `* insert` line (`insert-line` for updates as for
  creates); it pointed at the Instance header.
- **The CSV hint names a person's table**: yes/no flags left out when three other columns remain, a
  column with "name" in it preferred to the patient id, columns null for every patient kept
  (`readable-columns`) — for the CQL recipe, `Latest Number,Latest Unit,Latest Date,Above 9,Name`.
- **fsh: a duplicate id's problems at their own instance** (fsh/CLAUDE.md): both instances' errors went
  to the later file.
- **`$validate`'s clean answer names the FHIR it was held to** (`All OK (FHIR R5 (5.0.0))`).
- **`raco fhir guide [topic]`** prints the guides (the same text as `raco fhir-mcp guide`), for the
  Racket route; `raco fml … --transform … --indent` prints indented, as `write-fhir-json` does.
- The template's `tests.rkt` finds the invalid example's line by its text (a copy failed on a
  hard-coded 3).
- Docs: the skill's latest-HbA1c row gives the whole table command and says hand-placed workspace files
  are used; learn://workspace opens with the whole blood-pressure program in order and its correction
  recipe takes `as=source` for RuleSet-written data; the capability guide's stale `#:date` sentence is
  fixed, its smoke test stops the server by the banner's pid (`kill %1` needs one shell), and an input
  options table and the type conversion are stated; the fsh skill says `check` takes every
  subfolder and `.map` file.

## New users, round 21 (2026-11-11)
The twentieth rerun (every task first time, 6–15 calls, right answers, no source read) found one real
inconsistency; the round also found two silent defects while answering the agents' questions. Each
fix has a test doing it:
- **A capability server validates in its own FHIR, R6**: `$validate` and the store's write checks read
  R5 by default and said `All OK (FHIR R5 (5.0.0))` on an R6 server. The app's metadata carries the R6
  core package (`r6-sd-packages`) and `dispatch` sets `current-sd-packages` from it (outside settings
  win); `All OK (FHIR R6 (6.0.0-ballot4))`. capability-guide-test.
- **`write … enforce=true` under a type already listed** wrote a second `Observation:` line; YAML kept the
  last, so the new profile (or the old) was silently not enforced. The new canonical joins the type's
  line, and the reader keeps both when a type is named twice (fhir/lang/workspace). bp-rule-test.
- **CQL without FHIRHelpers compared raw FHIR values**: `Patient.gender = 'female'` answered false for a
  female patient; now a translation error naming the include (cql/CLAUDE.md). cql tests/helpers-test.
- **FHIR JSON in each type's element order** (`fhir/serialize/fhir-json`: the registered tower's field
  order, `_x` after `x`, unknown keys last; by name without a tower): a Quantity reads value, unit,
  system, code. `racket x.fsh|.map|.vcl` prints it indented.
- **`#lang` build errors show the line and a caret** (`raise-diagnostic` reads the source file when it
  can); `raco make` still adds Racket's own `compilation context…` lines.
- **Guides as files**: `raco fhir guide <topic> --blocks` lists a guide's code blocks, `--block N` prints
  one (`raco fhir-mcp guide` too); `raco fhir guide racket` is the Racket route on one page
  (`fhir-mcp/learn/racket.md`; fhir-examples' intake-pipeline-test runs its command blocks as written).
- Smaller: a misspelt interaction gets the nearest (`search` -> `search-type`, a prefix counts); "found no
  subject" says to add a rule for it; the capability guide's smallest server serves `$validate` and its
  decimal outputs are numbers throughout, with one operation using every input option (tested, 57.5);
  learn://workspace's `bp` view matches system and code as the rule does, its `Reading` RuleSet takes no
  unused id, and the correction recipe starts from `as=source`; the CQL guide says how to read an empty
  answer and what needs FHIRHelpers.

## New users, round 22 (2026-11-11)
The twenty-first rerun (every task first time, 10–14 calls, right answers, no source read; three of the
four saved a guide recipe with `--block N`) left small things; each fix has a test doing it:
- **The trail opens from where you are**: `describe ref=<Type> as=trail` called from another folder
  shows `source`/`at` relative to it when the file is there (`paths-from-here!`; SQL's `trail` keeps the
  workspace's form). A created value's `at` is the rule that set it (`* valueQuantity`, else the first
  component), not the Instance header. views-test, skill-batch-test.
- **FHIR JSON in the specification's order, choices included**: the generated schemas list choice members
  last, so `fhir-json` places each element by its core StructureDefinition's snapshot when one can be read
  (`sd-element-order`, sd-index loaded on demand; the schema order otherwise). The shell's answers print
  resources that way too (verbs.rkt `answer-json`): `apply` showed a Quantity as code, system, unit, value.
- **Tables a person reads**: the CQL recipe has `Ever Above 9` beside `Above 9` (latest vs ever: "nobody
  above 9" read as a bug); a run's hint is `run path=… as=csv columns=…` with a name column first; a Quantity
  define is summarised by count/min/max/mean and unit (cql `tally`); an unknown-column hint lists only the
  tables the statement reads (`tables-read`: a column `patient` is not the `Patient` table).
- **Guides**: learn://workspace has the patients view (with a name), the summary by name and one whole
  `readings.fsh` (RuleSet, a Patient, two readings — staged as is in bp-rule-test), and says referenced
  patients should be stored; the fhir skill leads the shell route with one batch of the whole session (run
  as written: skill-batch-test); `--blocks` names each block's section; the capability guide's wait loop
  gives up after 30 s and prints the log, an R4-to-R6 table for common resources, R6's own warnings
  (obs-12); learn://racket's API card reads the input (`json`'s `read-json`), says `#:now #f` is today, and
  says what `raco make` checks and what only `raco fsh check` does.

## New users, round 23 (2026-11-11)
The twenty-second rerun (every task first time, 7–14 calls, right answers, no source read; the server
agent's task now matched the guide's eGFR example, so round 24's asks for a QTc operation instead).
Each fix has a test doing it:
- **One path form in what describe answers**: `describe … /_history` from another folder shows `source`
  and `at` from there, as the trail CSV does (`history-from-here`, `path-from-here`); SQL's `trail`
  keeps the workspace's form (the guide says so).
- **A missing item is placed where it goes**: "found no component matching '8462-4'" is at the last rule
  writing `component`, "add a component with '8462-4' after this line" (`last-rule-line`); "found no
  subject" stays at the header.
- **`stage … keep:=false` checks only**: the same answer, no stage kept (a refusal shown on purpose
  needed `stage drop=refused` after it).
- **Guide blocks by name**: `raco fhir guide <topic> --block <name>` takes the first block whose first line
  has the word (`LatestA1c`, `BloodPressureRule`, `egfr`, a view's `bp`); the docs use names, so a block
  added above does not break a script. One command in the docs: `raco fhir guide`.
- **Tables a person reads**: the CQL recipe's `Latest Result` (`8.9 %`, the value with its unit) replaces
  `Latest Unit`; the run's hint lists a name, then text, then numbers (`Name,Latest Result,Latest
  Date,Above 9,Ever Above 9`, the guide's own table); CQL `explain` explains each define once (`explained:
  "above"` on a second use); the `copied` note is short.
- **Racket route**: `--now` that is not a date is one line (`"01/05/2015" is not a date (2026-01-01) or a
  DateTime`, a user error); FML says when a `where` dropped what the source matched (`its source matched
  1 item, but `where (linkId = 'gender')` held for none (the first: …)`, recorded in transform.rkt
  `source-matches`); learn://racket gives the `main.rkt` shape `tests.rkt` drives and the ~3 s startup.
- Capability guide: the eGFR block is pasted into the smallest server; a create says nothing of
  warnings (validate first).

## New users, round 24 (2026-11-11)
The twenty-third rerun (every task first time, 7–18 calls, right answers, no source read; the server task
was a QTc operation the guide does not contain) found one defect and a gap in our own guide; each fix has
a test doing what the agent did:
- **A search says what it did not apply** (workspace.rkt `run-search`): `Patient?_has:Observation:subject:code=4548-4`
  answered every patient, silently (the store ignores what it cannot apply). The answer now lists
  `ignored` at its top — reverse chaining, chaining, an unsupported modifier, a name the type does not
  search on (with the nearest) — and a `note` that the answer is the search without them;
  `query … strict:=true` refuses such a search (`fhir-search/ignored` over the store, and the file index,
  whose procedure answers `(values resources ignored)`; `search-param-names`). learn://search says so, and
  the skill's table sends "has none" to CQL.
- **The guide's blood-pressure rule wants a number** (`value.exists()` in each component's `where`): a
  unit with no value passed, and the summary's mean would have left the reading out without a word. The
  evidence says `'mm[Hg]' (no number)` (validate.rkt `compact-json`; it printed like a Coding). The guide
  says the rule is about LOINC-coded readings only.
- **`keep:=false` answers say "would create"**, and list every warning (dangling references too);
  `commit` answers the `reason` it recorded; `--blocks` prints the name `--block` takes (`block-name`: an
  FSH entity, a CQL library, a view's `name`), and a name is matched as a block's own name first.
- **Servers**: `(operation $validate)` without its require says which module provides it
  (`capability/op-ref.rkt`, expanded with the body: Racket said `$validate: unbound identifier`); strict
  search's refusal lists `_id, _lastUpdated, _count, _offset, _sort` too; the capability guide has an
  operation with two outputs, one boolean (`$map`, tested), says `#:min`/`#:max` are inclusive and to
  decide on the exact value and round only what is returned; the skill shows curl as the fast call.
- **Racket route**: FML's "where held for none" lists what the tested field held and the nearest
  (`the linkId there: name, gendr — did you mean 'gendr'?`; `where-evidence`, every matched item kept
  in `source-matches`); learn://racket lists the diagnostics API for tests; `init` and its CLAUDE.md
  name `raco fhir guide`; fml's guide writes `raco fml`.
Not done, named: a warning when a CQL library's FHIR version differs from the data's.

## New users, round 25 (2026-11-11)
The twenty-fourth rerun (every task first time, 6–14 calls, right answers, no source read) left one risk
and two missing tools; each fix has a test doing what the agent did:
- **`(server #:references "checked")`** (capability/runtime.rkt `unheld-references`): a create or update
  whose literal reference names a resource of a served type the server does not hold is a 422 naming it
  (a study server stored an Observation of `Patient/nope` without a word); a reference to a type the
  server does not serve, a contained, absolute or urn: one is not decided. Default unchanged.
- **`raco fhir check-files [dir|file …]`** (`fhir/check-files`): every `#lang` `.fsh`/`.map`/`.cql`/`.vcl`
  file compiled on its own in a fresh namespace, each one's problem printed at its line, all in one run,
  exit 1 — `raco make main.rkt` stopped at the first, so three typos took three runs (fhir-examples'
  intake-pipeline-test plants one in each language).
- **The template's `tests.rkt` reads its expectations from the files**: the Instances of `fsh-invalid/`
  and the birth date (the `valueDate` answer, whatever its linkId), so a project of one's own runs it
  unedited (an agent changed it with `sed`).
- **Every guide block has a name**: `block-name` reads a leading `-- name` (or `;; name`) comment and
  the first FSH entity past `Alias:` lines; the workspace guide's SQL blocks are named (`bp-summary`,
  `bp-summary-by-name`, `a1c-trail` …; mcp/sql.rkt's `reading?` skips leading comment lines).
- **Smaller**: `keep:=false` lists dangling references once for the stage (`references`), after the
  errors; `--now` says `write it as 2026-01-01, or 2026-01-01T12:00:00Z` (its examples read as today's
  date); learn://workspace says what `at` points to for each kind of resource; the capability guide's
  UCUM table has heart rate and ECG intervals with their LOINC codes, and says any number is a decimal.

## New users, round 26 (2026-11-11)
The twenty-fifth rerun (every task first time, 4–20 calls, right answers, no source read) found, by
planting mistakes on purpose, two gaps in the capability language; each fix has a test doing it:
- **An operation answers what it declares** (capability/runtime.rkt `output-problems`, for operations an
  app declares inline — `urn:fhir-capability:operation:` canonicals; a registered one is the package's):
  an output the handler gives that `#:out` does not declare (with the nearest), a required one it leaves
  out, or one of another type (`valueString` for a decimal) is a 500 naming each — an undeclared
  `prolonged` was served 200 and the OperationDefinition no longer said what the operation returns.
- **Every mistake of a form at once** (declare.rkt `within-form`/`checked`): a resource's bad interaction
  and its misspelt search-parameter type, an operation's bad `#:in` and `#:out` types, are all said;
  each form raised its first (the round-12 collection was per form).
- **`duplicate field Parameters.parameter`** says the fix (lang-gen/form-syntax.rkt: a repeating field
  takes all its values in ONE form, `(parameter A B …)`).
- **UCUM spellings**: `msec` is `ms`, `bpm` is `/min`, `sec`, `hr`, `lbs`, `degC` … (validate.rkt
  `ucum-spellings`), before the nearest-by-name suggestion.
- **Racket route**: the template's `main.rkt` takes `--now` before or after the file and says a missing
  file in one line (exit 2; fhir-authoring shows it whole, the test compares); `tests.rkt` says what
  `main.rkt` must provide when it lacks `intake`; the fhir skill's Racket section is a pointer to `raco
  fhir guide racket`, the one page.
- Docs: the skill lists `as=csv columns= sort= name= keep:= strict:=`; the guide's 140/90 SQL says in a
  comment that it reads systolic OR diastolic; the capability guide says outputs are held to `#:out`.

## New users, round 27 (2026-11-11)
The twenty-sixth rerun (every task first time, 4–15 calls, right answers, no source read) found a claim
of our own that did not hold and two quiet data-quality gaps; each fix has a test doing what the agent did:
- **The template's `tests.rkt` names its layout at its top** (`profiles-folder`, `invalid-folder`,
  `input-file`, `main-file`) and says in one line when one is not there — "run it as it is" held only
  for the template's own folder names (an agent's `profiles/` got `directory-list: could not open
  directory`); learn://racket says what is required (the `#lang` lines, an invalid example in its own
  folder) and what is the template's choice.
- **A code without its system is said at stage time** (workspace.rkt `systemless-codes`): a blood pressure
  coded `#85354-9` passed the guide's rule (keyed on LOINC) and dropped out of the views without a word;
  each such coding is a warning naming the system its shape suggests (LOINC digits-digit, SNOMED digits).
- **Reverse chaining and chaining are refused** (run-search): answered without them the search listed
  every patient beside a note; `ignored` stays for what a strict search would refuse.
- **Servers**: the smallest server declares `#:references "checked"`; the banner says the store is
  created on the first request when the file is not there yet.
- Smaller: a Quantity or Coding inside an answer reads in FHIR's order (verbs.rkt `answer-json`: an
  explain printed `code, system, unit, value`); the skill shows `explain ref=result://<name>`; fml's
  guide has the text-answer gender rule beside the coded one.

## New users, round 28 (2026-11-11)
The twenty-seventh rerun (every task first time, 7–19 calls, right answers, no source read) found two of
our claims that did not hold; each fix has a test doing what the agent did:
- **A `#lang fsh` file of examples whose profile is in another folder** (fsh/CLAUDE.md): run alone it
  failed with a stack trace through sd.rkt, and `raco fhir check-files` said `ok`. The module now
  raises one line at the Instance's header with where the profile is (`require that module before this
  one, or check this folder with raco fsh check bad --context profiles`); required after the profile's
  module it builds (an InstanceOf found in fhir/registry by name); check-files RUNS each `.fsh` module
  and prints that as a note (`fhir/check-files`).
- **The template's `tests.rkt` takes a `.fml` map** (its last check matched `.map:` only).
- **Smaller**: one unknown operation input beside one missing required input is said as one mistake
  however far apart they are spelt (`(`hr` was given instead: is it this input?)`, runtime.rkt `lone`);
  `raco fhir-mcp call|batch --indent` lays JSON answers out in the answer's own key order
  (`indent-json-text`, mcp-cli.rkt); `--blocks` reads a block's name from the comment after a `#lang`
  line (`;; smallest`, `;; minimal`, `;; clinic`); the rules cookbook has `code-system` (a code without
  its system is refused, a stage alone only warns).
- Docs: the skill's inline SQL batch line (escaped column names, booleans 1/0, empty rows = nobody;
  skill-batch-test runs it), `agent=Practitioner/x`, trail paths in describe vs SQL, write vs a file put
  there; learn://racket's smallest `main.rkt` (run as written in intake-pipeline-test), fhir-authoring
  pointing to it; the capability guide's input types (decimal for measurements), `patient` vs
  `subject` under strict search, the smallest server by `--block smallest`; the bp summary's "both" line.
Not done, named: a handler's output names checked against `#:out` when the module loads (only the
call checks them: the handler is code, its outputs known when it runs).

## New users, round 29 (2026-11-11)
The twenty-eighth rerun (every task first time, 6–20 calls, right answers) found one option that said
what the server did not do and one of round 28's claims that did not hold; each fix has a test:
- **`(server #:fhir-version "4.0.1")` is refused** at the option (declare.rkt): `/metadata` said
  4.0.1 while `$validate` answered R6. A capability server is R6; only its own version is accepted.
- **A misspelt operation input is one issue**: the "required (`hr` was given instead …)" problem
  claims the unknown input, whose own "is not an input" issue is dropped (runtime.rkt `claimed`).
- **The blood-pressure rule refuses `#85354-9`** (`bp-coded`: a 85354-9 coding names LOINC); a
  systolic-only reading coded without its system went through with a warning.
- **`raco fhir check-files`** prints `needs context  bad/bad.fsh — `IntakePatient` is defined in
  …` for an example whose profile another folder defines (it printed "ok … note: … compile error").
- Docs: the skill's rule and correction rows point to learn://workspace's whole-program paragraph,
  SQL as a file first; the capability guide says outputs are checked when an operation runs (call each
  once) and how to choose ids (`update`, PUT); learn://racket's smallest main.rkt names its FHIR
  versions, `.map` or `.fml`, options before the file; fsh's guide says a missing element is at the
  Instance's line; learn://workspace on adapting the rule to another panel.
- The cohort agent's task now differs from the guide's worked example (eGFR below 60, not HbA1c above
  9), so the rerun tests adapting the recipe, not copying it.

## New users, round 30 (2026-11-11)
The twenty-ninth rerun (every task first time; the cohort task now eGFR, not the guide's HbA1c) found a
wrong answer by probing: a CQL quantity literal in a unit that is not UCUM. Each fix has a test:
- **CQL refuses a unit that is not UCUM** (cql/CLAUDE.md): `< 60 'mL/min/1.73m2'` translated, every
  comparison was null, and the recipe's yes/no said "no" for a patient at 48. The suggestion table
  (`ucum-suggestion`: common spellings, then the nearest clinical unit) moved from fhir-validation's
  validate.rkt to `fhirpath/ucum`, one definition for the validator, FSH and CQL; the latest-value
  recipe's `Above 9` answers `unknown` when its comparison is null.
- **`(server #:warnings "refuse")`** (store/validated.rkt `refuse-warnings?`, read from the app's
  metadata): a write whose only problems are warnings (a Quantity in `msec`) is a 422; default stored.
- **`raco fhir-server check <app.rkt>`**: one line per resource and operation, or the mistakes (exit 1)
  — `racket app.rkt` printed 150 lines of CapabilityStatement to say it compiles.
- **A refused check-only stage says its errors alone** (no `references`): two reruns' agents read the
  dangling-reference note beside a rule's refusal as noise (round 25 had listed them; a clean check
  still does).
- **FML: a `where` that held for none is said at its rule's line** (fml/CLAUDE.md), not the nested
  rule's; `raco fhir check-files` leads a needs-context line with the command to run.
- **The template's `tests.rkt` finds a layout of other names** (the one folder declaring a Profile, the
  other holding Instances, the one json naming a QuestionnaireResponse) and says what it used.
- **Batch lines**: `\n` inside double quotes is a newline (inline FSH read `\n` as `n`).
- Docs: learn://workspace's `Reading` block is the RuleSet alone, `readings` the sample file, and a
  `bad-readings` block (the three refusals) is new — `--block` names read `// name` FSH comments; the
  Racket guide opens with what is required when writing your own; the capability guide on `check`,
  `#:warnings`, `patient` vs `subject` beside the smallest server; cql's guide on annotation units.

## New users, round 31 (2026-11-11)
The thirtieth rerun (every task first time, 8–13 calls, right answers; the cohort task now LDL) found no
wrong answer; the one quiet risk left and the small things, each with a test:
- **A run says when a define is null for every patient** (cql/workspace `all-null-notes`, the run
  summary's `notes`), with the units its text compares with — an LDL rule in `'mmol/L'` over mg/dL data
  was null for all three patients and the run said nothing (UCUM converts no molar unit to a mass one).
- **A refusal says what the value is in the rule's unit** (validate.rkt `with-conversion`): `found
  component[0].valueQuantity = 20 'kPa' (= 150 'mm[Hg]')` when the invariant names a unit
  (`code = 'mm[Hg]'`) the found one converts to — so a steward corrects the reading instead of dropping it.
- **Strict search names the other half of `patient`/`subject`** (runtime.rkt `patient-subject-hint`):
  `subject` refused where `patient` is declared says `did you mean patient? it reads the subject when it
  is a Patient`.
- Docs: learn://workspace's whole-program paragraph checks the refused reading with `keep:=false`;
  cql's guide lists the HbA1c-named defines to rename for another lab and `>=`; the fhir skill opens with
  the Racket pointer, gives the server row's first command (`--block smallest`, `check`, `serve`) and
  says which trail view has values; the capability guide's references are R6's; `raco fsh check`'s
  default-canonical note says how to set it.

## New users, round 32 (2026-11-12)
The thirty-first rerun (every task first time, 9–16 calls, right answers; the cohort task now potassium)
found one gap in the UCUM suggestions and one over-reach of round 30's; each fix has a test:
- **`mEq/L` and `IU` get what UCUM writes** (fhirpath/ucum `ucum-spellings`: `meq/L`, `[IU]/L`, …), in
  CQL, FSH and the validator; CQL's error is at the quoted unit (cql error.rkt `at-the-name`). Labs
  write potassium, sodium and chloride in mEq/L; the message pointed at ucum.org.
- **A refused check keeps the references of what passed** (workspace.rkt): round 30 dropped every
  dangling-reference warning when any change was refused, so a passing reading's missing patient took a
  second check. A refused change still says its errors alone.
- **A refusal's non-UCUM unit says what UCUM writes inline** (`130 'mmHg' (mercury is written mm[Hg])`,
  validate.rkt `with-conversion`).
- **The blood-pressure program as one session** (learn://workspace `--block bp-session`, a batch file;
  `block-name` reads `# name`): every file saved from the guide by name, `init`, `batch` — run as written
  in `fhir-mcp/tests/bp-session-test.rkt`. The sample file's block is `readings-sample` (it was
  `readings`, one letter from the RuleSet's `Reading`).
- **`raco fhir new tests [dir]`**: the template's gate alone, saying what it checks (an agent generated
  the whole template for one file). learn://racket's smallest `main.rkt` says a missing file in a line.
- **FML says why a date is unread** (`fhir/serialize/lenient` `drops-message`: `valueDate
  ("1990-02-30") is no date: February 1990 has 28 days`; it said "not a valid value, or not an element").
- Docs: the capability guide on stopping a backgrounded server by the banner's pid.
Not done, named: a lab-neutral, parameterized latest-value recipe (the HbA1c names are listed to
rename); `check --call` and Quantity inputs with unit conversion on capability servers.

## SQL on FHIR where tables are made (2026-11-11)
An audit of where the toolkit flattens FHIR into tables found hand-written JSON SQL doing a
ViewDefinition's job, and under it a load-order defect; both fixed, each with a test doing it:
- **One process, one tower per name** (`fhir/model/registry`): types register by NAME, and the
  sql-on-fhir engine's ViewDefinition model is built over R6 — loading it replaced an R4 workspace's
  Provenance, Observation, MedicationRequest … with R6's, so a correct R4 view was refused (`no element
  MedicationRequest.medicationCodeableConcept`) and R4-only elements read as nothing; which tower won
  depended on what loaded last. `pin-registered-types!` keeps the types registered now against later
  registrations (a new name, ViewDefinition, is still added); the hub pins its tower when it
  configures (`unpin-registered-types!` before loading another). `fhir-mcp/tests/views-test.rkt` fails
  without the pin.
- **The workspace's own tables are ViewDefinitions** (`fhir-mcp/mcp/views.rkt`, run by the
  sql-on-fhir engine like a workspace's `*.view.json`): `trail` is `trail-view` over Provenance (a
  `forEach` over the versioned targets; type/id/versionId by FHIRPath, the reason R4's `reason.text`,
  R5's `why`) — it was ~20 lines of `->>`, `json_each` and string slicing in a SQLite view;
  `describe … as=trail` joins `values-view` (generated per type from the elements the workspace's
  tower gives it: subject, value[x] else components joined by " / ", the first date the type has)
  and `names-view` to it — it was COALESCEs of JSON paths that fitted Observations only.
- **The SHA-1 is its own element**: a Provenance's source is `entity.what.display` (the file) and
  `entity.what.identifier` (system `urn:ietf:rfc:3174`, hex); the display carried both and SQL cut
  them apart. R5 Provenances carry the reason as `why` (R5 has no `reason`).
- **Docs lead with views**: the fhir skill, learn://workspace (the audit queries go through the guide's
  `a1c` view, its JSON read by trail-test), fhir-serving and the capability guide; the JSONB tables
  are the escape hatch for a one-off. Search indexing (SearchParameters), CQL results and the raw
  store views stay as they are: they are not flattening for analysis.

## The store as the codebase; the implementation guide as a language (2026-11-12)
The design is `docs/store-as-codebase.md`: the SQLite store as a CRMI artifact repository (HL7's
Canonical Resource Management Infrastructure 2.0.0, read from its package and guide pages —
status and version rules, manifests, the sixteen repository actions and their operations), the
languages as the text an agent edits, FHIR's own versions, Provenance and transactions as the
version control, git as a mirror of a text export. Built so far, step 0:
- **`sushi-config.yaml` is the seventh workspace language, "ig"** (fsh's `ig.rkt`,
  `ig-workspace.rkt`, `ig-guide.md` — `learn://ig`; fsh/CLAUDE.md). No new syntax: SUSHI's file,
  compiled to the ImplementationGuide that lists what the workspace's other languages define.
- **The workspace reads its guide** (`fhir/lang/workspace` `with-guide`,
  `workspace-implementation-guide`): the canonical, the FHIR version, `dependencies` as packages
  and `global` as profile constraints come from sushi-config.yaml, for every language;
  workspace.yaml keeps the data, audit, parameters, remote writes and models. A fact both state is
  the guide's, with a warning. A dependency `<id>-<version>` is located as fsh locates it
  (`dependency-packages`: also `<id>.tgz` when that package is the version asked for). The hub
  reconfigures when the guide is written, as for workspace.yaml.
- **One reader of the guide file** (`fhir/ig-config`, moved from fsh with `fhir/yaml`; fsh
  re-exports both): the FSH compiler and packer, the ImplementationGuide compiler, the workspace's
  configuration and the staging of artifacts all read the same `ig-config`.
- **A language that composes the others** provides `composes-workspace` (`workspace-composes?`):
  the hub computes it last and again whenever what the earlier languages define changes (its cache
  is keyed by their resources). `fhir/registry`'s `registered-by` enumerates what sources registered.
- `init` ignores `fhir.db` in git (it ignored only the WAL files: `git add .` took a binary that
  could lack the writes still in the WAL).
`fhir-mcp/tests/ig-test.rkt` runs the guide's own session.
Step 1, definitions through stage and commit (CRMI's Submit and Revise):
- **CRMI 2.0.0 is vendored** (`fhir-spec/hl7.fhir.uv.crmi-2.0.0.tgz`; its dependencies are not:
  fsh loads the newest extensions and terminology packages it finds into every project). Its 70
  profiled examples validate against its own profiles (the IG validation gate, 0 false positives).
- **`stage path=sushi-config.yaml` stages the collection** (workspace.rkt `collection-resources`):
  the guide first, then every resource the FSH, CQL, FML, VCL and JSON files define — artifacts and
  examples — one change set; `definitions:=true` stages an FSH file's or text's own definitions.
  Staging a definition without a guide is refused (its version is the guide's).
- **An artifact on its way in** (`mcp/artifacts.rkt`, pure, by CRMI's rule numbers;
  `in-collection`): its status is the collection's (draft when the guide states none — a
  compiler's default `active` is not the author's word), its version, experimental flag and
  publisher the collection's where it states none (3.5); one that states its own version (a CQL
  library) keeps its released state while the collection drafts on; a title and description are
  derived only for languages with no place for them (name; a library's leading comment). These
  authoring rules are for what the workspace's own languages wrote (`authored-language`): a
  definition given as JSON or taken from a result is somebody's published artifact, staged as it
  is. It is held to CRMI's
  Shareable profile of its type through `$validate` with the CRMI package in context (R4; the same
  minimum checked directly otherwise), each missing element saying where it is written. The
  lifecycle (3.1, 3.4): an active artifact does not go back to draft, a retired one does not come
  back, and neither changes content without a new version; retiring changes the status alone.
- **Each version is its own instance**: when another version begins under an id whose stored
  instance is active or retired, that instance is kept as `<id>-<version>` (`archive-of`) in the
  same stage.
- **Which definition a canonical means** (`working-copies-first`, the data source `with-hub`
  sets): a stored artifact a workspace file defines again is left to the file (the working copy,
  found in fhir/registry next); among stored versions of one url the active of the highest version
  answers, else the highest (`current-versions`). Reads by Type/id are the store's own.
  `describe ref=<url>` follows that; `<url>|<version>` names a stored version.
- A stage lists a resource stored unchanged that no longer passes (a rule changed under it) with
  its errors: staging a new rule says which stored examples it breaks.
`fhir-mcp/tests/artifacts-test.rkt` runs the whole sequence.
Quality pass over this work (2026-11-12; behaviour held by the tests above and the full suite):
the guide file had three readers (fsh's ig-config, the workspace's own parse of its facts, the
ImplementationGuide compiler's of dependencies and `global`) — now one; `stage!`'s steps are named
functions (`authored-artifact`, `change-of`, `archive-change`) with no side table; the hub's cache
entry is a struct (`compiled`: files, basis, resources, diagnostics) instead of two keys per
language; ig.rkt threads the instance labels through a fold instead of a mutable counter. One
behaviour corrected with it: the CRMI authoring rules had applied to ANY staged definition, so a
published Questionnaire given as JSON was refused for lacking a title, or turned to draft in a
draft guide. First cut of the hub (`mcp/workspace.rkt`, 2,168 lines, 153 definitions): the nine
functions that read a stage's FSH source as text (where an Instance and its rules are, the block
that stages again, the line an error is about) are `mcp/fsh-source.rkt` — pure, with contracts,
one definition of an entity header (there were three spellings) and the tests they never had.
Step 1, continued — the store alone, and edit (2026-11-12; `tests/artifacts-test.rkt` 5 and 6):
- **The guide read from the store** (`hub.rkt` `stored-guide`, `hub-guide`, `hub-guide-label`):
  with no `sushi-config.yaml` and a store that holds one ImplementationGuide url, its current
  version (the active one, as for any canonical) is the workspace's guide — read as the text it
  is handed back as, so file and store state the same facts (`open-workspace #:guide`, fhir/lang/
  workspace: canonical, FHIR version, dependencies as packages, `global` as profiles; a
  difference from workspace.yaml is a warning naming "the stored ImplementationGuide"). `check`'s
  configuration says where the guide is read from (`guide`). A broken file is still the working
  copy; several stored guides are a warning and none is taken.
- **edit** (`describe.rkt` `artifact-of`, `artifact-text`, `hub-edit!`): `describe ref=<canonical
  | Type/id> as=source` answers a stored definition as the text that states it, and `write
  path=<file> ref=…` writes it as its file (refused under a path of another language): a Library
  as its CQL (its content), the guide as `sushi-config.yaml` — the file its commit kept when that
  states this version and package, else fsh's `implementation-guide->config-text` — the rest as
  FSH without the version, status, experimental flag and publisher the guide gives (stated in the
  text they would no longer follow it). An archived version is written under its own id
  (`unarchived`, artifacts.rkt: the id is its url's last step). The text compiles to what is
  stored: staged unchanged it is "nothing to commit".
- **Definitions are staged under a guide being drafted**: with only a released (active, retired)
  stored guide, a definition's stage is refused with the call that hands the guide back.
- **A Provenance per source file** (`stage.rkt` `collection-sources`; `change` carries its
  `source`): a guide's stage records, for each resource it lists, the file that defines it — an
  FSH file read as text (`fsh-source.rkt` `definition-line`: the entity whose `Id:`, else whose
  name, is the id; `instance-line`), a file of another language asked what it alone defines — and
  the commit writes one Provenance per file (the guide's own first; the answer lists them as
  `provenances`), each target at its line (`lab.fsh:1`). So SQL's `trail` names each resource's own
  file, and **edit hands back the kept text** (`describe.rkt` `kept-text`): for the version its
  commit wrote, the FSH entity that defines it with the RuleSets, Invariants and Aliases it uses
  (`definition-block`; comments included, the file's other entities left out), a library's `.cql`,
  a value set's `.vcl`, a map's `.map`, the guide's file. Written from the resource only where no
  commit kept such a text (an archived release, a definition loaded from elsewhere).
Not yet, named: a definition staged alone in a store-only workspace is not added to the stored
guide's `definition.resource`. (A stored StructureMap with no kept text comes back as the mapping
language since 2026-11-13: `describe.rkt` `map-text`, fml's printer — below.)

Step 2a — pins: which version a canonical means (2026-11-12; `tests/pins-test.rkt`):
- **The pins are CRMI's manifest parameters**: a Parameters resource of `default-canonical-version`
  (any definition), `default-valueset-version`, `default-system-version` (and their deprecated and
  `force-` spellings), each a `url|version`. `mcp/artifacts.rkt`: `pinned-version`,
  `versions-in-force` (one per url: the pinned version when it is stored, else the current one —
  the generalisation of `current-versions`), `guide-manifest`.
- **The guide names its pins as the IG Publisher is told** (`fhir/ig-config`
  `ig-config-expansion-parameters`): `parameters: path-expansion-params: …/Parameters-<id>.json`
  is the Parameters with that id — an FSH instance or a JSON file of the workspace, else the one
  the data holds. fsh's `implementation-guide` contains it in the compiled guide under
  `cqf-expansionParameters` (CRMIImplementationGuide, as CRMI's own example), so a guide read from
  the store brings its pins; a name nothing defines is a warning at its line (`ig-workspace.rkt`).
- **In force for every resolver**: `hub.rkt`'s `hub-manifest` (the call's `current-manifest`,
  else the guide's) decides the view `with-hub` sets as `current-data-source` — among the stored
  versions of a url the pinned one answers; a working copy (a workspace file's definition) still
  comes first. `current-repository` is the data as stored, every version.
- **`manifest` on every tool but write and commit** (`verbs.rkt` `under-manifest`; `data.rkt`
  `manifest-argument`: a Parameters resource, its JSON text, or `Parameters/<id>` the workspace
  defines or stores): one call under other pins — `stage … keep:=false manifest=@pins.json` holds
  a reading to the draft profile, `describe ref=<url> manifest=…` answers the draft.
- **`$resolve`** (`mcp/crmi.rkt`, loaded with the operations): CRMI's operation on its own
  OperationDefinition, read from the vendored package — `canonical`, `resourceType`,
  `manifestParameters` and the version parameters given directly; the version named, else the
  pinned one, else the working copy, the stored version in force, the packages. A manifest
  *library* by canonical is refused, named. It reads the repository through parameters and knows
  no hub.
- `raco fhir-mcp call … key:=@file.json` reads an argument's JSON from a file (an operation's
  inputs, a manifest).
Not yet, named: pins on a dependency PACKAGE's artifacts (the package index resolves an
unversioned canonical to the package in context); the manifest library (composed-of, depends-on);
`X-Manifest` on served repositories; `check-…-version`.

The hub split (2026-11-12): `mcp/workspace.rkt` is now 41 lines — the contracted interface, as
before (verbs.rkt, mcp-cli.rkt and every test are untouched). Under it, each a module along one of
the old file's sections, in dependency order (no cycles): `calls.rkt` (how an answer names the next
call), `json-diff.rkt`, `results.rkt` (a result's name, its answer, its rows as a sorted table, two
results compared) — leaves with contracts and the tests they never had; `hub.rkt` (the Hub: the
structs, opening and configuring, paths, what the files define, the state kept in `.fhir-mcp/`,
results and stages); `data.rkt` (the data read whole, a resource held to the workspace's rules, the
trail written); then one module per verb: `check.rkt` (write, check), `run.rkt` (run, query,
explain, and the hub's own SQL, search and FHIR JSON), `apply.rkt`, `describe.rkt`, `stage.rkt`
(stage, commit; it reads a history from describe, never the reverse). The modules were generated
from the old file form by form (each with its comments), so no definition changed but these: an
unused struct field and an unused function removed, `run-sql` uses `view-names` instead of its
copy. Writing `json-diff`'s tests found a defect: `text` was skipped at every depth, as the
narrative is at the top, so a corrected `note.text` or `code.text` was "unchanged" — the stage said
the resource was stored as it is and nothing was committed. Only a resource's own `meta` and
narrative are left out now (trail-test corrects a note).

## FML as its specification writes it; the printer (2026-11-13)
The user's rule: "Print only the official grammar. My language should match the specified language
as much as possible." fml/CLAUDE.md has the detail ("The specified language; the printer"); in short:
- The specification's text and its formal grammar disagree (the header, url and rule-name quoting,
  string quotes): both are read, the text's form is written.
- Forms the specification has that fml lacked or dropped are implemented (metadata lines, the
  `draft` default, a source's type, cardinality and default, `let` constants, the short form, calls
  with nested rules, bare `share`, backticked names).
- `fml/print` (`fml->text`) writes any map or StructureMap in the specified language only;
  `raco fml --decompile`; fhir-mcp's edit hands a stored StructureMap back as a `.map` file
  (`tests/artifacts-test.rkt` 7). So every workspace language now comes back out of the store as text.
- What fml reads beyond the specification (unparenthesized `where`/`check`, `where` before the
  alias, `share <id>`, `conceptmap`) is a warning at the form from `check-map`; the family's own
  maps, guides and messages are in the specified form. `block-name` (guide blocks) and fml's editor
  outline read the metadata header.

## The store in git; what depends on what (2026-11-13; `docs/store-as-codebase.md` steps 3 and 5, in part)
- **The text export** (`fhir-mcp/mcp/export.rkt`; workspace.yaml `export: export/`, which `init`
  writes; `ws-config-export`). A commit that writes a definition rewrites the directory: the files
  the commits KEPT (each source file a Provenance holds inside the workspace, its newest text, as
  long as it still states a stored resource: the author's own lines), plus one file per current
  definition — and per example the stored guide lists — that no kept file states, written from the
  resource (`<Type>-<id>.fsh|cql|map|vcl`, the guide as `sushi-config.yaml`; describe.rkt's
  `artifact-text`). "Current" leaves out a released version archived beside the next (git has it).
  The directory is never a source (`workspace-files` skips it); only files an earlier export wrote
  are removed (remembered in `.fhir-mcp/export.json`), and `export` naming the workspace itself is
  refused. `raco fhir-mcp export [--check]` writes it, or (CI) says `differs`/`missing`/`stale` and
  exits 1. The law, `tests/export-test.rkt`: the export put back as the workspace's files is
  "nothing to commit".
- **Found by that law**: fsh's workspace support compiled every `.fsh` under the workspace root
  (the data directory and any copy included), so a second copy of a file listed each definition
  twice in the guide. `compile-project`/`check-fsh-project` take `#:files`, and fsh/workspace gives
  the workspace's own (`workspace-files`).
- **Dependencies as CRMI traces them** (`mcp/dependencies.rkt`, pure): the catalogue is DATA —
  `traced-paths`, per type, CRMI's "Dependency Tracing" paths as it writes them (`item..answerValueSet`
  = at any depth of items), `meta.profile` for every resource, the base specification implied.
  `direct-dependencies`, `dependency-closure` (breadth first, each canonical once, the resolver an
  argument; what nothing defines is listed, not followed), `module-definition`, `dependency-rows`.
- **A CQL library states its own** (cql `requirements.rkt`, from the ELM as JSON; cql/workspace's
  Library): each include, codesystem and valueset a `depends-on` relatedArtifact, each retrieve a
  `dataRequirement` (type, the ELM's templateId as profile, the code or value set filter) — what
  CRMI's computable library carries, so tracing reads the resource and needs no CQL.
- **`$data-requirements`** (`mcp/crmi.rkt`, on CRMI's own OperationDefinition): the artifact by
  `url` (+`version`), `id` or as the subject; its closure resolved as `$resolve` resolves
  (`artifactVersion`/`forceArtifactVersion` as pins, else the manifest in force); a
  module-definition Library. `manifest`, `expression`, `parameters`, `checkArtifactVersion` are
  refused, named. **SQL's `dependencies`** (run.rkt `builtin-tables`): one row per stored resource
  and target, so "what depends on X" is a query. `tests/dependencies-test.rkt`.
Not yet, named: `$infer-manifest-parameters`; the impact answer at stage time (dependents
re-checked, results out of date); requirements against a data source's capabilities; the export of
data that is not an example.

## Defects the documentation pass found (2026-11-13)
Rewriting the manuals for a first-time reader meant running every command; about forty things did
not do what a reader would expect. Each fix has a test doing what the writer did. The language
repositories' own are in their CLAUDE.md files (fsh, fml, cql, fhirpath, vcl, sql-on-fhir).
- **What was not checked is said.** A profile a resource claims in `meta.profile` that nothing in
  context defines (or whose base is not there) is a WARNING at `meta.profile[i]`
  (validate.rkt `unchecked-profile-issues`): a Patient claiming US Core, validated with the core
  package alone, was "All OK". `raco fhir-validate --package <name|file.tgz>` (repeatable) puts a
  guide and what it depends on in context, and takes the guide's FHIR version.
- **One reader of packages and their dependencies**: `fhir/package-set` (`package-file`,
  `package-set`, `package-dependencies`, `find-package`, `package-manifest`), moved from
  fhir-server's ig-plan; the validator's command line, the IG server and fsh's dependency lookup
  (fhir/ig-config) use it.
- **Required codes are checked whoever calls.** `$validate` passed the terminology service's
  typed-node closures, which answer nothing when no FHIR version is loaded: `"gender": "florp"` was
  "All OK" from a program that had not required a tower. `tx-member?` takes the resolver itself and
  asks at the JSON level. And a binding the tower has no generated expansion for (a profile's own
  value set, a guide's) is decided from the packages in context (`context-terminology`), so an FSH
  project's `* gender from BinarySex (required)` refuses `#other`. Gates unchanged: IG validation
  330 clean, validator fp 0 / recall 18, corpus 0 over-reported.
- **A required extension is enforced**: a slice of `extension` typed by one extension profile holds
  the entries with that url (`extension-slice-url`, the pin a differential never writes); any
  extension at all used to satisfy `extension contains X named x 1..1`.
- **The terminology service says "cannot say".** `rule-systems-without-content` (service.rkt): the
  code systems a value set selects from by filter or whole, whose content is not here. Such an
  expansion carries FHIR's `valueset-unclosed` extension; `$validate-code` for a code of such a
  system answers false with a message and `x-caused-by-unknown-system` (the reference server's
  parameter), which the validator reads as unknown. `raco fhir-tx` refuses a ValueSet, CodeSystem
  or ConceptMap url no package has (it printed an empty answer, exit 0) and notes an unclosed
  expansion on stderr. Suite 473/553, unchanged.
- **Two definitions, one code**: `build-app` picks an operation's definition by the entry's type
  (`od-for`), so `/ValueSet/$validate-code` is held to ValueSet's inputs (it refused `system`).
- **Servers**: a Bundle's writes are validated as single writes are (`validated-bundle`: a
  transaction with an invalid entry is refused whole, a batch answers that entry 422); a search
  parameter's expression is evaluated one `|` branch at a time (`path-values`: R6's `date` carries
  Appointment's branch unrooted, which failed on an Observation and left every date unindexed); a
  PUT that makes the resource answers 201; `/metadata` lists transaction and batch once; `raco
  fhir-server load` indexes with the core SearchParameters of `--fhir-version` (4.0.1 unless said;
  it used the engine's few built-ins, so a server over the store could not search by birthdate);
  the `serve-ig` and `fhir-tx serve` banners are flushed and name the pid; `raco fhir-lsp serve
  --help` prints usage (it started the server).
- **Form files point at their mistakes**: the generated `#lang` readers read syntax
  (`read-syntax`, codegen `reader-source`; fhir/r6 and sql-on-fhir/model regenerated), and
  `fhir-resource-form` keeps the form as read, so `patient.fhir6:3:36: Patient: "florp" is not in
  the required value set …` (it was located in fhir/kernel/kit.rkt).
- `build-tools.sh` lists what the changed commands load by name (fhir-validate: fhir/r6/types;
  fhir-server: the catalogue reader; sql-on-fhir: the towers and its operations).

## What that pass had left (2026-11-13)
The items the defect pass named as not done, each now done or decided, with a test:
- **`raco fhir-server load --validate [--package <guide>]…`** (server-cli.rkt `validate-before-load!`,
  store/load.rkt `file-resources`): every resource the load would write, a Bundle's entries each on
  their own, held to its type and claimed profiles first; problems as `file: Type/id: error: path:
  message`, warnings printed, one error = nothing loaded, exit 1 (no store is made). Without the
  flag the load checks nothing, as before. `tests/load-cli-test.rkt`.
- **The editor configurations are run in the editors** (`fhir-lsp/tests/editors-test.rkt`): the
  manual's Neovim and Emacs blocks, read out of the manual as written, given to a headless Neovim
  (0.10+) and Emacs (29+) that open the manual's `bp.fsh` — attach, the quoted message at line 5,
  hover, the fix clearing it. Skipped where an editor is not installed (`FHIR_LSP_NVIM`,
  `FHIR_LSP_EMACS` name a binary). Running them found two defects no unit test had:
  - Emacs writes a lock file `.#bp.fsh` (a link to nothing) beside a buffer as soon as it changes;
    fsh's project read it as a source and the whole project failed with "cannot open input file".
    File listings skip dot-files and dot-folders and take only what exists (fsh/project.rkt
    `source-files`, fsh/context-hint.rkt, `fhir/lang/declared` `files-beside`, `fhir/check-files`;
    `fhir/lang/workspace` already did).
  - A mapping-language file had no type findings in an editor (`tgt.gendr` unflagged; `raco fml
    check` flagged it): the server's process has no FHIR version loaded, so every type was unknown.
    fml/support.rkt loads R5 when none is registered, as the `#lang fml` reader does.
  VS Code is not tested: there is no extension of ours to run.
- **sql-on-fhir says what it left silent** (its CLAUDE.md): a JSON view with no `status` runs with
  a warning; a value the lenient read dropped ON A PATH THE VIEW READS is a warning counted over the
  resources (an element the version read lacks, with the `--fhir-version` that reads it; a value that
  is not valid FHIR, with why).
- **vcl**: a workspace problem in a file with a `#lang vcl` line is at its own line (it was one
  early). **fsh**: an instance of a logical model is written to a file named after the Instance, in
  the output folder and in the package (`--pack` wrote every id-less resource to one file).
- **The standalone tools were built and run** (`build-tools.sh`; `tools-smoke-test.sh [dist]` asks
  each of the twelve executables for one real piece of work — 22 checks — with a PATH that holds
  only `dist/bin`, from a scratch folder). The first run passed 19 of 21 and found: the standalone
  `fhir guide` could not load the guides (`fhir/mcp/resources` and the languages' workspace modules
  were not in its `++lib` list), and `serve-ig <ig> --gaps` printed nothing at all for a guide with
  no gap — now `hl7.fhir.us.core: no unmet requirement (…)` on stderr, the rows on stdout unchanged
  (`tests/gaps-cli-test.rkt`). Not in a standalone build, by nature: the capability language's
  guide and apps (they are Racket modules).
- Decided, not changed: a FHIRPath head of another resource type outside a union is an error (HL7's
  suite requires it); the 26 R5 (1 R4) core SearchParameter pairs the static check still refuses are
  the package's own (`date` writes Appointment's branch unrooted) and the store indexes them one
  branch at a time; quantity search does not convert units and string search covers names and
  addresses (read from store/search-index.rkt: the manual's Limits say what the code does).

## Quality, performance and specification pass (2026-11-13)
The pass was run per repository under one brief (baseline and behaviour dump first; HtDP and
Beautiful Racket for the code; a profile before any change for speed; every departure from the
specification fixed, decided against with a reason, or named with what it would take). Each
language repository's CLAUDE.md has its own section; this one is the fhir repository's.

**fhir-server, aligned with FHIR's RESTful API** (https://hl7.org/fhir/http.html; each was a named
Limit of the manual, each has a test doing it):
- **A searchset that is a page says so.** `Bundle.total` is every match, not the page's length
  (`fhir-search/page`: the page and a `COUNT(*)` over the same WHERE, asked only when `_count` or
  `_offset` made the answer a part); `next`/`previous` links are the search with `_offset` moved by
  `_count` (`paging-links`, relative to the base; http/server makes them absolute and puts `self`
  first); `_summary=count` and `_count=0` answer the total alone; `link` and `entry` are left out
  when empty (a search matching nothing answered `"entry":[]`, which is not FHIR JSON).
  `tests/search-paging-test.rkt`.
- **A SearchResult has one reading.** What a repository's search answers was three shapes taken
  apart in three places; it is a stated data definition (a list | `search-result` |
  `search-result/ignored` | `search-page`, the new variant carrying the total) read only by
  `search-facts`, with `with-ignored` for the one transformation (capability/runtime.rkt).
- **Versions on the wire** (`http/conditional.rkt`, pure over headers and the resource's JSON): an
  answer that is one resource carries `ETag: W/"<versionId>"` and `Last-Modified`; a read with
  `If-None-Match`/`If-Modified-Since` the current version satisfies is 304; a PUT, PATCH or DELETE
  with `If-Match` naming another version is 412 and writes nothing. `http/server.rkt`'s `answer`
  is one request answered as a value (a `response`), with no port: `serve-conn` reads, calls it,
  writes — and the tests call it directly. `tests/conditional-http-test.rkt`.
- **410 Gone** for a resource that was deleted (`deleted?`: no current resource, versions kept; a
  repository serving no history cannot say and answers 404); **`POST /{Type}/_search`** with the
  parameters as a form.
- server-cli.rkt's `validate-before-load!` is three functions and a `Finding` (context, one
  resource's finding, the report).
**fhir-mcp, what an agent pays and what a client may run unasked** (the start of "a FHIR
implementation designed to be used by agents" as something measured):
- **Tool annotations** (`mcp/verbs.rkt` `verb-behaviour`, a table; `mcp/tools.rkt` `hinted`,
  `with-hints`): each verb says, in MCP's own terms, whether it only reads (`check`, `explain`,
  `describe`), can replace something (`write`, `apply`, `commit`), is idempotent, and reaches
  beyond the workspace (`apply` always; the others only when the data is a FHIR server —
  `data-remote?`). A client can run the reading verbs without asking its user.
- **Protocol negotiation** (`mcp/server.rkt` `negotiated-version`): 2025-06-18, 2025-03-26 and
  2024-11-05; the server answered 2024-11-05 whatever it was asked.
- **A token budget, ratcheted** (`tests/tool-budget-test.rkt`): the nine tools' definitions are a
  ceiling that only comes down (12,300 bytes; they were 14,041 — and 6 KB thirty rounds earlier,
  which is what this file still claimed). Two repetitions went: the `manifest` property's sentence
  on seven tools, and `run`'s property descriptions repeated on `query` ("as for run").

Left, named: a delete is not a history entry (it needs a tombstone row in `fhir_history`, vread of
it answering 410, and fhir-mcp's `history`/`trail` views taught to show or skip it); conditional
create/update/delete by search; `If-Match` is checked just before the write, not atomically with
it; `first`/`last` paging links; `_summary` other than `count`, `_elements`.

## Known deferrals
- Full IG *package* generation (an IG as a `gen-target` with `delegate-base`) — the `#:delegate` seam
  and the sd profiling lang exercise delegation; whole-package IG codegen is not wired yet.
- FML: `dateOp` (the specification leaves its parameters "to be documented"); a map pinned to R4
  (`uses …|4.0.1`) still runs on the R5 tower (one tower per process; the check warns).
