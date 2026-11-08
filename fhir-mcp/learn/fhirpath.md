# FHIRPath in the workspace

FHIRPath navigates and tests the inside of a resource: "the official name's given names", "is any
component's value over 140". A `.fhirpath` file holds one expression. `run` evaluates it over every
resource of the type it starts with (`Patient.name.given` reads every Patient), or over `over`.
`explain` gives the value of each part of the expression for one resource.

## Official references
- FHIRPath (normative): http://hl7.org/fhirpath/N1
- FHIR's use of FHIRPath (additional functions, `resolve()`, `%resource`): https://hl7.org/fhir/fhirpath.html

## Cheat sheet
```
Patient.name.where(use = 'official').given.first()
Observation.component.where(code.coding.code = '8480-6').value.ofType(Quantity).value > 140
Condition.code.coding.exists(system = 'http://snomed.info/sct')
Patient.birthDate < @1960-01-01
MedicationRequest.dosageInstruction.count()
Observation.value.ofType(Quantity).value
Encounter.period.start.toString().substring(0, 4)
```
Every value is a collection, and an empty collection is "nothing". `where`, `exists`, `all`,
`select`, `first`, `count`, `ofType`, `is` and `as` are the workhorses. `value` is a choice, so read
`value.ofType(Quantity)`, not `valueQuantity`. Strings use single quotes; dates start with `@`.

## Worked example
```fhirpath
Observation.where(code.coding.code = '85354-9').component.where(code.coding.code = '8480-6').value.ofType(Quantity).value
```

## Common problems
- Empty where you expected a value: explain it. The part where the value disappears shows which
  step reads the wrong element.
- `say which resources the expression reads`: start the expression with a type, or pass `over`.
