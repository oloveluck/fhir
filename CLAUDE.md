# CLAUDE.md — working notes for this repo

FHIR as a family of Racket `#lang`s (language-oriented programming). This is the **foundation
vertical slice**; the grand vision is FHIR's type system as a collection of languages (foundation
types, a StructureDefinition lang, per-IG generated langs, capability/operation langs, and separate
FHIRPath/CQL/FML/FSH langs). JSON only, no XML.

## Package map (the family)
Eight Racket packages in six git repos. The foundation keeps the `fhir` collection; each language is its
own collection (`#lang cql`, `(require cql/compile)`), so a user who installs `cql` gets exactly CQL.
Rule that makes directories movable: **cross-directory imports use collection paths** (`fhir/model/node`),
never `../model/node.rkt`. Dependency order (base first):

| package | repo / dir | contents | depends on |
|---|---|---|---|
| `fhir` | `oloveluck/fhir` → `fhir/` | foundation: `result/ contracts.rkt model/ primitives/ kernel/ lang-gen/ serialize/ foundation/ codegen/ sd/ r4/ r5/ r6/ spec-package.rkt` | base |
| `fhir-spec` | `oloveluck/fhir` → `fhir-spec/` | the vendored HL7 NPM packages (`*.tgz`, 50 MB) — data only, located via `fhir/spec-package` | base |
| `fhirpath` | `oloveluck/fhirpath` | the FHIRPath engine (with UCUM, `print.rkt`), `raco fhirpath` | fhir |
| `vcl` | `oloveluck/vcl` | `#lang vcl`, `raco vcl` | fhir |
| `cql` | `oloveluck/cql` | `#lang cql` (CQL → ELM + interpreter), `raco cql` | fhir, fhirpath |
| `fml` | `oloveluck/fml` | `#lang fml` (FHIR Mapping Language), `raco fml` | fhir, fhirpath, cql (only `cql/error.rkt`, to be removed) |
| `fsh` | `oloveluck/fsh` | `#lang fsh` (FHIR Shorthand, bidirectional), `raco fsh` | fhir, fhirpath (snapshots via `fhir/sd/snapshot`) |
| `fhir-tools` | `oloveluck/fhir` → `fhir-tools/` | application layer: `capability/ http/ terminology/ conformance/ viewdef/ store/ omop/`, the `raco fhir` CLI, integration `tests/`, `examples/` | fhir, fhir-spec, fhirpath, vcl, db-lib (+ libduckdb at run time) |

`fhir` and `fhir-tools` both contribute to the `fhir` collection and must stay module-disjoint. `fhir`
does NOT depend on `fhir-spec`: `fhir/spec-package.rkt` locates the tarballs through the collection
search path (`spec-package-path`, `#:optional? #t` for callers that can degrade), so codegen and full
snapshot generation need `fhir-spec` while a `#lang cql` user never downloads it.

Seams introduced by the split (each a one-module move, no behaviour change):
- `kernel/operation-entry.rkt` (fhir) holds the struct generated `operations.rkt` files need, so the
  towers don't depend on `capability/`; `capability/runtime` re-exports it.
- `fhirpath/print.rkt` (was `fml/fhirpath-print.rkt`) — the store narrows search-param expressions
  with it; FML only consumed it.
- `store/materialize.rkt` (was `viewdef/materialize.rkt`) — the DuckDB bottom half depends on
  `store/fhir-analytics`, so it lives with the store; `viewdef/` stays a pure lang + evaluator.
- `sd/{sd-index,snapshot,element-index}.rkt` (were `conformance/`) — pure SD machinery, in the
  foundation so `fsh` doesn't depend on the validator. `sd-index` reads fhir-spec's R5 core package
  when present (`current-sd-package` overrides; `sd-index-available?` tells).
- `fhirpath/tests/run-r5.rkt` `dynamic-require`s `fhir/terminology/service` (the %terminologies
  backend, in fhir-tools) and lowers its floor to 1041 when fhir-tools is absent — terminology depends
  on fhirpath, so the TCK runner injects it at run time.
- codegen writes towers to `(collection-path "fhir" "<tower>")`, so `raco fhir regen` lands in whichever
  package owns the tower (`fhir` for r4/r5/r6, `fhir-tools` for viewdef/omop).
- `store/fhir-analytics.rkt` loads libduckdb lazily (`DUCKDB_LIB` overrides the search path); requiring
  it without DuckDB works, opening analytics does not.

