# SQL on FHIR ViewDefinitions in the workspace

A ViewDefinition flattens resources into a table: one row per resource (or per repeating element),
one column per FHIRPath. Write it as JSON in a `*.view.json` file. `run` answers its rows over the
data, and `explain` shows what one resource contributes and whether each `where` holds for it. Use it
for tables and counts across a population.

## Official references
- SQL on FHIR: https://sql-on-fhir.org
- The specification (ViewDefinition, the operations): https://build.fhir.org/ig/FHIR/sql-on-fhir-v2/

## Cheat sheet
```
{
  "resourceType": "ViewDefinition",
  "name": "bp_readings",
  "status": "active",
  "resource": "Observation",
  "where": [{"path": "code.coding.exists(system = 'http://loinc.org' and code = '85354-9')"}],
  "select": [
    {"column": [
      {"name": "id", "path": "getResourceKey()"},
      {"name": "patient", "path": "subject.getReferenceKey(Patient)"},
      {"name": "date", "path": "effective.ofType(dateTime)"}]},
    {"forEach": "component", "column": [
      {"name": "code", "path": "code.coding.code.first()"},
      {"name": "value", "path": "value.ofType(Quantity).value"}]}
  ]
}
```
`forEach` makes a row per item (`forEachOrNull` keeps resources without any), `unionAll` stacks
selects, and `constant` names values the paths use as `%name`. A column's path must give one value
per row, unless the column is `"collection": true`.

## Worked example
```view
{"resourceType": "ViewDefinition", "name": "patients", "status": "active", "resource": "Patient",
 "select": [{"column": [{"name": "id", "path": "getResourceKey()"},
                        {"name": "gender", "path": "gender"},
                        {"name": "birth_date", "path": "birthDate"}]}]}
```
