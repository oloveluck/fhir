# fhir

FHIR for Racket: a typed FHIR model with R4, R5 and R6 generated from the HL7 specifications, a
validator and terminology service, and servers generated from Implementation Guides.

```racket
#lang fhir/r6
(Patient
 (id "example") (active #t) (gender "male") (birthDate "1974-12-25")
 (name (HumanName (family "Chalmers") (given "Peter" "James"))))
```

`racket patient.fhir6` prints the FHIR JSON. `(birthDate "1974-13-40")`, `(notAField "x")` or
`(gender "florp")` fail to compile.

## Packages

| package | what |
|---|---|
| `fhir/` | the model, primitives and JSON; `#lang fhir/r4`, `fhir/r5`, `fhir/r6`; `#lang fhir/sd` and snapshot generation; codegen from StructureDefinitions; FHIR operations as procedures (`fhir/operation`); `raco fhir` |
| `fhir-spec/` | the vendored HL7 packages: core R4/R5/R6 and the IGs the tests use |
| `fhir-validation/` | the validator (cardinality, types, slicing, bindings, invariants) and the terminology service; `raco fhir-validate` |
| `fhir-server/` | FHIR REST servers, generated from an IG or declared in `#lang fhir/capability`, over a SQLite store; `raco fhir-server` |

```sh
raco fhir-validate resource.json [profile.json…]        # an OperationOutcome on stdout
raco fhir-server serve-ig hl7.fhir.us.core --port 8080  # a server generated from US Core
```

## Install

From source, with [fhirpath](https://github.com/oloveluck/fhirpath), [vcl](https://github.com/oloveluck/vcl)
and [cql](https://github.com/oloveluck/cql) checked out alongside (the validator and server use them):

```sh
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-validation cql fhir/fhir-server
```

Architecture notes: `CLAUDE.md`.
