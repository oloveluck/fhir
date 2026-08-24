# CLAUDE.md — working notes for this repo

FHIR as a family of Racket `#lang`s (language-oriented programming). This is the **foundation
vertical slice**; the grand vision is FHIR's type system as a collection of languages (foundation
types, a StructureDefinition lang, per-IG generated langs, capability/operation langs, and separate
FHIRPath/CQL/FML/FSH langs). JSON only, no XML.

## Package setup
This directory IS the `fhir` collection (linked via `raco pkg install --link --name fhir`).

## How-to-use docs
User-facing usage/how-to lives in `.claude/skills/` — `fhir-authoring` (write/run the langs),
`fhir-cli` (`raco fhir` reference), `fhir-serving` (store + HTTP), `fhir-analytics` (OMOP/DuckDB).
This file is the architecture reference; keep the how-to in the skills.

## Architecture (bottom-up)
- **Result, not exceptions** (`result/`): validation returns `(ok v)`/`(err e)`; every error carries
  the `spec-url` it violated.
- **Canonical value is a typed node** (`model/node.rkt`): one generic `(struct fhir (type fields))`.
  Leaves are primitive newtype instances; nested values are `fhir` nodes. jsexpr is DERIVED
  (`serialize/to-json.rkt`) — do not reintroduce "jsexpr is the only value".
- **Spec-linking registry** (`model/registry.rkt`): `prop:fhir-spec` on values + type/primitive/
  element registries. `from-json`, and future langs, read this.
- **Compile-time validation** (`lang-gen/form-syntax.rkt`): `build-fhir-form` is the crown jewel —
  it runs at phase 1 in generated modules and expands to `node-build`. Keep the `#:delegate` seam
  (the profile/IG extension point) even though the slice doesn't use it.
- **One schema, two directions**: `serialize/{to,from}-json` are both driven by the registered
  `type-schema`, so they cannot drift.

## Codegen (`codegen/`)
`gen.rkt`'s `generate-tower` / `tower-files` reads a vendored `.tgz` (`load-spec`), nests + expands
the snapshot to IR (`nest`/`expand`/`ir`), and emits per type a form module (`emit-form`) + a schema
module (`emit-schema`), plus the tower index/main/reader. `target.rkt` is the R6/R4 seam (a
`gen-target` with a `whitelist` that keeps the slice small — set to `#f` for full generation).

**Generating an IG's resources as a lang (the recipe, proven by `#lang fhir/viewdef`):** an IG whose
StructureDefinitions are `kind=resource`/`derivation=specialization` with snapshots becomes a
first-class generated tower in four steps — (1) vendor the IG's NPM package under `spec/` (from
`packages2.fhir.org/packages/<id>` → the `tarball` URL); (2) add a `gen-target` in `codegen/target.rkt`
with `#:whitelist` = the IG's own types, `#:delegate-base` = the matching core tower (match
`fhirVersion`!), `#:forms?` `#t` for an authoring `#lang`; (3) add the id to `target-for` + the CLI's
`targets-of` "all" list; (4) `raco fhir regen <id>` — the emitted `types.rkt` requires the base
tower's index first, so every core datatype the IG references (Meta, Coding, …) resolves through the
shared runtime registry (types are referenced by symbol, `(vector 'type 'Coding)`, resolved at
runtime — nothing is re-emitted). `raco fhir check all` then guards the IG tower's determinism too.
Constraint-derivation profiles in the package are auto-skipped by `keep?`. Hand-written modules
(evaluators, harnesses) co-locate safely in the same directory: the check byte-diffs only the files
it generates. `target-sof` (`spec/hl7.fhir.uv.sql-on-fhir.tgz`, whitelist `ViewDefinition`, base R6)
is the exemplar: `#lang fhir/viewdef` authors compile-time-validated ViewDefinitions, and the same
schema drives `from-json`, which strictly parses 132/133 of the official suite's views — the 1
rejection being the suite's deliberately-invalid view.