Each language repo carries its own `CLAUDE.md` with the architecture notes for that language.

## Package setup
From `~/Projects` with the six repos side by side (dependency order):
```sh
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl cql fml fsh fhir/fhir-tools
raco setup --check-pkg-deps --pkgs fhir fhir-spec fhirpath vcl cql fml fsh fhir-tools
```
This repo's root holds the family README/LICENSE and these notes; `fhir/`, `fhir-spec/` and `fhir-tools/`
are the three packages. `fhir-tools/` owns the `raco fhir` CLI; the languages own `raco fhirpath`,
`raco cql`, `raco fsh`, `raco vcl`, `raco fml`.

## How-to-use docs
User-facing usage/how-to lives in `.claude/skills/` — `fhir-authoring` (write/run the langs),
`fhir-cli` (`raco fhir` reference), `fhir-serving` (store + HTTP), `fhir-analytics` (OMOP/DuckDB).
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
raco test -p fhir fhir-spec fhirpath vcl cql fml fsh      # the foundation + the languages
(cd fhir-tools && raco test terminology/ capability/ http/ conformance/ viewdef/ tests/)  # store/ omop/ need libduckdb
racket fhir-tools/examples/patient.fhir6 # prints FHIR JSON
racket fhir-tools/examples/demo.cql      # #lang cql — prints ELM JSON
raco fhir check all                      # determinism guard
raco fhirpath --tck r5                   # FHIRPath conformance (or r4); raco fhirpath --ucum-tck
raco cql --tck                           # CQL expression conformance (compile→run ELM→compare); raco fml --tck
raco fhir roundtrip-tck r5               # parse+serialize round-trip the whole R5 corpus (or r4)
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

## Capability / operation lang (`#lang fhir/capability`, `capability/`)
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

