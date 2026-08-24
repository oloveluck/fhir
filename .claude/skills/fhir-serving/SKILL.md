---
name: fhir-serving
description: Serve and persist FHIR in this repo — the embedded SQLite+DuckDB store, `raco fhir serve` for a REST API from a #lang fhir/capability app, `raco fhir load` for Bundles, transaction/batch bundles, and audit/provenance. Use when running a FHIR server or loading resources into a store.
---

# Serving & persisting FHIR

> Built for spec development and testing, not production. Persistence is an embedded **SQLite** store
> (WAL, connection pool, versioned history, FHIRPath-extracted token/reference search indexes) with
> **DuckDB** attached over the same file for analytics (see the **fhir-analytics** skill).

## Serve a capability app over HTTP

`http/` is a from-scratch HTTP/1.1 server (no `web-server` dependency) that serves a
`#lang fhir/capability` app (see **fhir-authoring**).

```sh
raco fhir serve examples/server-app.rkt 8080
```

Exposes the FHIR REST grammar: `GET /metadata` (the derived CapabilityStatement), resource CRUD
(`GET/POST/PUT/DELETE /{Type}[/{id}]`), vread (`/{Type}/{id}/_history/{vid}`),
`GET /{Type}?param=value` search, and `$operation` invocation at system/type/instance level.
`serve-app : app #:port → shutdown-thunk` is also a plain library function.

## Store-backed serving (IG-driven search)

`store/serve.rkt`'s `make-store-app` derives the whole thing from an IG/core package: the package's
own `SearchParameter` resources build the search catalog, and the CapabilityStatement is derived from
that same catalog — advertised params and working search can't drift.

```racket
(make-store-app #:package (list r5-tgz) #:types '(Patient Observation …))
```

`racket examples/store-app.rkt` prints the derived `/metadata`;
`raco fhir serve examples/store-app.rkt` exposes CRUD + vread + IG-param search over SQLite.

## Load resources / Bundles

```sh
raco fhir load <store.db> <bundle.json | dir>
```

Handles `transaction` (atomic, one store transaction, `urn:uuid` reference resolution + spec-ordered
apply), `batch` (per-entry outcomes), and `collection` (the Synthea create-batch shape). A
transaction/batch Bundle POSTed to `/` routes to the app's `#:transaction` handler.

## Audit + Provenance

`make-store-app … #:audit? #t` records an `AuditEvent` (and a `Provenance` for create/update) into
the store on every committed write — served and searchable like any resource
(`GET /AuditEvent?action=C`). Writes to AuditEvent/Provenance themselves are exempt (no recursion).

## Direct store API

`store/fhir-engine.rkt`: `fhir-create!/read/vread/update!/delete!/history/search` over a
`fhir-store` (path + connection pool). Writes go only through `call-with-store-transaction`; search
params are data (FHIRPath per type), reindexed inside the same write transaction.