**OperationDefinitions generate too**: `load-package` also collects the package's
`OperationDefinition-*.json` (sorted by (code, id)), and any package that ships them gets a generated
`<tower>/operations.rkt` — each OD verbatim as data (`<code>-definition`, embedded as canonical
sorted-key JSON for byte-determinism) plus a scaffold constructor `<code>-operation` that binds
level/code/target from the OD and takes ONLY the handler, returning `operation-entry`s for
`build-app`. Identifiers are named by code, or by id when several ODs share a code (the core
$apply pair). The core towers get the standard operations (`fhir/r5/operations`: 61); the SOF
tower gets `sql-run-operation`/`sql-export-operation`.

**Terminology generates too** — ValueSets are part of the language: `load-package` collects
ValueSet/CodeSystem (+ `package/example/*.json`, returning one `package-contents` struct), and
every REQUIRED-bound `code` element on a kept type whose ValueSet expands OFFLINE from the
package's own CodeSystems (whole-system or enumerated includes; filters/imports/excludes → not
expandable, fail open) lands in a generated `<tower>/terminology.rkt` registering codes into
`model/binding.rkt`. The tower index requires it normally AND for-syntax, the element's binding
flows into the form macro's field-spec `extra` slot (`(required vs-url)` — captured from
ElementDefinition.binding, which `element-definition` now parses), and `form-syntax`'s
`check-binding` rejects out-of-set literal codes at COMPILE time: `(Patient (gender "florp"))` is
a syntax error listing the valid codes (r6: 202 valuesets; unregistered urls fail open).
VS/CS resolution consults the DELEGATE-BASE packages up the chain, so IG towers get core-bound
expansions too (`viewdef/terminology.rkt`: `(ViewDefinition (status "florp"))` is a compile
error). At RUNTIME the same catalogue backs `conformance/validate.rkt`'s required-binding check
when no tx-service is supplied (offline expansions are exact → 'no is never a false positive). Runtime
terminology ($expand/$validate-code/$translate over ANY package tgz) remains `terminology/`.

**Examples must parse** (`tests/ig-examples-sof-test.rkt`): every `package/example/*.json` an IG
ships parses — the tower's own types STRICTLY (the schema is the validator), everything else
leniently to its declared type. Documented corpus defect: all 10 of the SOF 3.0.0-ballot's
ViewDefinition examples carry `resourceDefinition`, an element the IG's own SD does not declare —
masked with a ratchet check that fails (forcing mask removal) once the IG fixes its examples.

**Generated code is never hand-edited.** Every generated file carries a `DO NOT EDIT` banner;
`raco fhir check` (→ `codegen/check.rkt`) regenerates purely and byte-diffs vs disk. **Generated
code is held to reading standards too**: the banner stamps the TRUE provenance
(`hl7.fhir.uv.omop#2.0.0-ballot`, not a generic "core"), form macros emit one field-spec per line
(a schema table, not a 1500-char line), and operations.rkt embeds each OperationDefinition as
pretty sorted-key JSON in a multi-line string literal (readable AND byte-deterministic).
Generation must
stay deterministic: emit via `~s` on data, sort names, quote unbounded max as `'*`.

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
raco test result/ model/ primitives/ kernel/ lang-gen/ serialize/ codegen/ terminology/ capability/ http/ fsh/ cql/ tests/
racket examples/patient.fhir6            # prints FHIR JSON
racket examples/demo.cql                 # #lang fhir/cql — prints ELM JSON
raco fhir check all                      # determinism guard
raco fhir fhirpath-tck r5                # FHIRPath conformance (or r4)
raco fhir cql-tck                        # CQL expression conformance (compile→run ELM→compare)
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

## StructureDefinition / profiling lang (`#lang fhir/sd`, `sd/`)
`(profile Name #:base Base (field min max) …)` reads `Base`'s full schema at **phase 1** (via
`model/introspect.rkt`'s `full-field-specs`, which reads the runtime registry — `sd/profile.rkt`
requires `fhir/r6/types` for-syntax to populate it), validates each override as a genuine *narrowing*
(loosening is a compile error), and synthesizes a form macro that validates the constrained schema
then **delegates** to the base macro (`build-fhir-form #:delegate`). `#:base` may be a base type or an
earlier profile → multi-level delegation (a compile-time `profile-table` carries each profile's
constrained schema for profile-of-profile). The built value is the base resource; the profile adds
only compile-time conformance. Reader is plain (profiles are definitions, not resource instances).

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
`conformance/sd-index.rkt` (`resolve-sd-raw`, moved from `fsh/`) resolves base/profile SDs from the R5
core package. `conformance/snapshot.rkt` (`generate-snapshot`) is a reduced-ProfileUtilities merge:
re-root the base snapshot, element-by-path merge (diff overrides; `constraint` **accumulates**),
`ensureBase`, and named-slice re-rooting (a slice inherits the base element at its path). Deferred:
reslicing, discriminator inference, choice-`[x]` slice expansion, contentReference. `conformance/element-index.rkt`
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

