# fhir — FHIR as a family of Racket `#lang`s

A language-oriented-programming implementation of [FHIR](https://build.fhir.org/). FHIR's type
system is treated as a *collection of languages*: a foundation type framework, and one generated
`#lang` per version tower (`#lang fhir/r6`, `#lang fhir/r4`) whose type macros validate resources at
**compile time** and build a typed value that serializes to JSON.

This is the **foundation vertical slice** — one coherent end-to-end path proving the architecture,
not breadth. See `docs`/the plan for the grander vision (StructureDefinition lang, per-IG langs,
capability/operation langs, and FHIRPath/CQL/FML/FSH).

## What works today

- **Primitives** — all ~21 FHIR primitives as validated opaque newtypes (`primitives/`), with
  variable-precision temporal values and Result-not-exceptions validation.
- **A typed value model** — one generic tagged node `(struct fhir (type fields))` (`model/node.rkt`);
  jsexpr is a *derived* view, so every value keeps its FHIR type tag.
- **Compile-time validating form macros** — `lang-gen/form-syntax.rkt`'s `build-fhir-form` checks
  unknown/duplicate/missing fields, cardinality, choice min/max, nested type heads, and primitive
  literals at expansion, raising located `raise-syntax-error`s. **Required terminology bindings are
  enforced at compile time too**: each tower's generated `terminology.rkt` carries every
  required-bound ValueSet expanded offline from the package's own CodeSystems (202 in R6), so
  `(Patient (gender "florp"))` is a syntax error listing the valid codes.
- **Schema-driven JSON round-trip** — `serialize/{to-json,from-json}.rkt`, both driven by one
  registered `type-schema` so they cannot drift. Handles the primitive `_field` sibling
  (id/extension) and **precision-preserving decimals** (string-backed; emitted as raw number tokens).
  Exercised by a large **round-trip corpus** (`raco fhir roundtrip-tck r4|r5`): the vendored HL7
  `fhir-test-cases` examples plus every resource in the R4/R5 core packages — **~7,700 real resources**
  parse → serialize → re-parse idempotently (`tests/example-roundtrip-r{4,5}.rkt`).
- **Spec-driven codegen** — `codegen/` reads the vendored R6/R4 core packages and emits the tower
  (form macros + runtime schemas + the `#lang`), deterministically, guarded by `raco fhir check`.
- **A profiling language** — `#lang fhir/sd` defines profiles that narrow a base type's cardinality
  (checked at compile time) and compile to a **delegating** form macro, composing to any depth
  (profile → profile → base → typed node).
- **Standalone checked literals** — `(lit date "1974-12-25")` (`primitives/literals.rkt`).
- **FHIRPath** — a from-scratch engine (`fhirpath/`) over the typed node model, with full UCUM
  quantities (incl. product/quotient units), precision-aware decimals/temporals, a conservative
  static semantic pass, and the complete function library. Passes the official HL7 conformance
  suites (`raco fhir fhirpath-tck r4|r5`): **R5 1044/1044, R4 932/934** — 100% of in-scope tests
  (R4's two misses are genuine R4-vs-R5 spec-edge cases).
- **FHIR Shorthand (bidirectional)** — `#lang fhir/fsh` (`fsh/`) is a from-scratch FSH compiler (the
  authoring DSL compiled by SUSHI): Profiles, Extensions (with auto-scaffolding), ValueSets,
  CodeSystems (incl. concept hierarchy), Instances, Invariants, Aliases, discriminator slicing
  (incl. reslicing + multi-discriminator), Logical models & custom Resources (`addElement`), Mappings,
  and RuleSets — plain **and
  parameterized** (`{param}` substitution). Emits StructureDefinition differentials by default and full
  **snapshots** opt-in (`emit-snapshot?`, merged onto the R5 base). Targets R5; a `.fsh` file is a
  module producing the FHIR resources, and `raco fhir fsh <dir>` batch-compiles a folder SUSHI-style.
  The **reverse** direction (FHIR → FSH, GoFSH) is `raco fhir gofsh <file.json>` / `fhir->fsh` /
  `node->fsh`. Verified against the vendored SUSHI **golden corpus** (forward **22/22**) and a full
  **FSH→FHIR→FSH→FHIR round-trip fixpoint** (**22/22**), plus a parse∘print AST fixpoint.
- **CQL → ELM** — `#lang fhir/cql` (`cql/`) compiles Clinical Quality Language to **ELM** (its
  machine-readable form) and then RUNS the ELM (never CQL directly) with a small interpreter that
  **reuses the FHIRPath engine's** decimal/quantity/temporal/equality primitives. This is the
  foundation slice: the expression + definition core (the FHIRPath-superset grammar + `library`/
  `define`/function defs, literals incl. List/Interval/Tuple/Quantity, operators, `if`/`case`) with a
  light System-type inference that picks overloaded operators (`+`→Add/Concatenate) and stamps result
  types. A `.cql` file is a module providing the CQL AST, the ELM AST, the ELM JSON, and each define's
  interpreted value; `raco fhir cql <file.cql>` prints ELM JSON. Conformance is the FHIRPath-TCK
  philosophy — compile→run-ELM→compare-expected — run against the **official HL7 `cqframework/cql-tests`
  suites** (vendored verbatim; `raco fhir cql-tck`): **1819/1823 (99.8%)**. Eleven of sixteen suites
  pass in full; the 4 remaining misses are documented irreducible corpus edges (2 self-contradictions
  in the corpus's integer-literal-range rules, 1 uncertainty bound contradicting the same corpus's own
  arithmetic convention, 1 exotic timing-phrase family). Covers uncertainty ranges, ratio literals,
  instance selectors, null-typed lists, and interval/timing algebra. The operator set is a **table-driven registry**
  (HTDP-style: operators are data, O(1) hash dispatch) reusing the FHIRPath decimal/quantity/temporal
  engine; queries, timing phrases, intervals, and durations are all supported over System values. The
  remaining tail is the hard edges — DateTime uncertainty ranges, UCUM boundary ops, ratio literals.
- **SQL-on-FHIR** — `#lang fhir/viewdef` is a **generated IG tower** (the SQL-on-FHIR IG's
  ViewDefinition resource run through the same codegen as R6/R4, delegating core datatypes to the R6
  base — the first IG-as-gen-target): compile-time-validated ViewDefinition authoring, plus a
  hand-written evaluator (`viewdef/eval.rkt`) that runs views over typed resources with the FHIRPath
  engine (forEach/forEachOrNull/repeat/unionAll/where/constants/%rowIndex/getReferenceKey) →
  flat rows. Passes the **complete official shared test suite** (vendored from FHIR/sql-on-fhir.js):
  `raco fhir sof-tck` → **133/133**. The generated schema doubles as the view validator (strict
  `from-json` rejects the suite's invalid views — and caught the ballot IG's own examples using an
  element its StructureDefinition doesn't declare, guarded by `tests/ig-examples-sof-test.rkt`:
  every example an IG ships must parse). Codegen also consumes the package's
  **OperationDefinitions** — every tower gets a generated `operations.rkt` (ODs as data + scaffold
  constructors needing only a handler) — and the IG's **`$sql-run`/`$sql-export`** are served
  (`viewdef/run.rkt` + `make-store-app #:sof? #t`): stored/searchable ViewDefinitions, subject by
  canonical/reference/inline, ndjson/json/csv results streamed RAW in their native media type,
  `_format=fhir` as Parameters, and a synchronous-completion `$sql-export` manifest.
- **VCL** — the ValueSet Compose Language (`#lang fhir/vcl`, `vcl/`): the official ANTLR grammar
  vendored and ported to brag; expressions compile to ValueSet.compose (and decompile back — all
  **60 spec examples** parse + survive the print∘parse fixpoint); a parse error is a compile
  error; implicit `http://fhir.org/VCL?v1=…` ValueSet URLs expand directly in
  `$expand`/`%terminologies`. `raco fhir vcl '(http://loinc.org)(a;b)'` prints the ValueSet.
- **FHIR Mapping Language** — `#lang fhir/fml` (`fml/`): a brag parser ported from the **official
  `mapping.g4`** (vendored) with the FHIRPath grammar inlined — embedded expressions parse to real
  FHIRPath ASTs at compile time — plus a **StructureMap
  compiler** (`fml->structuremap`), and a **transform engine** (`run-map`) that executes
  groups/rules (where-filters, dependent calls, nested rules, `share`d targets, multi-target
  chains, `create`/`reference`/`evaluate`/`cast`) over typed resources — with the target's shape
  (array vs scalar, `value[x]` choice keys) driven by the **runtime type registry**. Against the
  vendored `fhir-test-cases/r5/structure-mapping` suite (`raco fhir fml-tck`): **all 6 executable
  JSON tests + all 15 `.map` parses** pass (the 4 CDA/XML-output tests are out of scope — this repo
  is JSON-only).
- **Persistence engine** — `store/`: an embedded FHIR store where **SQLite** (WAL, connection pool,
  transactional CRUD + versioned history + FHIRPath-extracted token/reference search indexes) and
  **DuckDB via FFI** (sqlite_scanner ATTACHing the same file, read-only) share one database — FHIR
  search through SQLite indexes, SQL-on-FHIR-style analytics (`json_extract` flattening, aggregates)
  through DuckDB. Search params are data (FHIRPath expressions per type); indexes rebuild inside the
  write transaction. End-to-end integration test covers CRUD, search, cross-engine analytics, and
  WAL snapshot isolation. **IG-driven serving** (`store/ig-params.rkt` + `store/serve.rkt`): the
  package's own SearchParameter resources build the search catalog (multi-base FHIRPath narrowed at
  the AST level, `resolve()` guards folded into the reference index), the CapabilityStatement is
  derived from that same catalog, and `raco fhir serve examples/store-app.rkt` exposes the REST
  endpoints — advertised params and working search can't drift because both come from one artifact.
  **Transaction/batch Bundles** (`POST /`): atomic transactions with `urn:uuid` reference
  resolution and spec-ordered application, per-entry batch outcomes, and `raco fhir load` for
  prepopulating from Bundle files (Synthea-style transaction or collection exports).
  **Audit + Provenance** (`#:audit? #t`): every write records an AuditEvent and a Provenance into
  the store itself, served and searchable like any other resource (`GET /AuditEvent?action=C`).
- **OMOP lang + FHIR→OMOP analytics** — the FHIR-to-OMOP IG (`hl7.fhir.uv.omop`) as a generated
  tower: the 25 OMOP CDM tables (the IG's logical models) become `#lang fhir/omop` types named like
  OMOP DDL (`(person (person_id 1) …)`), coexisting with the R5 core tower. SQL-on-FHIR
  ViewDefinitions — one per table, mirroring the IG's own StructureMaps — flatten FHIR resources
  into OMOP rows; concept columns translate through the IG's own ConceptMaps; DuckDB gets an `omop`
  schema (DDL derived from the logical models) loaded next to the ATTACHed SQLite store, so one
  session answers OMOP cohort SQL (joins, aggregates, date arithmetic) AND raw-FHIR queries.
  The session API (`omop/session.rkt`: `with-omop` / `omop-query` / `omop-materialize!`) runs
  plain SQL and materializes custom SQL-on-FHIR views alongside the CDM
  (`viewdef/materialize.rkt` turns ANY ViewDefinition into a DuckDB table); `#:duckdb path`
  persists the omop schema to a file the standalone `duckdb` CLI opens directly.
  `raco fhir omop <store.db> [SQL] [out.duckdb]`; `examples/omop-demo.rkt` is the walkthrough.
- **Snapshot generation + resource validation** — `conformance/` generates a StructureDefinition
  snapshot (differential merged onto the base, from the R5 core package) and **validates** a resource
  against its base type / profiles: cardinality, unknown-element, **type-narrowed choice[x]** (a
  `value<X>` key is checked against the element's declared `type[]` — a disallowed variant is flagged
  unknown and doesn't satisfy the required `value[x]`, and the chosen concrete type drives the primitive
  and recursion checks), primitive format (decimals validated on their exact JSON lexeme),
  fixed[x]/pattern[x], required bindings (via the terminology service), and FHIRPath invariants
  (opt-in). It is strictly **fail-open** — never reports an issue when anything is undecidable — gated
  by a never-over-report corpus test (0 errors over 200 valid R5 resources) and a **case-level recall
  differential** against the HL7 reference validator's recorded outcomes (false-positives = 0; recall
  14/16 on a curated R5 subset, ratcheting up — incl. **duplicate JSON key** detection via the reader's
  `read-fhir-json/duplicates`). `raco fhir validate <resource.json> [profile.json…]` and
  `raco fhir snapshot <sd.json>`.
- **An HTTP server** — `http/` serves a `#lang fhir/capability` app over a small from-scratch HTTP/1.1
  server (`racket/tcp`; no `web-server` dependency). `raco fhir serve <app.rkt> [port]` exposes FHIR
  REST: `GET /metadata` (the CapabilityStatement), resource CRUD (`GET/POST/PUT/DELETE /{Type}[/{id}]`),
  `GET /{Type}?param=value` search, and `$operation` invocation at system/type/instance level. Declared
  **search parameters** carry a FHIRPath expression and actually filter, via a generic in-memory
  repository (resources with no explicit `#:repository`). `serve-app` is also a plain library function.
- **A capability / operation language** — `#lang fhir/capability` (`capability/`) DECLARES what a FHIR
  app supports (`server` / `resource` / `operation` forms) and DERIVES the CapabilityStatement + an
  OperationDefinition per operation (so `/metadata` can't drift), then assembles an in-process
  application: pluggable resource repositories + operation handlers and a `dispatch` that routes a
  request over typed nodes (unknown/unsupported → an OperationOutcome). Declarations are validated at
  compile time against the R6 schemas.
- **A terminology service** — `terminology/` backs FHIRPath's `%terminologies` (`expand` /
  `validateVS` / `translate`): a real, version-neutral service that lazily loads a vendored core
  package, indexes every CodeSystem/ValueSet/ConceptMap by canonical URL, and runs
  `$expand`/`$validate-code`/`$translate`. `make-r5-terminology` / `make-r4-terminology` (or
  `make-terminology <tgz>`) — the result nodes build against whichever tower the caller registered.

## Conformance corpora

Every suite is vendored verbatim with a SOURCE.txt (source URL, retrieval date, and exactly what
is skipped and why) and gated by a floor that only rises:

| suite | source | current |
|---|---|---|
| FHIRPath | HL7 R4/R5 official suites | **1044/1044** (R5), 932/934 (R4) |
| CQL | cqframework/cql-tests | **1819/1823** |
| UCUM | the official UCUM functional tests | **573/573** (every section) |
| SQL-on-FHIR | FHIR/sql-on-fhir.js shared suite | **133/133** |
| terminology | hl7.fhir.uv.tx-ecosystem | **463/553** |
| snapshot generation | fhir-test-cases rX/snapshot-generation | **80/80 paths**, 143/148 cardinality |
| validator differential | fhir-test-cases + recorded Java outcomes | **0 false positives**, 17/26 caught (67 cases) |
| FML | fhir-test-cases structure-mapping | 6/6 exec, 15/15 parse |
| VCL | the spec page's own examples | 60/60 parse + print∘parse fixpoint |
| FSH | the SUSHI golden corpus | 22/22 forward + round-trip |
| round-trip | HL7 examples + R4/R5 core packages | ~7,700 resources |
| IG examples | US Core 9.0.0 + IPS 2.0.1 | **274/274** parse *and* round-trip |

## Try it

```sh
racket examples/patient.fhir6      # author a Patient in #lang fhir/r6, print its FHIR JSON
racket examples/patient.fhir4      # the same pipeline, R4
raco make examples/us-core.sd      # #lang fhir/sd — profiles (US Core-style) over the R6 base
racket examples/patient-app.rkt    # #lang fhir/capability — configure an app, print its /metadata
raco fhir serve examples/server-app.rkt 8080   # serve that app over HTTP (GET /metadata, CRUD, search, $ops)
racket examples/patient.fsh        # #lang fhir/fsh — compile FSH to FHIR JSON
raco fhir fsh <dir>                # SUSHI-style: compile a folder of .fsh into fsh-generated/
raco fhir gofsh <file.json>        # reverse: decompile a FHIR resource to FSH text
racket examples/demo.cql           # #lang fhir/cql — compile CQL to ELM, print the ELM JSON
raco fhir cql <file.cql>           # compile a CQL library to ELM JSON
raco fhir cql-tck                  # run the CQL expression conformance suite (compile→run→compare)

raco fhir regen [r6|r4|all]        # regenerate the type tower(s) from the vendored spec
raco fhir check [r6|r4|all]        # verify the committed tower matches a fresh regen (CI guard)
raco fhir roundtrip file.json Patient   # parse FHIR JSON to a typed node and re-serialize
raco fhir fhirpath-tck r5               # run the official FHIRPath R5 conformance suite (or r4)
raco fhir roundtrip-tck r5              # parse+serialize round-trip every resource in the R5 corpus (or r4)
raco fhir validate <resource.json> [profile.json…]   # validate a resource -> OperationOutcome (exit 1 on error)
raco fhir snapshot <sd.json>           # generate a StructureDefinition snapshot

raco test result/ model/ primitives/ kernel/ lang-gen/ serialize/ codegen/ tests/
```

Example (`examples/patient.fhir6`):

```racket
#lang fhir/r6
(Patient
 (id "example") (active #t) (gender "male") (birthDate "1974-12-25")
 (name (HumanName (family "Chalmers") (given "Peter" "James")))
 (maritalStatus (CodeableConcept (coding (Coding (code "M") (display "Married")))))
 (deceasedBoolean #f))
```

`(birthDate "1974-13-40")`, `(notAField "x")`, or `(name (Coding …))` all fail to **compile**.

## Layout

```
result/       Result type (ok/err + ValidationError, each carrying its spec-url)
model/        base (framework hierarchy), schema (field-spec/ftype/type-schema), node (typed value),
              registry (prop:fhir-spec + type/primitive/element registries), introspect (read a
              type's full schema at phase 1 — the reflection seam the profiling lang grows onto)
primitives/   define-primitive macro, patterns, temporal, the catalogue, literals (lit)
lang-gen/     form-syntax (the compile-time validating macro build-fhir-form, incl. #:delegate)
kernel/       node-build (runtime sink), kit (#lang #%module-begin + JSON view)
serialize/    to-json / from-json (schema-driven; _field siblings + precise decimals)
foundation/   the base module language + reader (#lang fhir/foundation)
sd/           the StructureDefinition / profiling lang: profile (delegating form macros), base, reader
fhirpath/     the FHIRPath engine: parser/, value/decimal/temporal-ops/quantity/ucum, types, navigate,
              equality, operators, functions, environment, eval, terminology (%terminologies handle);
              tests/ (HL7 TCK harness + inputs)
terminology/  a terminology service (make-r5-terminology): R5-core-backed $expand/$validate-code/$translate
capability/   the capability/operation lang: reader, base, module-begin (partition+assemble), declare
              (compile-time validation), derive (CapabilityStatement/OperationDefinition), runtime
              (repository/operation-handler/app/request + dispatch + generic in-memory search)
http/         a minimal HTTP/1.1 server (racket/tcp): router (FHIR REST <-> dispatch), server (serve-app)
conformance/  sd-index (base SDs from the R5 package), snapshot (differential->snapshot merge),
              element-index (SdElements lookups + datatype jump), validate (structural + invariants +
              bindings + slicing -> OperationOutcome, fail-open)
fsh/          the FHIR Shorthand lang (bidirectional): parser/ (brag grammar + lexer + prefab AST +
              path), resolve (R5 path→type), caret, compile (FSH→FHIR jsexpr; slicing, extensions,
              logical/resource, parameterized RuleSets), snapshot + sd-index (opt-in snapshots from the
              R5 package), print + decompile (FHIR→FSH), base + lang/reader (#lang fhir/fsh),
              tests/ (SUSHI golden + round-trip fixpoint + features)
cql/          the CQL→ELM lang: parser/ (brag grammar + lexer + prefab AST + parse, forked from
              fhirpath), elm/ (prefab ELM structs + canonical-JSON emitter), compile (CQL→ELM + type
              inference), interp + value (ELM interpreter reusing the fhirpath primitives; CQL null),
              base + lang/reader (#lang fhir/cql), tests/ (cql-tests-format conformance harness + vendor)
codegen/      load-spec, structure-definition, ir, nest, expand, emit-form, emit-schema, gen,
              check (determinism guard), target (the R6/R4 parameterization seam)
r6/ r4/       GENERATED towers (forms + schema + #lang) — do not edit; run `raco fhir regen`
cli/          raco fhir
spec/         vendored hl7.fhir.{r6,r4}.core.tgz
```

## Prior art

Informed by two local repos (not reused verbatim): `~/Sandbox/stroma` (a rough Racket LOP FHIR,
source of the `#lang`-tower + compile-time-macro approach) and `~/Sandbox/fhir4s` (a polished Scala
FHIR, source of the spec-driven-codegen + determinism-guard + typed-value discipline).
