# CLAUDE.md — working notes for this repo

FHIR as a framework for spec-driven development: FHIR's specs (profiles, value sets, invariants,
measures, maps) as Racket `#lang`s and the tools that check them, so a person or an LLM goes from a
requirement to a validated FHIR artifact with positioned feedback (language-oriented programming;
JSON only, no XML). Worked examples, and the spec-driven benchmark, live in the `fhir-examples` repo.

## Package map (the family)
Eleven Racket packages in seven git repos, plus `fhir-examples` (examples and the benchmark). The foundation keeps
the `fhir` collection; each language is its own collection (`#lang cql`, `(require cql/compile)`).
Rule that makes directories movable: **cross-directory imports use collection paths** (`fhir/model/node`),
never `../model/node.rkt`. Dependency order (base first):

| package | repo / dir | contents | depends on |
|---|---|---|---|
| `fhir` | `oloveluck/fhir` → `fhir/` | foundation: `result/ contracts.rkt model/ primitives/ kernel/ lang-gen/ serialize/ foundation/ codegen/ sd/ r4/ r5/ r6/ spec-package.rkt package.rkt diagnostic.rkt subcommands.rkt cli.rkt` (`raco fhir`), foundation `tests/` and `examples/` | base |
| `fhir-spec` | `oloveluck/fhir` → `fhir-spec/` | the vendored HL7 NPM packages (`*.tgz`) — data only, located via `fhir/spec-package` | base |
| `fhirpath` | `oloveluck/fhirpath` | the FHIRPath engine (with UCUM, `print.rkt`), `raco fhirpath` | fhir |
| `vcl` | `oloveluck/vcl` | `#lang vcl`, `raco vcl` | fhir |
| `fhir-tx` | `oloveluck/fhir` → `fhir-tx/` | `terminology/service.rkt` ($expand, $validate-code, $lookup, $translate over packages or resources; the tx-service handle for %terminologies), `terminology/operations.rkt` (the same as fhir/operation values), the tx-ecosystem suite, `tx-cli.rkt` (`raco fhir-tx`) | fhir, fhir-spec, fhirpath, vcl |
| `fhir-validation` | `oloveluck/fhir` → `fhir-validation/` | `conformance/validate.rkt`, the validation corpora and tests, `validate-cli.rkt` (`raco fhir-validate`) | fhir, fhir-spec, fhirpath, fhir-tx |
| `cql` | `oloveluck/cql` | `#lang cql` (CQL → ELM + interpreter), `raco cql` | fhir, fhirpath |
| `fml` | `oloveluck/fml` | `#lang fml` (FHIR Mapping Language), `raco fml` | fhir, fhirpath, cql (only `cql/error.rkt`, to be removed) |
| `fsh` | `oloveluck/fsh` | `#lang fsh` (bidirectional), projects + packaging, `check.rkt`; `raco fsh`, `raco fsh check` | fhir, fhirpath, fhir-validation |
| `fhir-server` | `oloveluck/fhir` → `fhir-server/` | `capability/ http/ store/` (SQLite), IG-generated servers, `$evaluate-measure`, `server-cli.rkt` (`raco fhir-server`), server tests | fhir, fhir-spec, fhirpath, fhir-tx, fhir-validation, cql, db-lib |
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

Each language repo carries its own `CLAUDE.md` with the architecture notes for that language.