## FHIR Shorthand lang (`#lang fhir/fsh`, `fsh/`)
A from-scratch FSH compiler (the SUSHI authoring DSL) built onto this repo's model. Layers: `parser/` (a `#lang brag` grammar + a stateful `br-parser-tools` lexer
that emulates FSH's ANTLR pushMode/popMode via a mode-stack box + one lexer per mode; prefab AST with
`lower-entity`; `path.rkt` sub-parses FSH paths; `parse.rkt` pre-splits a doc into entity chunks since
brag's start rule is one `entity`), `resolve.rkt` (walks an FSH path against the R5 registry via
`model/introspect` `full-field-specs` → element type code / cardinality kind — for fixed/pattern key
selection and Instance array nesting), `caret.rkt` (get/set at a caret path), `compile.rkt`
(entity AST → **FHIR jsexpr**). Targets **R5** (`fhirVersion "5.0.0"`, canonical base default
`http://example.org`). Profiles/Extensions → a StructureDefinition **differential** (type-qualified
paths, per-element `id`; **no snapshot** — deferred); `=` assigns `patternX`, `= … (exactly)` assigns
`fixedX` (both prim+complex); root `obeys` lands a constraint on the base-type element sourced to the
profile url. Instance → a plain resource (schema-driven nesting; `meta.profile` stamped when
`InstanceOf` is a local profile). ValueSet/CodeSystem → compose/concept (system pulled from `from
system` or the code token; CodeSystem gets `count`). Whole-doc compile resolves `Alias`es and expands
non-parameterized `insert RuleSet` first. `#lang fhir/fsh` (`fsh/base.rkt` custom `#%module-begin` +
`fsh/lang/reader.rkt`'s `#:read-syntax` running `parse-fsh-doc`, emitting `(fsh-entity <ast>)` forms)
makes a `.fsh` file a module providing `document`/`compiled`(jsexpr)/`resources`(typed nodes via
`from-json`), printing JSON in `main`. `raco fhir fsh <dir>` batch-compiles a folder SUSHI-style.
**Bidirectional**: the reverse direction (FHIR → FSH, "GoFSH") is `fsh/decompile.rkt` +
`fsh/print.rkt` (FSH AST → text). `fhir->fsh` (jsexpr) / `node->fsh` (typed node) emit idiomatic rules
where recognised (card/flag/binding/only-with-targetProfile/obeys/concept/include-exclude) and a
lossless `^caret` catch-all for everything else; Invariants are **not** emitted standalone (SUSHI-style)
but re-synthesised from SD constraints so a recompile refills severity/human/expression. `raco fhir
gofsh <file.json>` is the CLI. Invariants are consumed only as SD constraint sources — `compile-doc`
skips standalone `fsh-invariant` output.

Conformance: `fsh/tests/golden-test.rkt` runs the vendored SUSHI **golden corpus** (`.fsh`+`.json`
pairs) through a tolerant deep-subset comparator (expected ⊆ actual; list items matched
content-independently so differential `element` arrays line up by path) — forward **22/22**;
`fsh/tests/roundtrip-test.rkt` checks a **FSH→FHIR→FSH→FHIR fixpoint** (deep-equal, **22/22** — all
pairs) and a parse∘print∘parse AST fixpoint.

The initially-deferred features are all implemented: **CodeSystem concept hierarchy** (`* #a #b` nests,
`count` totals the tree); **Extension auto-scaffolding** (`add-extension-scaffold`/`add-extension-header`
— root short/definition, `extension` 0..0 / min + per-slice `.extension` 0..0 + `.url` fixedUri, `url`
fixedUri, `context` + type-characteristics); **discriminator slicing** (`contains` sets base `min` =
Σ slice mins, slice ids `path:slice`, slicing authored via `^slicing…` carets; `element-loc` maps FSH
paths → ElementDefinition id/path, `[x]`→`[x]`, `[slice]`→`:slice`); **Logical models & custom
Resources** (`compile-logical-resource` — root element at the entity id, `addElement`/kind/derivation=
specialization); **parameterized RuleSets** (`instantiate-ruleset` substitutes `{param}` in the raw
body tokens and re-parses); **snapshot generation** (opt-in `emit-snapshot?` → `conformance/snapshot.rkt`, a
ProfileUtilities-style merge of the differential onto the base's snapshot from the R5 core package via
`conformance/sd-index.rkt`); and **Mapping** (`apply-mapping` — a post-pass injecting `StructureDefinition.mapping`
+ `ElementDefinition.mapping` into the named Source SD). `fsh/tests/features-test.rkt` covers the
golden-less features (param RuleSets, snapshot, Mapping). The reverse direction is complete too:
`decompile-extension` emits minimal FSH and lets the forward compiler regenerate the scaffold, and the
profile decompiler is slice-aware (`id->fsh-rel` inverts id↔path, reconstructs `contains` + `^slicing`
carets) — so all 22 pairs round-trip. **Reslicing** (a slice of a slice — ids join with `/`, e.g.
`component:Lab/Chem`; `element-loc`'s `id-seg` and the `contains` handler are reslice-aware, as is the
decompiler's `base-id-of`) and **multi-discriminator** slicing both compile and round-trip
(`fsh/tests/features-test.rkt`). The FSH lang is now feature-complete for this slice — nothing is
deferred.

## Serialization details now handled (`serialize/`)
- **Primitive `_field` sibling**: id/extension serialize to a parallel `_field` object (list →
  `_field` array with `null` placeholders) and merge back on parse.
- **Precision-preserving decimal**: `decimal` is string-backed; `node->json-string` emits it as a raw
  number token via an internal extended-jsexpr (`raw-num`). `node->jsexpr` is the lossy structured
  view. Read via racket/json is number→string (value-kept; trailing zeros limited by racket/json —
  a decimal supplied as a JSON *string* is preserved exactly).
- **`lit` macro** (`primitives/literals.rkt`): standalone compile-time-checked literals, e.g.
  `(lit date "1974-12-25")`.

## FHIRPath (`fhirpath/`)
A from-scratch engine in `fhir/fhirpath/`, evaluating over the typed `fhir` node model. Layers:
`parser/` (brag precedence-cascade grammar + br-parser-tools lexer + prefab AST), `value.rkt`
(item/collection model + System types + `item->system`), `decimal.rkt` (exact + scale),
`temporal-ops.rkt` (partial Date/Time/DateTime: compare/equal/arith/boundary), `quantity.rkt` +
`ucum.rkt` (a compact UCUM engine ported from `ucum-essence.xml` — exact canonicalization/
conversion), `types.rkt` (FHIR ancestry from the registry + System lattice + is/as/ofType),
`navigate.rkt` (schema-driven, value[x] choice, resource-root, `_field` extensions), `equality.rkt`
(= ~ 3-valued + set ops), `operators.rkt`, `functions.rkt` (the full library), `environment.rkt`
(`$this/$index/$total`, `%` externals, defineVariable via a shared mutable scope), `eval.rkt`.

Data-driven conformance harness in `fhirpath/tests/` runs the official HL7 suites:
`raco fhir fhirpath-tck r5` (1044) / `... r4` (934). Current: **R5 1044/1044, R4 932/934** — 100% of
in-scope tests. Each run requires the matching full tower (`run-r5` requires `fhir/r5/schemas`);
`tests/vendor/` has the suite XML + `.g4`, `tests/inputs*/` the JSON resources.
`tests/fhirpath-test.rkt` is a fast in-tree smoke. Input loading is **lenient** (`from-json
#:lenient? #t` — unknown/mismatched fields are skipped) so examples from a newer FHIR version than
the tower still load.

Strict-mode semantics: `fhirpath/analyze.rkt` is a conservative static pass (seeded from the input
resource type via `eval-fhirpath #:strict?`) that raises `'semantic` for unknown elements, direct
expanded-choice access (`Observation.valueQuantity` — allowed only under `mode="lenient"`), string
functions on complex types, and order-dependent functions on unordered sources. It only raises when
confident (unknown type ⇒ stop), so it never flags a valid expression it can't fully type. UCUM
product/quotient units, quantity `~` least-precision, defineVariable scope (via `env-clone-vars` at
`|`/projection boundaries), and `resolve()` over `contained` are all implemented.

`%terminologies` is a terminology-service handle: the `terminology/` package is version-neutral
(`make-terminology <core.tgz>`, with `make-r5-terminology` / `make-r4-terminology` conveniences) —
it lazily loads a core package, indexes every CodeSystem/ValueSet/ConceptMap by canonical URL, and
implements `$expand` / `$validate-code` (vs a ValueSet) / `$translate` (ported clean-room from
fhir4s's `TerminologyOps`). Algorithms run on raw jsexpr; only the result nodes go through `from-json`,
so they build against whichever tower the caller registered (R5 core is what the TCK exercises; R4
works identically — the R4 suite just has no `%terminologies` tests, so `run-r4` doesn't wire it). The engine side is a version-neutral `tx-service` struct
(`fhirpath/terminology.rkt`) with three closures; `expand`/`validateVS`/`translate`
(`fhirpath/functions.rkt`) dispatch on it. The service is injected via `eval-fhirpath #:externals`
as `%terminologies` (see `run-r5.rkt`); `env-lookup-external` already checks `#:externals` first, so
no engine-core change was needed. Results are typed nodes (built via `from-json`) that navigate
normally (`.expansion.contains`, `.parameter.where(...)`).

Remaining known failures: 1 R4 `@…+0.1 's'` (a genuine R4-vs-R5 spec conflict — R4 truncates fractional seconds, R5
keeps them; fixing R4 would regress R5); 1 R4 signed-zero `(-0.0034).lowBoundary(1)` = `-0.0`
(`fp-decimal` has no signed zero).

## CQL / ELM lang (`#lang fhir/cql`, `cql/`)
Clinical Quality Language (https://cql.hl7.org/) as the next sibling lang. Unlike FHIRPath (evaluated
directly), **CQL is compiled to ELM** (Expression Logical Model, the machine-readable form of a
library) and the ELM is then RUN — the interpreter never evaluates CQL directly. This is the
**foundation CQL slice**: the expression + definition core (the FHIRPath-superset expression grammar +
`library`/`using`/`include`/`parameter`/`define`/function-`define`), System-typed literals (Integer,
Long, Decimal, Quantity, Ratio, String, Boolean, Date/DateTime/Time, List, Interval, Tuple),
operators, `if`/`case`. Layers:
- `cql/parser/` — a **fork-and-extend** of `fhirpath/parser/` (brag grammars can't be imported): a
  `br-parser-tools` `lexer.rkt` (CQL keywords, `'…'` strings, `"…"` delimited ids, `42L` longs), a
  `#lang brag` `grammar.rkt` (a superset precedence cascade + library/definition/interval/list/tuple/
  if/case productions), prefab `ast.rkt` + `lower` (the fhirpath pattern), and a memoized `parse.rkt`
  (`parse-cql` → `Result<cql-library>`, `parse-cql-expr` for bare-expression fragments).
- `cql/elm/` — prefab ELM node structs (`ast.rkt`; binary/n-ary/unary operators share the ELM
  OperatorExpression shape via generic `elm-nary`/`elm-unary` carrying the ELM type string) + `json.rkt`
  emitting **canonical ELM JSON** via `racket/json` (NOT `serialize/to-json.rkt`, which is FHIR-specific);
  `drop-false` shared util; interval `lowClosed`/`highClosed` are meaningful #f (never dropped).
- `cql/compile.rkt` — `cql-ast → elm-ast` with a **light System-type inference** (bottom-up
  `(values node type)`) that resolves overloaded surface operators (`+`→Add on numbers / Concatenate on
  strings; `&`→`Concatenate(Coalesce(l,''),Coalesce(r,''))`; `!=`→`Not(Equal)`; membership→In/Contains;
  numeric promotion Integer<Long<Decimal<Quantity) and stamps `resultTypeName`. Errors are `cql-error`
  (`cql/error.rkt`) in `err`.
- `cql/interp.rkt` + `cql/value.rkt` — the ELM interpreter (`eval-elm`, the ELM analog of `fp-eval`),
  **reusing** `fhirpath/{decimal,quantity,temporal-ops,equality,value}` and adding CQL's structured
  carriers (`cql-interval`/`cql-tuple`/`cql-ratio`/`cql-code`/`cql-concept`) + the `cql-null` singleton.
  Key semantic bridge: CQL is single-value-with-`null` (three-valued And/Or/Xor/Implies; null-propagating
  arithmetic/comparison), not FHIRPath's always-collection model.
- `#lang fhir/cql` (`cql/lang/reader.rkt` + `cql/base.rkt`): a `.cql` file is one library; the reader
  parses it and emits `(cql-library-form <ast>)`; the custom `#%module-begin` compiles to ELM and
  provides `library` (CQL AST), `elm` (ELM AST), `elm-json`, and `results` (define-name → interpreted
  value); `main` prints the ELM JSON. `examples/demo.cql` runs it.
- **Operator registry** (`cql/interp.rkt`): the interpreter core is a small structural recursion over
  ELM nodes; operators are DATA in a hash registry (`def-op!`/`apply-op`, O(1) dispatch, `lazy?` flag for
  short-circuit `and`/`or`/`implies`) — the CQL analog of `fhirpath/functions.rkt`. ~150 operators span
  arithmetic, comparison, logical, string, list, aggregate, DateTime (constructors, `<prec> from`,
  duration `+`/`-`, `between`/`difference in`, precision timing `before/after <prec> of`, `same … as`),
  interval (start/end/width/point-from, contains/includes/meets/overlaps/starts/ends, union/intersect/
  except/collapse/expand, precision-qualified timing), and a **query engine** (`from … where/return/sort/
  aggregate` over lists → cartesian tuples). Values reuse the FHIRPath System carriers (`moment`,
  `fp-decimal`, `fp-quantity`, `fp-long`) + CQL's `cql-interval`/`cql-tuple`/`cql-null`. Intervals are
  normalized to closed bounds at construction (open→successor/predecessor); Integer results overflow to
  null (32-bit). `cql/tests/bench.rkt` guards performance.
- Conformance: `cql/tests/harness.rkt` runs the cqframework/cql-tests XML format
  (`<test><expression [invalid=…]/><output/>`) via **compile→run-ELM→compare-expected** (the
  FHIRPath-TCK philosophy: it evaluates the `<output>` literal as CQL and compares values, treating an
  `invalid` expression as expected-to-fail and a `<library>` test as skipped). The **official HL7 suites
  are vendored verbatim** in `cql/tests/vendor/cql-tests/` (from `cqframework/cql-tests`, commit
  `36a47eb…`, see its SOURCE.txt); `raco fhir cql-tck` (→ `cql/tests/run.rkt`, floor-ratcheted) runs
  them: **1819/1823 (99.8%)** — 11 of 16 suites at 100% (incl. Interval 410/411, DateTime 314/317,
  Arithmetic 234/236, List/Comparison/String/Types near-full). Notable semantics implemented:
  **uncertainty as Interval[min,max]** (operands filled to their full MILLISECOND low/high boundaries,
  extremes over the four corners; comparisons do band comparison; uncertainty intervals participate in
  `+`/`-`/`*`); **ratio literals** (`1'cm':2'cm'`, `=` componentwise / `~` cross-multiplied);
  **instance selectors** (`Code{…}`/`Concept{…}`/`Quantity{…}` build their carriers; other classes a
  typed `cql-obj` so `is Vocabulary` sees the ValueSet/CodeSystem hierarchy); **null-typed lists**
  (`null as List<T>` = `cql-null-list`: Length 0, scalar membership false, list-list inclusion null);
  **CQL ms-precision uncertainty** (a second-precision moment vs a ms-precision one agreeing through
  seconds compares as 'empty — deliberately different from FHIRPath's missing-frac=.000, applied only
  in cql/interp's cql-moment-compare, never in the shared fhirpath engine); calendar-duration `~`
  (pairwise 1 year = 12 months AND = 365 days); literal domains enforced at compile (Integer 32-bit,
  Decimal 28/8 digits); `X between A and B` desugars at the comparison level with the unit-word left
  operand recognised as a duration (context-sensitive, like the reference grammar). The **4 remaining
  misses are irreducible corpus edges**: `Floor(±2^31)` expects out-of-range literals to evaluate while
  ValueLiteralsAndSelectors requires the SAME literals to error (corpus self-contradiction, 2); one
  standalone uncertainty bound (`[17,44]`) contradicts the same corpus's arithmetic convention
  (`[16,44]`-derived, 1); and the `starts 1 day or less on or after day of` timing-phrase family
  (a whole grammar for 1 test). `cql/tests/coverage.rkt` reports the live per-suite/failure-bucket
  breakdown each iteration; `cql/tests/vendor/cql-smoke.xml` is the harness's own self-test (not part of
  the conformance number). `raco fhir cql <file.cql>` prints ELM JSON.
- **Deferred CQL slices**: retrieves (`[Condition: "vs"]`) + a FHIR data-source/retrieve layer (absent —
  `navigate.rkt` assumes in-memory roots), queries (`with`/`where`/`return`/`sort`/`aggregate`),
  terminology-backed membership via the `tx-service`, FHIR model-info from `full-field-specs`, ELM XML
  output, temporal literals as canonical ELM Date/DateTime/Time constructor nodes (slice-1 emits them as
  a Literal carrying the lexeme — round-trips through our interpreter), and a reference-ELM structural
  differential vs the Java `cql-to-elm` translator.

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

## FML / StructureMap lang (`#lang fhir/fml`, `fml/`)
The FHIR Mapping Language as a lang: `fml/parser/grammar.rkt` is a `#lang brag` port of the
**official `hl7.org/fhir/R5/mapping.g4`** (vendored alongside as `fml/parser/mapping.g4`). Where the
g4 stubs FHIRPath ("insert reference to FhirPath grammar here"), the repo's FHIRPath cascade is
INLINED with the same rule names — so `fhirpath/parser/ast.rkt`'s `lower` turns embedded expressions
into REAL FHIRPath ASTs at parse time (`fml-fhirpath` carries the AST; nothing re-parses at
runtime). Documented g4 deviations follow the reference implementation + the vendored suite: bare
(unparenthesized) `where`/`check` expressions, `share <listRuleId>`, string rule-names,
double-quoted strings inside expressions, and the fp `is`/`as` OPERATOR level omitted (`create('X')
as var` must read as a target alias; the `.is()`/`.as()` function forms remain).
`fml/fhirpath-print.rkt` prints ASTs back to canonical text (print∘parse fixpoint-tested) for the
StructureMap emission. Two consumers: `fml/structuremap.rkt` (AST → the StructureMap resource
jsexpr — the canonical compiled form, printed by `#lang fhir/fml`'s `main`) and `fml/transform.rkt`
(the executor): a rule matches its source element(s) (where-filtered FHIRPath over typed nodes),
binds `as` vars, then runs comma-chained target ops / `then` dependent group calls / nested rules. Targets build through TSLOTs — closures that mutate the jsexpr under
construction up to the root — whose shape is **registry-driven** (`full-field-specs`: max>1 appends
arrays, max-1 sets scalars, and a `create('T')` on a `value[x]` element picks the `value<T>` key).
`share v` reuses one target element across rules. FML's FHIRPath dialect bridges: rule variables
become `%externals` via a chain-head AST rewrite, and element-model `.value` steps retry stripped.
Conformance (`raco fhir fml-tck` → `fml/tests/run.rkt`): the vendored
`fhir-test-cases/r5/structure-mapping` suite — **6/6 executable JSON tests, 15/15 `.map` parses**;
the 4 CDA/XML-output tests + the one StructureMap-as-JSON input are skipped (XML is out of scope
repo-wide, documented in the vendor SOURCE.txt).

## VCL lang (`#lang fhir/vcl`, `vcl/`)
VCL — the ValueSet Compose Language (build.fhir.org/ig/FHIR/ig-guidance/vcl.html), a compact
URL-embeddable syntax for ValueSet composes — as the 5th brag lang. `vcl/parser/vcl.g4` is the
official ANTLR grammar vendored verbatim; `grammar.rkt` ports it rule-for-rule (documented
deviations: a named `tail` rule; codeList accepts a singleton so decompiled one-code `in` filters
round-trip). The lexer is faithful to the g4's deliberate URI greed (a URI token eats `;&^{}`
until whitespace/paren — hence the bracketed `(system)` form). Prefab AST + `lower`
(`parser/ast.rkt`), memoized `parse-vcl -> Result` (the cql pattern). `vcl/compile.rkt` maps AST →
ValueSet.compose: disjunction → include entries, conjunction → one include's AND'd filters,
top-level `-` → exclude, `(system)` distributes (codes collapse into one concept list), `^uri` →
valueSet, the 11 filter ops + R6 `of`; NOT compose-expressible (nested exclusion, conjoined
enumerations, bare `*`) errs clearly. `vcl-print` re-brackets compound members (the spec has NO
`,`/`;` precedence). `vcl/decompile.rkt` is the reverse (compose→VCL; nested filter values
reparse via the real grammar). Conformance: all **60 spec examples** (vendored,
`vcl/tests/vendor/`) parse AND survive the print∘parse fixpoint; compose round-trip law tested.
`#lang fhir/vcl` (one expression per file; parse errors are COMPILE errors) provides
source/expression/compose/valueset; `raco fhir vcl <expr>` prints the ValueSet. **Implicit VCL
ValueSets work in `$expand`**: `terminology/service.rkt` recognizes `http://fhir.org/VCL?v1=…`,
percent-decodes (spec SHALL), compiles, and expands against its index — so `%terminologies` and
the validator see VCL urls as real ValueSets.

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

## Known deferrals
- Full IG *package* generation (an IG as a `gen-target` with `delegate-base`) — the `#:delegate` seam
  and the sd profiling lang exercise delegation; whole-package IG codegen is not wired yet.
- FML / query-and-retrieve CQL — future work over `model/node` + `model/registry` + `fhirpath`.
