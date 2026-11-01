---
name: fhir-cli
description: The `raco fhir` command-line reference for this repo — regenerate/check the R4/R5/R6 + IG type towers, run the conformance suites (sof-tck, tx-tck, roundtrip-tck here; the language TCKs via raco fhirpath/cql/fml --tck), validate/snapshot resources, and roundtrip JSON. Use when running the CLI or the conformance harnesses.
---

# `raco fhir` command reference

The CLI lives in `cli/`. All commands run from the repo root.

## Codegen (the type towers)

| command | what it does |
|---|---|
| `raco fhir regen [r6\|r4\|all\|<ig>]` | regenerate a tower from the vendored spec `.tgz` |
| `raco fhir check [r6\|r4\|all\|<ig>]` | regenerate purely and byte-diff vs disk (CI determinism guard) |

Generated files (`r4/ r5/ r6/` in the `fhir` repo, IG towers `viewdef/ omop/` here) carry a
`DO NOT EDIT` banner — never hand-edit; run `regen`. IG targets (`sof`, `omop`, …) are defined in
`fhir`'s `codegen/target.rkt`; regen writes into whichever linked package holds the tower.

## Conformance suites (every floor only rises)

| command | suite | current |
|---|---|---|
| `raco fhirpath --tck r5\|r4` | HL7 FHIRPath | 1044/1044 (R5), 932/934 (R4) |
| `raco cql --tck` | cqframework/cql-tests | 1819/1823 |
| `raco fhir sof-tck` | SQL-on-FHIR shared suite | 133/133 |
| `raco fml --tck` | fhir-test-cases structure-mapping | 6/6 exec, 15/15 parse |
| `raco fhirpath --ucum-tck` | UCUM functional tests | 573/573 |
| `raco fhir tx-tck` | hl7.fhir.uv.tx-ecosystem | 463/553 |
| `raco fhir roundtrip-tck r5\|r4` | HL7 examples + core packages | ~7,700 resources |

## Resources: roundtrip / validate / snapshot

| command | what it does |
|---|---|
| `raco fhir roundtrip <file.json> <Type>` | parse FHIR JSON → typed node → re-serialize |
| `raco fhir validate <resource.json> [profile.json…]` | validate → OperationOutcome (exit 1 on error) |
| `raco fhir snapshot <sd.json>` | generate a StructureDefinition snapshot |

## Language CLIs

The languages ship their own commands (each package's `cli.rkt`): `raco fsh <dir|file> [--snapshot]`,
`raco fsh --decompile <file.json>`, `raco cql <file.cql>`, `raco vcl '<expr>'`, `raco fml <file.map>
[--transform <src.json>]`, `raco fhirpath '<expr>' [resource.json]` — see the **fhir-authoring** skill. `raco fhir serve` / `raco fhir load` /
`raco fhir omop` — see **fhir-serving** and **fhir-analytics**.

## Unit tests

```sh
raco test -p fhir fhir-spec fhirpath vcl cql fml fsh      # foundation + languages (linked packages)
(cd fhir-tools && raco test terminology/ capability/ http/ conformance/ viewdef/ tests/)  # store/ omop/ need libduckdb
```
