# Clinical Quality Language (CQL) in the workspace

CQL states facts about a patient: "had an HbA1c test this year", "is in the denominator". A library
compiles to ELM. `run` evaluates every define for every patient in the data and answers a row per
patient. `explain` follows one patient's answer down through the defines it uses to the retrieves
that read data. That shows how many resources of a type the patient has, and which ones the filter
kept.

Here the FHIR model is 4.0.1, so write `using FHIR version '4.0.1'`. `include FHIRHelpers version
'4.0.1'` is always available. Other libraries resolve from the workspace's `.cql` files by name.
Value sets resolve by canonical from the workspace (a `.vcl` file, an FSH ValueSet), then from the
data, then from the packages. Parameters are CQL expressions, set in `workspace.yaml` or on the run.

## Official references
- The CQL specification: https://cql.hl7.org/
- Author's guide: https://cql.hl7.org/02-authorsguide.html
- Developer's guide (the full language): https://cql.hl7.org/03-developersguide.html
- Operator and function reference: https://cql.hl7.org/09-b-cqlreference.html
- ELM, the logical specification: https://cql.hl7.org/04-logicalspecification.html
- Using CQL with FHIR (IG): https://hl7.org/fhir/uv/cql/

## Cheat sheet
```
library Screening version '1.0'
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers
valueset "HbA1c": 'http://example.org/fhir/ValueSet/hba1c'
parameter "Measurement Period" Interval<DateTime>
context Patient

define "Tests": [Observation: "HbA1c"]                      // a retrieve: type and value set
define "Tests This Year":
  "Tests" O where O.effective during "Measurement Period"   // a query
define "Has Test": exists "Tests This Year"
define "Adult": AgeInYears() >= 18
define "Gap": "Adult" and not "Has Test"
define "Last Value":
  Last("Tests" O sort by effective).value as Quantity
```
Strings use single quotes, and names with spaces use double quotes. `and`, `or` and `not` are
three-valued, so null is not false. `exists` tests a list. `First`, `Last`, `Count` and `Sum`
aggregate. Timing phrases include `during`, `before`, `3 days or less before` and `overlaps`.

## Worked example
```cql
library HbA1cGap version '1'
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers
codesystem "LOINC": 'http://loinc.org'
code "HbA1c code": '4548-4' from "LOINC"
context Patient
define "Tests": [Observation: "HbA1c code"]
define "No HbA1c": not exists "Tests"
define "Gap": AgeInYears() >= 18 and "No HbA1c"
```
`query("cql", "AgeInYears() > 65")` evaluates one expression for every patient without a library.

## Common problems
- An unknown value set at run time: no ValueSet with that url is in the workspace, the data or the
  packages. Write a `.vcl` file for it, and use its canonical.
- `Could not resolve ... FHIRHelpers`: add `include FHIRHelpers version '4.0.1' called FHIRHelpers`.
- A define is null when you expected false: an operand was null. Explain it for that patient.
- A comparison of a FHIR element with a System value fails to translate: include FHIRHelpers, which
  supplies the conversions.
