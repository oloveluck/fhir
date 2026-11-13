# Testing fhir

Every suite is vendored with its source and license (a `SOURCE.txt` beside it) and gated by a floor
that only rises. The languages' own suites are in their repositories: [fsh](https://github.com/oloveluck/fsh/blob/main/TESTING.md),
[cql](https://github.com/oloveluck/cql/blob/main/TESTING.md), [fml](https://github.com/oloveluck/fml/blob/main/TESTING.md),
[vcl](https://github.com/oloveluck/vcl/blob/main/TESTING.md), [fhirpath](https://github.com/oloveluck/fhirpath/blob/main/TESTING.md),
[sql-on-fhir](https://github.com/oloveluck/sql-on-fhir/blob/main/TESTING.md).

## Results

| Suite | What it checks | Result |
|---|---|---|
| Round-trip, R5 and R4 core packages | every resource parses into the typed model and serialises back unchanged | R5 2968/2968 and 77 test-case examples; R4 4581/4581 and 72 |
| IG examples (US Core 9.0.0, IPS 2.0.1) | every published example parses and round-trips | 274/274 |
| IG validation (US Core, IPS) | every example validates against the IG profiles it claims, with no false error | 260/260 clean (216 + 44) |
| Validator differential (fhir-test-cases validator, with the Java validator's recorded outcomes) | each case's verdict against the reference's | no false positives; 18 of 26 invalid cases caught |
| Invariants over the R5 core package | no error-level invariant violation on a valid resource | 2957/2968; the 11 are the package's own (sdf-27, scs-1) |
| IG FHIRPath (US Core, IPS) | profile invariants on their examples; SearchParameter expressions | 6082 invariant checks pass and none fail (3 warnings; 2 dom-3 errors, from a multi-item `as()` the FHIRPath spec makes an error); 1330/1330 search expressions |
| Snapshot generation (fhir-test-cases) | generated snapshots against the expected ones, element by element | paths 80/80, cardinality 476/478, types 235/236 |
| Terminology (hl7.fhir.uv.tx-ecosystem 1.9.3) | `$expand`, `$validate-code`, `$lookup` and others against the suite's expected responses | 473/553 (367 more skipped: external terminologies and code systems not available offline) |
| IG search (US Core 9.0.0) | each example found by searching on its own values | 2468/2468 probes |
| IG server (US Core 9.0.0) | a server generated from the IG meets its CapabilityStatement | 0 unmet requirements |
| FSH → package → server (mCODE 4.0.0) | mCODE compiled from its FSH, packed, served; its examples against its profiles | 283/283 validate; 0 unmet requirements |
| Measure server (CQF Measures 5.0.0) | `$evaluate-measure` per patient over two eCQMs | 60/65 (the 5 are named in the test) |
| MCP workspace (`fhir-mcp/tests/workspace-test.rkt`) | the nine tools end to end over a workspace of every language and a data directory; every worked example in `learn://` compiles | passes (`fhir/rest-data-source`'s FHIR-server data source has its own test against a stub server) |

## The misses, named

- **Validator, 8 invalid cases not caught**: choice-type narrowing, invariants, and decimal-format
  edges. Two are the `ctm-1` CareTeam cases, which the Java validator flags only through a non-spec
  reading of `is` on an empty collection; matching it would break FHIRPath conformance.
- **Invariants, 11**: ten logical models in the core package with a baseDefinition and no
  `derivation` (sdf-27), and CodeSystem/fhir-types against the profile it claims (scs-1).
- **Snapshots, 3**: version-induced. `prov-fi` is an R4 profile, and the resolver reads R5 bases.
- **Measure server, 5**: two cases whose resources reference a bare id or a sibling patient, which a
  server rightly leaves out of the patient's data, and the three corpus disagreements `cql` documents.

## Speed

Measured, not gated: `fhir-server/bench/store-bench.rkt` loads a bulk export and asks a fixed set
of questions of the store, the same way each time. The numbers below are on the MIMIC-IV Clinical
Database Demo on FHIR 2.1.0 (PhysioNet; 30 files, 928,935 resources, 813,540 of them Observations),
on a four-core machine with nothing else running. "Before" is this repository on 2026-11-13,
before the work the benchmark prompted.

| | Before | Now |
|---|---|---|
| `raco fhir-server load`, the whole dataset | not finished in 30 minutes | 2 min 15 s (6,880 resources a second) |
| …a 61,396-resource sample of it | 95.7 s | 9.9 s |
| a patient's observations, the first 10 of 48,554 | 225 ms | 28 ms |
| …of one code (1,362 resources returned) | 177 ms | 144 ms |
| …from a date on, sorted by date, the first 10 | 3,201 ms | 222 ms |
| a patient's latest observation | 255 ms | 112 ms |
| every observation of one code, counted (19,330) | 47 ms | 7 ms |
| SQL over raw JSON: a patient's observations by `subject.reference` | 1.9 s | 1.9 s (41 ms through the reference index) |

```sh
racket fhir-server/bench/store-bench.rkt sample <ndjson-dir> sample/     # the first 4,000 lines of each file
racket fhir-server/bench/store-bench.rkt load sample/                    # read, index and load, timed apart
racket fhir-server/bench/store-bench.rkt query <store.db>                # the questions, the median of 5 runs
```

## Running them

```sh
raco test -p fhir fhir-spec fhir-tx fhir-validation fhir-server   # everything here, with the floors
raco fhir roundtrip-tck r5            # the R5 round trip (or r4)
raco fhir-tx tck                      # the terminology suite
raco fhir check all                   # the generated towers equal a fresh generation
```

The standalone tools (`build-tools.sh`) are checked by running each from a build with no Racket
collections visible; that check is manual.

One test currently fails: `fhir-server/capability/declare.rkt`'s tests still expect three values
from `parse-operation`, which returns one `parsed-operation` struct since commit 510ba5f.
