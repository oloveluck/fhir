---
name: fhir-cli
description: Command-line reference for this repo — `raco fhir` (regenerate/check the R4/R5/R6 towers, roundtrip JSON, snapshots, the round-trip suite), `raco fhir-validate` (validate resources against profiles; the terminology suite), and where the language and server commands live. Use when running the CLI or the conformance harnesses.
---

# Command reference

Every command prints usage with `-h`/`--help` (exit 0); a usage error, unknown option or missing file
exits 2 with one line on stderr; a validation or language error exits 1.

## `raco fhir` — the foundation (package `fhir`, `fhir/cli.rkt`)

| command | what it does |
|---|---|
| `raco fhir regen [r6\|r4\|r5\|all]` | regenerate a tower from the vendored spec `.tgz` |
| `raco fhir check [r6\|r4\|r5\|all]` | regenerate purely and byte-diff vs disk (CI determinism guard) |
| `raco fhir roundtrip <file.json> [Type]` | parse FHIR JSON → typed node → re-serialize |
| `raco fhir roundtrip-tck [r4\|r5]` | round-trip the HL7 examples + the whole core package |
| `raco fhir snapshot <sd.json>` | generate a StructureDefinition snapshot |

Generated files (`r4/ r5/ r6/`) carry a `DO NOT EDIT` banner — never hand-edit; run `regen`. Targets
are defined in `fhir/codegen/target.rkt` (an IG can be a target too: whitelist + delegate base).

## `raco fhir-validate` — validation (package `fhir-validation`)

| command | what it does |
|---|---|
| `raco fhir-validate <resource.json> [profile.json…] [--package <name\|file.tgz>]… [--format outcome\|text\|json] [--fhir-version 4.0.1\|5.0.0\|6.0.0]` | validate against the base type, the supplied profiles and those in `meta.profile` → OperationOutcome (exit 1 on error). `--package hl7.fhir.us.core-6.1.0` puts a guide and what it depends on in context, so a claimed profile is found; one found nowhere is a WARNING saying the resource was not checked against it (read the warnings before trusting a clean answer). The version: the one asked for, else the resource's own (`fhirVersion`), else the first package's, else R5 |
| `raco fhir-tx tck` | the hl7.fhir.uv.tx-ecosystem terminology suite (473/553) |

For a whole FSH project use `raco fsh check <dir>` (fhir-authoring skill): it validates every example
against the project's own profiles and positions each problem in the FSH.

## Conformance suites (every floor only rises)

| command | suite | current |
|---|---|---|
| `raco fhirpath --tck r5\|r4` | HL7 FHIRPath | 1044/1044 (R5), 932/934 (R4) |
| `raco fhirpath --ucum-tck` | UCUM functional tests | 573/573 |
| `raco cql --tck` | cqframework/cql-tests | 1820/1823 |
| `raco fml --tck` | fhir-test-cases structure-mapping | 6/6 exec, 15/15 parse |
| `raco fhir-tx tck` | hl7.fhir.uv.tx-ecosystem | 473/553 |
| `raco fhir roundtrip-tck r5\|r4` | HL7 examples + core packages | R5 2968+77, R4 4581+72 |

## Standalone executables (`build-tools.sh`, repo root)
`./build-tools.sh dist` builds every installed tool (`fsh cql fml vcl fhirpath sql-on-fhir fhir
fhir-validate fhir-tx fhir-server fhir-lsp fhir-mcp`) into `dist/bin`, runnable without Racket; packages
go to `dist/share/fhir-packages`, more are found through `FHIR_PACKAGE_PATH`. The commands are the
`raco` ones without the prefix (`fsh check ig/`); `--tck`, `regen`/`check`/`fetch` and loading a `.rkt`
file stay `raco`-only.

## Elsewhere

The languages ship their own commands: `raco fsh <dir|file>`, `raco fsh check <dir>`,
`raco fsh --decompile <file.json>`, `raco cql <file.cql>`, `raco vcl '<expr>'`, `raco fml <file.map>`,
`raco fhirpath '<expr>' [resource.json]` — see **fhir-authoring**. Servers: `raco fhir-server
serve-ig|serve|load|evaluate-measure` — see **fhir-serving**. The benchmark: `raco spec-bench`
(fhir-examples repo).

## Tests

```sh
raco test -p fhir fhir-spec fhirpath vcl fhir-validation cql fml fsh fhir-server fhir-examples
```