## HTTP layer (`http/`, `raco fhir serve`)
A small from-scratch HTTP/1.1 server over `racket/tcp` (web-server-lib isn't in this minimal Racket) that
serves a capability `app`. `http/router.rkt` is a **pure** function `handle : app method path query body →
(values status jsexpr)` mapping the FHIR REST grammar onto `capability/runtime`'s `dispatch`:
`GET /metadata`→CapabilityStatement; `GET/POST /{Type}` → search/create; `GET/PUT/DELETE /{Type}/{id}`;
`GET /{Type}/{id}/_history/{vid}`→vread; `GET|POST /${op}`, `/{Type}/${op}`, `/{Type}/{id}/${op}`→invoke
(GET query → a Parameters input, POST → the body). It maps the returned node to a status (OperationOutcome
`issue.code`→404/400/500, create→201). `http/server.rkt` `serve-app : app #:port → shutdown-thunk` parses
request line + headers + Content-Length body, one request per connection (Connection: close), each on its
own thread. `raco fhir serve <app.rkt> [port]` dynamic-requires the module's `app` and serves it.
`tests/http-test.rkt` starts the example server and drives it over a real socket. Because the capability
lang is R6, served resources/search evaluate against the R6 tower.

## Snapshot generation + validation (`conformance/`)
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
even when on. Result is an `OperationOutcome` (via `from-json`). CLI: `raco fhir validate
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

## SQL-on-FHIR lang (`#lang fhir/viewdef`, `viewdef/`)
The first **IG-as-gen-target** (see the Codegen recipe above): `raco fhir regen sof` generates the
ViewDefinition tower from `spec/hl7.fhir.uv.sql-on-fhir.tgz` (3.0.0-ballot, FHIR R6) with
`delegate-base` R6 — `#lang fhir/viewdef` authors compile-time-validated ViewDefinitions, and strict
`from-json` doubles as the view validator. The hand-written `viewdef/eval.rkt` (contracts, HTDP
structural recursion over the generated schema's nodes) evaluates a view over typed resources with
the FHIRPath engine: rows are the cartesian product of top-level select items; `forEach` maps
(empty → no rows), `forEachOrNull`'s empty case evaluates columns over the EMPTY collection (so
`%rowIndex` still yields 0 while element paths go null); `repeat` is the DEPTH-FIRST-preorder
transitive closure; `unionAll` concatenates after checking branch column congruence; `where` must
resolve to a boolean (else a view error); `constant` value[x]s become `%name` externals;
`getResourceKey()`/`getReferenceKey(Type?)` are a pure AST rewrite over the FHIRPath prefab nodes
(key = the reference's id part) — the engine itself is untouched. forEach/repeat swallow ONLY
unknown-element navigation (heterogeneous foci); syntax/constant errors surface. Conformance:
`raco fhir sof-tck` (→ `viewdef/tests/run.rkt`, floor 133) runs the vendored official shared suite
(`viewdef/tests/vendor/sof-tests/`, from FHIR/sql-on-fhir.js — see SOURCE.txt): **133/133**. One
engine fix rode along: FHIRPath `join` on empty input now returns empty (spec-correct; TCK has no
empty-join test, re-verified 1044/1044).

**The IG's operations are served** (`viewdef/run.rkt` + the generated `viewdef/operations.rkt`):
`$sql-run` executes a ViewDefinition supplied as exactly one of subjectCanonical (url[|version] of a
STORED view), subjectReference, or inline subjectResource — data = inline `resource` params
(Bundles unwrapped) else server data of view.resource's type, filtered by `patient` (subject
reference match / Patient id) and `_since`; `_limit` caps rows; `_format` = **ndjson (default)** |
json | csv (`header` param; false arrives as #f via POST, "false" via GET) | fhir (a Parameters
resource) — parquet is not-supported. Results return as a `Binary` node that `http/router.rkt`'s
`handle/raw` (used by the server) streams RAW with the Binary's own contentType — the spec's "raw
binary stream", not an envelope. `$sql-export` is the synchronous-completion profile: subjects run
immediately, the manifest returns completed with an inline-Binary output part per subject (no job
store/cancel — documented). Wiring: `make-store-app #:package (list r5 sof) #:types (… ViewDefinition)
#:sof? #t` — ViewDefinition becomes a stored/searchable type (the IG's own SearchParameters; the
engine indexes `uri` params as system-less tokens so `url=` search works), and /metadata advertises
the ops by their REAL canonicals (`rc-operation` grew a `canonical` field; `build-app` joins entry→OD
by the derived urn OR the OD's `code`). `tests/sof-op-test.rkt` drives it over a socket.

## Persistence engine (`store/`, tests/fhir-store-test.rkt)
An embedded, in-process FHIR store combining **SQLite** (transactional CRUD/versioning/search) and
**DuckDB via FFI** (analytics) over the SAME database file:
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
- `store/fhir-analytics.rkt` — minimal `ffi/unsafe` bindings to `libduckdb` (open/connect/query/
  destroy_result + column/value accessors; `ffi/unsafe`'s `->` renamed `~>` to coexist with
  contracts). A `duckdb_result` is caller-allocated (64-byte raw block, always destroy+free in
  dynamic-wind); handles carry finalizers plus explicit `close-analytics`/`call-with-analytics`.
  `open-analytics` checkpoints the WAL, then `INSTALL sqlite; LOAD sqlite; ATTACH … (TYPE SQLITE,
  READ_ONLY)` — DuckDB's sqlite_scanner reads the live store file; `fhir-analytics-query` returns
  rows as hasheqs (NULL→'null, booleans, numerics via column-type); `fhir-flatten-observations` is
  the SQL-on-FHIR-style JSON flattening example (DuckDB `json_extract` over `raw_resource`).
- `tests/fhir-store-test.rkt` — end-to-end: batch insert, indexed search, cross-engine analytics
  (AVG per patient computed by DuckDB over the SQLite file), WAL snapshot isolation + parallel
  writers. Deps: `db-lib` (info.rkt) + system `libduckdb` (brew).

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
`raco fhir load <store.db> <bundle.json|dir>` prepopulates a store from files. The version chain is
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
`raco fhir serve examples/store-app.rkt` exposes CRUD + vread + IG-param search over SQLite.
`tests/store-http-test.rkt` drives it over a real socket (advertised params from the package;
token/reference searches hit the indexes; delete → 404 while history remains).

## OMOP lang + FHIR→OMOP ETL (`#lang fhir/omop`, `omop/`, `raco fhir omop`)
The FHIR-to-OMOP IG (`spec/hl7.fhir.uv.omop.tgz`, 2.0.0-ballot, R5) as the second IG-as-gen-target,
with two codegen seams added for it: `keep?` accepts **kind=logical** (only when a whitelist names
the type explicitly — the core packages' pattern logicals FiveWs/Event/… must not be swept), and
`gen-target` gained a **`rename`** field (a name transform applied to the SD name + the root segment
of every element path right after load; whitelists match post-rename). `target-omop` renames
CamelCase→**snake_case** (`camel->snake`, acronym-aware: NoteNLP→note_nlp) — that IS the OMOP CDM
naming, the generated forms read like OMOP DDL (`(person (person_id 1) …)`), and lowercase names
can't collide with the R5 core resources (OMOP's Person/Observation/Location/Specimen/Episode) in
the shared registry, so **both towers coexist in one process**. 25 tables generated (RecordSet, the
IG's FHIR-side bundling construct, deliberately excluded); `raco fhir regen omop`, checked by
`check all`.

The ETL (the SQL-on-FHIR route the IG's StructureMaps describe):
- `omop/views.rkt` — one **ViewDefinition per OMOP table** (jsexpr data, strictly validated against
  the generated SOF schema — which resolves fine over the R5 registry since types bind by symbol at
  runtime), each MIRRORING the IG's StructureMap (PersonMap, ConditionMap, MeasurementMap[laboratory
  gate as `where`], EncounterVisitMap, MedicationMap, ProcedureMap). Where a map calls
  `translate(ConceptMap,…)` the view emits the SOURCE code and carries a `(column . conceptmap-url)`
  translation spec. `module+ test` proves **congruence**: every view column ∈ the generated OMOP
  logical model's fields.
- `omop/etl.rkt` — pure row pipeline: eval-view → **translate** (terminology/service over the OMOP
  tgz itself — the IG's own ConceptMaps; unmapped/absent → `"0"`, OMOP's no-matching-concept) →
  **mint** (integer-typed columns: numeric FHIR ids pass through, non-numeric get a stable per-run
  integer ≥1000000; ONE minter across tables so person_id keys agree) → **load-omop!** (DuckDB
  `CREATE SCHEMA omop` + DDL **derived from the generated logical models**: integer→BIGINT,
  code/string→VARCHAR, date→DATE, dateTime→TIMESTAMP, decimal→DOUBLE; typing follows the IG, not
  OHDSI DDL — concept ids are `code`→VARCHAR). `store->omop!` runs the whole chain from a
  `fhir-store`; OMOP tables land IN the analytics session's memory catalog next to the ATTACHed
  SQLite, so one DuckDB session queries `omop.person` joins AND `fhir.fhir_resources` raw JSON.
- One viewdef/eval fix rode along: `item->jsexpr` renders FHIR primitives via `primitive->jsexpr`
  (raw date/dateTime field values were leaking as `t-*` structs into row cells; SOF TCK re-verified
  133/133).
- `raco fhir omop <store.db> [SQL] [<out.duckdb>]` — ETL then query (JSON row per line) or print
  table counts; the third arg persists the omop schema to a .duckdb FILE the standalone `duckdb`
  CLI opens directly (verified). `examples/omop-demo.rkt` is the end-to-end demo;
  `omop/tests/omop-test.rkt` the integration test (GenderClass 8507/8532 translation, unmapped→0,
  joins, AVG, datediff over real DATE columns, minted vs passthrough ids, cross-engine FHIR+OMOP,
  persistence round-trip + idempotent re-ETL).

Generic SOF↔OMOP layering (`viewdef/materialize.rkt`, `omop/session.rkt`):
- `viewdef/materialize.rkt` — ANY SQL-on-FHIR ViewDefinition materializes as a DuckDB table:
  `materialize-view!` (eval-view → optional `#:transform` row post-pass → `replace-table!`), DDL
  from `#:columns` override / the view's SOF column `type` hints / value inference. `replace-table!`
  (CREATE OR REPLACE + batched INSERT, idempotent) and `duck-type`/`sql-literal` are the shared
  bottom half — `omop/etl.rkt`'s `load-omop!` is now a thin loop over `replace-table!` with
  logical-model-derived `omop-columns`.
- `store/fhir-analytics.rkt` — `open-analytics` takes `#:duckdb path` (persistent DuckDB file
  instead of :memory:) and `store` may be `#f` (reopen a .duckdb alone, no ATTACH).
- `omop/session.rkt` — the front door: `open-omop`/`with-omop` (analytics + full ETL; `#:duckdb`
  for persistence), `omop-query` (plain SQL; `omop.*` + `fhir.*` both in scope), `omop-counts`,
  `omop-materialize!` (a CUSTOM view into the same session, resources pulled from the store by the
  view's `resource` type — user flattenings alongside the CDM).

## Vendored conformance corpora (the ratchet table)
Every suite is vendored VERBATIM with a SOURCE.txt (url + retrieval date + what is skipped and
why), driven by an execution harness, and gated by a floor that only rises:

| suite | source | harness | current |
|---|---|---|---|
| FHIRPath | HL7 R4/R5 XML suites | `raco fhir fhirpath-tck r5\|r4` | 1044/1044, 932/934 |
| CQL | cqframework/cql-tests | `raco fhir cql-tck` | 1819/1823 |
| SQL-on-FHIR | FHIR/sql-on-fhir.js shared suite | `raco fhir sof-tck` | 133/133 |
| FML | fhir-test-cases r5/structure-mapping | `raco fhir fml-tck` | 6/6 exec, 15/15 parse |
| **UCUM** | **FHIR/Ucum-java UcumFunctionalTests.xml** | **`raco fhir ucum-tck`** | **573/573** (all sections) |
| VCL | the spec page's 60 examples | `raco test vcl/` | 60/60 parse + fixpoint |
| round-trip | HL7 examples + R4/R5 core packages | `raco fhir roundtrip-tck r5\|r4` | 2968+77, 4581+72 |
| **IG examples** | **US Core 9.0.0, IPS 2.0.1 packages** | `tests/ig-examples-r4-test.rkt` | **274/274 parse+round-trip** |
| **IG validation** | **US Core 9.0.0, IPS 2.0.1: every example vs the IG profiles it claims** | `tests/ig-validation-r4-test.rkt` | **260/260 clean** (0 false positives) |
| **IG search** | **US Core 9.0.0 examples, R4 core + US Core SearchParameters: each example found by its own values** | `tests/ig-search-r4-test.rkt` | **2368/2368 probes** |
| **IG server** | **a server generated from US Core 9.0.0: 0 unmet SHALL, all 230 examples load through validation** | `tests/ig-server-r4-test.rkt` | **0 SHALL gaps** (91 MAY/SHOULD) |
| **IG FHIRPath** | **the same IGs: profile invariants on their examples + SearchParameter expressions** | `tests/ig-fhirpath-r4-test.rkt` | **6082 invariant checks, 0 fail** (2 dom-3 spec-conflict errors); **1330/1330 search** |
| SOF examples | the SOF IG's own package | `tests/ig-examples-sof-test.rkt` | 17/17 (1 documented IG defect) |
| **snapshot** | **fhir-test-cases rX/snapshot-generation** | `conformance/tests/snapshot-conformance-test.rkt` | **paths 80/80, card 143/148, types 70/71** (id-matched) |
| validator | fhir-test-cases validator + java outcomes | `tests/validate-diff-test.rkt` | **fp=0**, recall 17/26 (67 cases) |
| FSH | SUSHI golden corpus | `fsh/tests/golden-test.rkt` | 22/22 fwd + round-trip |
| **terminology** | **hl7.fhir.uv.tx-ecosystem 1.9.3** | **`raco fhir tx-tck`** | **463/553** |

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
its profiles' invariants hold on them. `fhir-tools/tests/ig-*-harness.rkt` read any IG package and
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

## Servers generated from an IG (`store/ig-server.rkt`, `raco fhir serve-ig`)
`make-ig-server store ig.tgz` derives the whole server from the IG package: package.json
`fhirVersions` picks the tower (fhir/r4|r5|r6) and the core package; the IG's server
CapabilityStatement (rest.mode = server) gives the types, interactions, search parameters, includes,
supported profiles and operations; the search catalog is the core SearchParameters overlaid by the
IG's; every create/update (API and example loader alike) is validated against its base type and
claimed profiles over `(current-sd-packages (list ig core))` — errors -> 422. `/metadata` is the IG's
OWN CapabilityStatement as `kind: instance`, trimmed to what this server executes; everything
trimmed is a `gap` (type, what, name, SHALL/SHOULD/MAY, reason). IG operations are a table keyed by
OperationDefinition canonical (`operation-impls`; US Core `$docref` so far) — the OD itself comes
from the package and drives input validation. `raco fhir serve-ig hl7.fhir.us.core [--db f] [--port n]`
loads the IG's examples and serves; `--gaps` prints the unmet requirements.
US Core status: every SHALL met except authorization (SMART is not modelled in the CapabilityStatement's
resources and is out of scope); 91 MAY/SHOULD gaps are history, patch and `$expand`.

## Known deferrals
- Full IG *package* generation (an IG as a `gen-target` with `delegate-base`) — the `#:delegate` seam
  and the sd profiling lang exercise delegation; whole-package IG codegen is not wired yet.
- FML / query-and-retrieve CQL — future work over `model/node` + `model/registry` + `fhirpath`.
