---
name: fhir-serving
description: "Serve and persist FHIR with the fhir-server package — servers generated from IG packages (`raco fhir-server serve-ig`), `raco fhir-server serve` for a #lang fhir/capability app, the embedded SQLite store, `raco fhir-server load`, transaction/batch bundles, audit/provenance, and `$evaluate-measure`. Use when running a FHIR server or loading resources into a store."
---

# Serving & persisting FHIR

> Built for spec development and testing, not production. Persistence is an embedded **SQLite** store
> (WAL, connection pool, every resource as JSONB, versioned history, FHIRPath-extracted, type-driven
> search indexes).

## Serve a capability app over HTTP

`http/` is a from-scratch HTTP/1.1 server (no `web-server` dependency) that serves a
`#lang fhir/capability` app (see **fhir-authoring**).

```sh
raco fhir-server serve examples/server-app.rkt 8080
raco fhir-server serve clinic.rkt 8080 --store fhir.db   # resources without a #:repository kept in SQLite
```

A resource declared without `#:repository` is kept in a SQLite FHIR store when there is one — the
`--store` file, `(server #:store "fhir.db")` (beside the module), or a workspace's `fhir.db` when the
workspace runs the app (`<name>.capability.rkt`, learn://capability) — and in a temporary one,
removed when the server stops, otherwise. The
store keeps each resource as SQLite JSONB, with its history and search indexes. For tables of
values, a workspace over the same store (`data: fhir.db`) reads it through SQL on FHIR views
(learn://sql-on-fhir); `raco fhir-server sql` reads the raw JSONB (`resource ->> '$.gender'`).

Exposes the FHIR REST grammar: `GET /metadata` (the derived CapabilityStatement), resource CRUD
(`GET/POST/PUT/DELETE /{Type}[/{id}]`), vread (`/{Type}/{id}/_history/{vid}`),
`GET /{Type}?param=value` search, and `$operation` invocation at system/type/instance level.
Every server follows FHIR's REST rules for pages and versions: `_count` takes a page, the Bundle's
`total` counts every match and `next`/`previous` links lead through the pages (`_summary=count` is
the total alone; `POST /{Type}/_search` takes the parameters as a form); an answer that is one
resource carries `ETag: W/"<versionId>"` and `Last-Modified`; a read with `If-None-Match` or
`If-Modified-Since` the current version satisfies is 304; a PUT, PATCH or DELETE with `If-Match`
naming another version is 412; a deleted resource is 410 Gone (404 if it never was).
`serve-app : app #:port → shutdown-thunk` is also a plain library function.

## Store-backed serving (IG-driven search)

`store/serve.rkt`'s `make-store-app` derives the whole thing from an IG/core package: the package's
own `SearchParameter` resources build the search catalog, and the CapabilityStatement is derived from
that same catalog — advertised params and working search can't drift.

```racket
(make-store-app #:package (list r5-tgz) #:types '(Patient Observation …))
```

`racket examples/store-app.rkt` prints the derived `/metadata`;
`raco fhir-server serve examples/store-app.rkt` exposes CRUD + vread + IG-param search over SQLite.

## Load resources / Bundles

```sh
raco fhir-server load <store.db> <bundle.json | dir> [--fhir-version 4.0.1|5.0.0|6.0.0] [--validate [--package <guide>]…]
```

It reads `.json` (resources, Bundles), bulk data (`.ndjson`, `.ndjson.gz`: a resource to a line,
ids kept) and `.cql`. Indexed for every search FHIR defines for the type, in R4 unless `--fhir-version` says otherwise
(a `#lang fhir/capability` app is R6). `load` checks nothing unless `--validate` is given: then
every resource (a Bundle's entries too) is held to its type and the profiles it claims first, each
problem printed as `file: Type/id: error: path: message`, and nothing is loaded when one is an
error (exit 1). A server validates what is written through it, single writes and each entry of a
transaction or batch alike.

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

## Server generated from an IG
```sh
raco fhir-server serve-ig hl7.fhir.us.core --port 8080     # loads the IG's examples (validated) and serves
raco fhir-server serve-ig hl7.fhir.us.core --gaps          # the IG requirements this server does not meet
raco fhir-server serve-ig path/to/package.tgz --db store.db --no-examples
```
Everything comes from the package: FHIR version, resource types, interactions, search parameters
(type-driven search: string/date/number/quantity/token/reference/uri, modifiers, prefixes,
`_include`/`_revinclude`), write validation against claimed profiles (422), IG operations with an
implementation (`$docref`, `ValueSet/$expand`, `Measure/$evaluate-measure`). Library:
`fhir/store/ig-server` (`make-ig-server`, `load-ig-examples!`).

## Measure processing (CQL over the store)
```sh
# a server from CQF Measures (that IG ships several server CapabilityStatements: pick one)
raco fhir-server serve-ig hl7.fhir.us.cqfmeasures-5.0.0.tgz --capability measure-calculation-service-example \
     --load measures/ --load patients/ --tz-offset -07:00 --no-examples
curl 'localhost:8080/Measure/<id>/$evaluate-measure?periodStart=2021-01-01&periodEnd=2021-12-31&subject=Patient/p1'
curl 'localhost:8080/Measure/$evaluate-measure?measure=<canonical>&periodStart=2021-01-01&periodEnd=2021-12-31'

# without a server
raco fhir-server load store.db measures/          # Bundles, resources, and .cql files (become Library resources)
raco fhir-server evaluate-measure store.db <Measure id|url> --period-start 2021-01-01 --period-end 2021-12-31 \
     [--subject Patient/p1] [--tz-offset -07:00]
```
The Measure's Library (by url, or by name = the canonical's last segment), its includes, value sets
(stored ValueSets with expansions, then the IG/core packages) and each patient's data come from the
store. With `subject`: an individual MeasureReport; without: a summary over every stored Patient with
the proportion score. Data can also arrive as a transaction Bundle (`POST /`). Library:
`fhir/store/measure` (`evaluate-measure`), `fhir/store/load` (`load-files!`, `cql->library`); running a
CQL library over a folder of FHIR JSON without a store: `raco cql lib.cql --data dir --valuesets dir`.

## Serve FHIR operations

The operations a pipeline applies (`fhir/operation`) serve over HTTP unchanged, and `/metadata` is
derived from what is served — each operation under its own canonical, nothing advertised that is not
routed:

```racket
(require fhir/capability/operations
         (only-in fhir/conformance/operations $validate) (only-in fhir/terminology/operations $expand))
(serve-operations (list $validate $expand) #:port 8080)          ; operations only
```

In a `#lang fhir/capability` app, next to its resources:

```racket
(require (only-in fhir/conformance/operations $validate) (only-in fhir/terminology/operations))
(resource Patient #:interactions (read create))
(operation $validate)               ; a value in scope — Patient/$validate, Patient/<id>/$validate
(operation "ValueSet/$expand")      ; by reference — ValueSet gets a CapabilityStatement entry for it
```

Instance-level calls take the stored resource as the subject. `racket examples/operations-server.rkt`
serves $validate, $expand, $validate-code and $lookup. A server generated from an IG
(`raco fhir-server serve-ig`) serves every implemented operation its IG names, the same way.
