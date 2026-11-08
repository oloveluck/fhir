# FHIR Shorthand (FSH) in the workspace

FSH is how you say what valid FHIR data looks like: profiles, extensions, value sets, code systems,
and example instances. All the workspace's `.fsh` files compile as one project, using the canonical,
FHIR version and packages in `workspace.yaml`. Every example is validated against the profiles. A
problem is reported at the rule that caused it.

## Official references
- FHIR Shorthand specification: https://hl7.org/fhir/uv/shorthand/
- Language reference: https://hl7.org/fhir/uv/shorthand/reference.html
- FSH School (tutorials, SUSHI): https://fshschool.org/docs/

## Cheat sheet
```
Alias: $loinc = http://loinc.org             # a name for a url

Profile: BloodPressurePanel                  # constrain a resource
Parent: Observation
Id: bp-panel
Title: "Blood pressure panel"
* status = #final                            # fixed value (patternCode)
* code = $loinc#85354-9                      # system#code
* subject 1..1 MS                            # cardinality, must-support
* subject only Reference(Patient)            # narrow a type
* component 2..*
* category from http://hl7.org/fhir/ValueSet/observation-category (required)   # binding
* obeys bp-1                                 # an invariant

Invariant: bp-1
Description: "A panel has a value or its components"
Expression: "value.exists() or component.exists()"
Severity: #error

Instance: bp-example                         # an example, validated against its profile
InstanceOf: BloodPressurePanel
* status = #final
* code = $loinc#85354-9
* subject = Reference(Patient/example)

ValueSet: HbA1cTests
Id: hba1c-tests
* $loinc#4548-4 "Hemoglobin A1c/Hemoglobin.total in Blood"
* include codes from system http://snomed.info/sct where concept is-a #44054006
```
Paths are element names from the parent (`component.code`, `value[x]`, `valueQuantity`). `[+]` and
`[=]` index repeating elements in instances. A slice is `component[systolic]`.

## Worked example
```fsh
Alias: $loinc = http://loinc.org

Profile: HbA1cObservation
Parent: Observation
Id: hba1c-observation
* status = #final
* code = $loinc#4548-4
* subject 1..1
* value[x] only Quantity

Instance: hba1c-example
InstanceOf: HbA1cObservation
* status = #final
* code = $loinc#4548-4
* subject = Reference(Patient/example)
* valueQuantity = 7.2 '%'
```

## Common problems
- "`nmae` is not an element of Patient": a misspelled path. `describe("Patient")` lists the elements.
- An example fails `status = final`: the example contradicts a fixed value in its profile.
- `Parent` not found: the profile you extend is in a package that is not in `packages`.
- Two files define the same canonical differently: give one of them another `Id`.