## Package setup
From `~/Projects` with the repos side by side (dependency order):
```sh
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx fhir/fhir-validation cql fml fsh fhir/fhir-server fhir-examples
raco setup --check-pkg-deps --pkgs fhir fhir-spec fhirpath vcl fhir-tx fhir-validation cql fml fsh fhir-server fhir-examples
```
This repo's root holds the family README/LICENSE and these notes; `fhir/`, `fhir-spec/`, `fhir-tx/`,
`fhir-validation/` and `fhir-server/` are its five packages. Commands: `raco fhir` (foundation),
`raco fhir-tx`, `raco fhir-validate`, `raco fhir-server`, and per language `raco fhirpath|cql|fsh|vcl|fml`.

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
  `prop:exn:srclocs`); CQL and FML put it in `cql-error-diagnostic`; VCL attaches it to its
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
It exposed a validator recall gap, now closed: an entry matching exactly ONE slice (pins decidable)
is held to the slice's own children — cardinality, fixed/pattern, required bindings, and choice
variants the slice does not allow (`valueString` in a Quantity-only slice) — recursion stays with the
unsliced walk. Gates unchanged: fp=0, 0 over-reported, IG validation 260 clean, published mCODE 283/283.
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
parent, children, weakly cached on the resource) and an expansion cache per resolver. `$expand`
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
`raco fhir-tx tck` on every push.

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
`validate-object` recursion applying pure rules — cardinality, unknown-element (lenient on choice
variants), primitive format (reuses `primitives/` ctors), fixed[x]=/pattern[x]⊆, required binding (via a
`tx-service`; only fires when the VS demonstrably expands offline), value/pattern-discriminator
slice `min` (multi-discriminator and `$this` supported; the pinned value is fixed[x]/pattern[x] on
the slice's `<slice-id>.<disc-path>` element; any non-value/pattern discriminator or unresolvable
pin → fail-open — this was a silent stub until the quality loop made it real and test-pinned); plus
FHIRPath invariants (`#:invariants?`, **off by default**). The cardinal rule is **fail-open — never
report on anything undecidable** (unresolvable type/profile/VS, unparseable expression). Invariants are
off by default because our FHIRPath, though TCK-complete, mis-evaluates some base invariants (`ele-1`,
`sdf-8`, `csd-1`) vs the Java reference and would over-report; the universal base keys are denylisted
even when on. Result is an `OperationOutcome` (via `from-json`). CLI: `raco fhir-validate
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
request order. `load-bundle!` also accepts `collection` (a batch of creates — the Synthea shape);
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
| **UCUM** | **FHIR/Ucum-java UcumFunctionalTests.xml** | **`raco fhirpath --ucum-tck`** | **573/573** (all sections) |
| VCL | the spec page's 60 examples | `raco test vcl/` | 60/60 parse + fixpoint |
| round-trip | HL7 examples + R4/R5 core packages | `raco fhir roundtrip-tck r5\|r4` | 2968+77, 4581+72 |
| **IG examples** | **US Core 9.0.0, IPS 2.0.1 packages** | `tests/ig-examples-r4-test.rkt` | **274/274 parse+round-trip** |
| **IG validation** | **US Core 9.0.0, IPS 2.0.1: every example vs the IG profiles it claims** | `tests/ig-validation-r4-test.rkt` | **260/260 clean** (0 false positives) |
| **IG search** | **US Core 9.0.0 examples, R4 core + US Core SearchParameters: each example found by its own values** | `tests/ig-search-r4-test.rkt` | **2368/2368 probes** |
| **IG server** | **a server generated from US Core 9.0.0: all 255 resources load through validation** | `tests/ig-server-r4-test.rkt` | **0 unmet requirements** (SHALL/SHOULD/MAY; auth aside) |
| **IG FHIRPath** | **the same IGs: profile invariants on their examples + SearchParameter expressions** | `tests/ig-fhirpath-r4-test.rkt` | **6082 invariant checks, 0 fail** (2 dom-3 spec-conflict errors); **1330/1330 search** |
| **snapshot** | **fhir-test-cases rX/snapshot-generation** | `conformance/tests/snapshot-conformance-test.rkt` | **paths 80/80, card 476/478, types 235/236** (id-matched) |
| validator | fhir-test-cases validator + java outcomes | `tests/validate-diff-test.rkt` | **fp=0**, recall 17/26 (67 cases) |
| FSH | SUSHI golden corpus (hand-authored pairs) | `fsh/tests/golden-test.rkt` | 22/22 fwd + round-trip |
| **FSH real IG** | **IPS 2.0.1's own FSH vs its published package** | `fsh/tests/ig-ips-test.rkt` (fsh repo) | **0 compile errors; 76/114 exact, 82/114 complete; 321/440 differential elements** |
| **FSH -> package -> server** | **mCODE 4.0.0's FSH compiled and packed here, served by a generated server: its examples vs its profiles** | `tests/fsh-ig-server-r4-test.rkt` | **283/283 validate** (as the published package); 0 unmet requirements |
| **FSH real IG 2** | **mCODE 4.0.0's own FSH (dependencies US Core 6.1.0 + Genomics Reporting 2.0.0 from sushi-config.yaml) vs its published package** | `fsh/tests/ig-mcode-test.rkt` (fsh repo) | **0 compile errors; 206/349 exact, 282/349 complete; 279/501 differential elements** |
| **Measure server** | **a server generated from CQF Measures 5.0.0: $evaluate-measure over its store, 2 eCQMs, 65 test patients** | `tests/measure-server-r4-test.rkt` | **60/65 individual reports** (5 named); 0 unmet requirements |
| **CQL execution** | **4 eCQMs over 76 test patients (cqframework/ecqm-content-r4-2021): populations vs expected** | `cql/tests/measure-test.rkt` (cql repo) | **71/76** (5 named corpus disagreements) |
| **CQL real libraries** | **32 published libraries (FHIRHelpers, CQF Measures, CQL IG) vs the reference ELM** | `cql/tests/elm-corpus-test.rkt` (cql repo) | **32/32 parse + compile; 742/803 defs ELM-equal** |
| **SQL on FHIR** | **the shared suite from FHIR/sql-on-fhir.js, over the model generated from the 3.0.0-ballot package** | `raco sql-on-fhir tck` (sql-on-fhir repo) | **144/144** |
| **terminology** | **hl7.fhir.uv.tx-ecosystem 1.9.3** | **`raco fhir-tx tck`** (fhir-tx) | **463/553** |

A later pass closed every remaining gap that needs no external terminology — the corpora drove
these fixes, each one a real defect:
- **tx** (441→**463/553**, and the denominator is now honest): wildcard version pins (`1.x.x`) keep
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
Unknown parameters and unsupported modifiers are ignored (FHIR's lenient default) and reported by
`fhir-search/ignored`; the derived CapabilityStatement advertises only executable kinds (composite and
special are not). Before this, search guessed token-vs-reference from the VALUE's shape and string/
date/number/quantity parameters silently matched nothing.

## Servers generated from an IG (fhir-server's `store/ig-server.rkt`, `raco fhir-server serve-ig`)
`make-ig-server store ig.tgz` derives the whole server from the IG package: package.json
`fhirVersions` picks the tower (fhir/r4|r5|r6) and the core package; the IG's server
CapabilityStatement (rest.mode = server) gives the types, interactions, search parameters, includes,
supported profiles and operations; the search catalog is the core SearchParameters overlaid by the
IG's; every create/update (API and example loader alike) is validated against its base type and
claimed profiles over `(current-sd-packages (list ig core))` — errors -> 422. `/metadata` is the IG's
OWN CapabilityStatement as `kind: instance`, trimmed to what this server executes; everything
trimmed is a `gap` (type, what, name, SHALL/SHOULD/MAY, reason). IG operations are a table keyed by
OperationDefinition canonical (the registered operation values, see "Operations as values") — the OD itself comes
from the package and drives input validation. `raco fhir-server serve-ig hl7.fhir.us.core [--db f] [--port n]`
loads the IG's examples and serves; `--gaps` prints the unmet requirements.
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

## Known deferrals
- Full IG *package* generation (an IG as a `gen-target` with `delegate-base`) — the `#:delegate` seam
  and the sd profiling lang exercise delegation; whole-package IG codegen is not wired yet.
- FML transforms beyond the TCK — future work over `model/node` + `model/registry` + `fhirpath`.
