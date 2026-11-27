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
| IG validation (US Core, IPS, CRMI) | every example validates against the IG profiles it claims, with no false error | 330/330 clean (216 + 44 + 70) |
| Validator differential (fhir-test-cases validator, with the Java validator's recorded outcomes) | each case's verdict against the reference's | no false positives; 22 of 26 invalid cases caught |
| Validator against HL7's, on changed examples (six US Core 9.0.0 profiles: 28 published examples and 713 copies with one change each, judged by HL7's Java validator; `fhir-examples/value-experiment/verify/profile-cases.rkt`) | each resource's verdict against HL7's | 740 of 741 the same; none refused that HL7's passes (659 before the misses on the sample cases were fixed). The next six profiles, 3,145 cases: 3,111 the same and 5 refused that HL7's passes, all one cause (a best practice rule reported as an error); after it 3,116, none refused; the 29 passes read (three causes, fixed): 3,145 |
| Invariants over the R5 core package | no error-level invariant violation on a valid resource | 2957/2968; the 11 are the package's own (sdf-27, scs-1) |
| IG FHIRPath (US Core, IPS) | profile invariants on their examples; SearchParameter expressions | 6082 invariant checks pass and none fail (3 warnings; 2 dom-3 errors, from a multi-item `as()` the FHIRPath spec makes an error); 1330/1330 search expressions |
| Snapshot generation (fhir-test-cases) | generated snapshots against the expected ones, element by element | paths 80/80, cardinality 476/478, types 235/236 |
| Terminology (hl7.fhir.uv.tx-ecosystem 1.9.3) | `$expand`, `$validate-code`, `$lookup` and others against the suite's expected responses, refusals (an OperationOutcome where one is expected) included | 600/600 (320 more skipped, each with its reason under `-v`: the suites written for SNOMED CT, LOINC, OMOP and HGVS content, which is not shipped; tx.fhir.org's `$related` and `$batch-validate`; three expansions of UCUM by rule) |
| IG search (US Core 9.0.0) | each example found by searching on its own values | 2468/2468 probes |
| IG server (US Core 9.0.0) | a server generated from the IG meets its CapabilityStatement | 0 unmet requirements |
| FSH → package → server (mCODE 4.0.0) | mCODE compiled from its FSH, packed, served; its examples against its profiles | 283/283 validate; 0 unmet requirements |
| Measure server (CQF Measures 5.0.0) | `$evaluate-measure` per patient over two eCQMs | 60/65 (the 5 are named in the test) |
| MCP workspace (`fhir-mcp/tests/workspace-test.rkt`) | the nine tools end to end over a workspace of every language and a data directory; every worked example in `learn://` compiles | passes (`fhir/rest-data-source`'s FHIR-server data source has its own test against a stub server) |

## The misses, named

- **Validator, 4 invalid cases not caught**: two are the `ctm-1` CareTeam cases, which the Java
  validator flags only through a non-spec reading of `is` on an empty collection (matching it would
  break FHIRPath conformance); one needs LOINC's codes and properties (a supplement); one's only
  error is that the reference could not load an R5 extension definition.
- **Validator against HL7's on changed examples, 1 of 741**: an NPI identifier with no value, where
  the NPI rule comes out empty (held here, failed there). On the fresh set, 5 QuestionnaireResponses
  are refused that HL7's validator passes: the next thing to open.
- **Terminology, 320 skipped**: each with its reason under `raco fhir-tx tck -v` (content not
  shipped: SNOMED CT, LOINC, OMOP, HGVS; candidate operations).
- **Invariants, 11**: ten logical models in the core package with a baseDefinition and no
  `derivation` (sdf-27), and CodeSystem/fhir-types against the profile it claims (scs-1).
- **Snapshots, 3**: version-induced. `prov-fi` is an R4 profile, and the resolver reads R5 bases.
- **Measure server, 5**: two cases whose resources reference a bare id or a sibling patient, which a
  server rightly leaves out of the patient's data, and the three corpus disagreements `cql` documents.

## Speed

Measured, not gated: `fhir-server/bench/store-bench.rkt` loads a bulk export and asks a fixed set
of questions of the store, the same way each time. The numbers below are on the MIMIC-IV Clinical
Database Demo on FHIR 2.1.0 (PhysioNet; 30 files, 928,935 resources, 813,540 of them Observations),
on a four-core machine with nothing else running. "Before" is this repository at commit 5a9d601
(2026-11-13, before the work the benchmark prompted), checked out and measured on the same machine
as "now": timings from different machines, or different days on a shared one, are not comparable.

| | Before | Now |
|---|---|---|
| `raco fhir-server load`, the whole dataset | not finished in 30 minutes | 3 min 19 s (4,674 resources a second) |
| …a 61,396-resource sample of it | 102.2 s | 13.1 s |
| a patient's observations, the first 10 of 48,554 | 272 ms | 39 ms |
| …of one code (1,362 resources returned) | 214 ms | 172 ms |
| …from a date on, sorted by date, the first 10 | 3,598 ms | 289 ms |
| a patient's latest observation | 339 ms | 140 ms |
| every observation of one code, counted (19,330) | 58 ms | 9 ms |
| SQL over raw JSON: a patient's observations by `subject.reference` | 2.0 s | 2.0 s (56 ms through the reference index) |

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
