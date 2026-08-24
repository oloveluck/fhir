---
name: fhir-analytics
description: FHIR analytics & OMOP in this repo — run SQL-on-FHIR ViewDefinitions and the FHIR→OMOP ETL over DuckDB (`raco fhir omop`, omop/session.rkt), and materialize any ViewDefinition as a DuckDB table. Use for cohort SQL, OMOP CDM, or SQL analytics over a FHIR store.
---

# Analytics & OMOP over DuckDB

> DuckDB (via FFI, `store/fhir-analytics.rkt`) ATTACHes the SQLite store file read-only through the
> sqlite_scanner, so one session answers both raw-FHIR JSON queries (`fhir.*`) and flattened
> analytics tables (`omop.*`, materialized views) side by side. Meant for spec/analytics
> exploration, not production.

## FHIR → OMOP ETL

The FHIR-to-OMOP IG (`hl7.fhir.uv.omop`) generates `#lang fhir/omop` (25 CDM tables). The ETL is the
SQL-on-FHIR route the IG's StructureMaps describe: one ViewDefinition per table (`omop/views.rkt`)
→ translate concept columns through the IG's own ConceptMaps → mint integer keys → load a DuckDB
`omop` schema (DDL derived from the logical models).

```sh
raco fhir omop <store.db>                 # run the ETL, print table counts
raco fhir omop <store.db> "<SQL>"         # ETL then query (one JSON row per line)
raco fhir omop <store.db> "<SQL>" out.duckdb   # also persist the omop schema to a .duckdb file
```

`examples/omop-demo.rkt` is the end-to-end walkthrough. The persisted `out.duckdb` opens directly in
the standalone `duckdb` CLI.

## Session API (`omop/session.rkt`)

```racket
(with-omop store
  (λ (s)
    (omop-counts s)
    (omop-query s "SELECT AVG(...) FROM omop.person JOIN fhir.fhir_resources ...")
    (omop-materialize! s my-viewdef)))   ; a custom SOF view alongside the CDM
```

- `open-omop` / `with-omop` — analytics session + full ETL; `#:duckdb path` for a persistent file.
- `omop-query` — plain SQL; both `omop.*` and `fhir.*` are in scope.
- `omop-materialize!` — materialize a custom SQL-on-FHIR view into the same session.

## Materialize any ViewDefinition

`viewdef/materialize.rkt`: `materialize-view!` turns ANY SQL-on-FHIR ViewDefinition into a DuckDB
table (`replace-table!` is idempotent CREATE OR REPLACE + batched insert; DDL from `#:columns` /
the view's SOF `type` hints / value inference). This is the shared bottom half the OMOP loader reuses.

## Cross-engine store analytics

`store/fhir-analytics.rkt`: `open-analytics` (checkpoints WAL, `ATTACH … TYPE SQLITE READ_ONLY`),
`fhir-analytics-query` (rows as hasheqs), `fhir-flatten-observations` (a `json_extract` flattening
example). `#:duckdb path` reopens a persistent DuckDB file; `store` may be `#f` to open a `.duckdb`
alone with no ATTACH.
