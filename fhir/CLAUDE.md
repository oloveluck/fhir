# CLAUDE.md — fhir

Notes for the FOUNDATION package `fhir` (this directory; `(define collection "fhir")`). Conventions,
HTDP design style, the package map and the conformance ratchet table live in the repo root's
CLAUDE.md. `fhir-tools/` (same repo) contributes the application layer to the same `fhir` collection:
the two must stay module-disjoint. Cross-directory imports use collection paths (`fhir/model/node`,
never `../model/node.rkt`). The vendored spec tarballs are the separate `fhir-spec` package, found via
`spec-package.rkt` — nothing here depends on them statically (codegen and snapshot generation need them
at run time and say so).

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
## StructureDefinition / profiling lang (`#lang fhir/sd`, `sd/`)
`(profile Name #:base Base (field min max) …)` reads `Base`'s full schema at **phase 1** (via
`model/introspect.rkt`'s `full-field-specs`, which reads the runtime registry — `sd/profile.rkt`
requires `fhir/r6/types` for-syntax to populate it), validates each override as a genuine *narrowing*
(loosening is a compile error), and synthesizes a form macro that validates the constrained schema
then **delegates** to the base macro (`build-fhir-form #:delegate`). `#:base` may be a base type or an
earlier profile → multi-level delegation (a compile-time `profile-table` carries each profile's
constrained schema for profile-of-profile). The built value is the base resource; the profile adds
only compile-time conformance. Reader is plain (profiles are definitions, not resource instances).
## Serialization details now handled (`serialize/`)
- **Primitive `_field` sibling**: id/extension serialize to a parallel `_field` object (list →
  `_field` array with `null` placeholders) and merge back on parse.
- **Precision-preserving decimal**: `decimal` is string-backed; `node->json-string` emits it as a raw
  number token via an internal extended-jsexpr (`raw-num`). `node->jsexpr` is the lossy structured
  view. Read via racket/json is number→string (value-kept; trailing zeros limited by racket/json —
  a decimal supplied as a JSON *string* is preserved exactly).
- **`lit` macro** (`primitives/literals.rkt`): standalone compile-time-checked literals, e.g.
  `(lit date "1974-12-25")`.

## Snapshot generation + SD index (`sd/sd-index.rkt`, `sd/snapshot.rkt`, `sd/element-index.rkt`)
Moved here from `conformance/` in the package split: they read only the vendored R5 core package
(no FHIRPath), so they live with the StructureDefinition tooling and `fsh` can generate
snapshots without depending on the validator. `conformance/validate.rkt` (main `fhir` package)
and `fsh/compile.rkt` import them as `fhir/sd/snapshot` etc. The full description is in the main
repo's "Snapshot generation + validation" section.

## Operation entries (`kernel/operation-entry.rkt`)
The one struct a generated tower's `operations.rkt` produces. Lives in the foundation so the
towers depend only on fhir; `capability/runtime` (main package) re-exports it.
