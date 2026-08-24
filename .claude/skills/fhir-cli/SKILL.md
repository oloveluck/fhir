---
name: fhir-cli
description: The `raco fhir` command-line reference for this repo — regenerate/check the R4/R5/R6 + IG type towers, run the conformance suites (fhirpath-tck, cql-tck, sof-tck, fml-tck, ucum-tck, tx-tck, roundtrip-tck), validate/snapshot resources, and roundtrip JSON. Use when running the CLI or the conformance harnesses.
---

# `raco fhir` command reference

The CLI lives in `cli/`. All commands run from the repo root.

## Codegen (the type towers)

| command | what it does |
|---|---|
| `raco fhir regen [r6\|r4\|all\|<ig>]` | regenerate a tower from the vendored spec `.tgz` |
| `raco fhir check [r6\|r4\|all\|<ig>]` | regenerate purely and byte-diff vs disk (CI determinism guard) |

Generated files (`r4/ r5/ r6/`, IG towers) carry a `DO NOT EDIT` banner — never hand-edit; run
`regen`. IG targets (`sof`, `omop`, …) are defined in `codegen/target.rkt`.

## Conformance suites (every floor only rises)

| command | suite | current |
|---|---|---|
| `raco fhir fhirpath-tck r5\|r4` | HL7 FHIRPath | 1044/1044 (R5), 932/934 (R4) |
| `raco fhir cql-tck` | cqframework/cql-tests | 1819/1823 |
| `raco fhir sof-tck` | SQL-on-FHIR shared suite | 133/133 |
| `raco fhir fml-tck` | fhir-test-cases structure-mapping | 6/6 exec, 15/15 parse |
| `raco fhir ucum-tck` | UCUM functional tests | 573/573 |
| `raco fhir tx-tck` | hl7.fhir.uv.tx-ecosystem | 463/553 |
| `raco fhir roundtrip-tck r5\|r4` | HL7 examples + core packages | ~7,700 resources |

## Resources: roundtrip / validate / snapshot

| command | what it does |
|---|---|
| `raco fhir roundtrip <file.json> <Type>` | parse FHIR JSON → typed node → re-serialize |
| `raco fhir validate <resource.json> [profile.json…]` | validate → OperationOutcome (exit 1 on error) |
| `raco fhir snapshot <sd.json>` | generate a StructureDefinition snapshot |

## Language CLIs

`raco fhir fsh <dir>`, `raco fhir gofsh <file.json>`, `raco fhir cql <file.cql>`,
`raco fhir vcl <expr>` — see the **fhir-authoring** skill. `raco fhir serve` / `raco fhir load` /
`raco fhir omop` — see **fhir-serving** and **fhir-analytics**.

## Unit tests

```sh
raco test result/ model/ primitives/ kernel/ lang-gen/ serialize/ codegen/ terminology/ \
          capability/ http/ fsh/ cql/ tests/
```
