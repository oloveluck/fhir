#lang fhir/fsh
// patient.fsh — author FHIR conformance resources in #lang fhir/fsh.
// Run `racket examples/patient.fsh` to compile these to FHIR JSON (the SUSHI-style output).

Alias: $sct = http://snomed.info/sct

Profile: MyPatient
Parent: Patient
Id: my-patient
Title: "My Patient"
Description: "A patient with a required name and a fixed gender constraint."
* name 1..*
* name.family 1..1
* gender 0..1
* maritalStatus from http://hl7.org/fhir/ValueSet/marital-status (required)
* obeys mp-1

Invariant: mp-1
Description: "A patient must have a name or an identifier"
Severity: #error
Expression: "name.exists() or identifier.exists()"

ValueSet: FavoriteColors
Id: favorite-colors
Title: "Favorite Colors"
* http://example.org/colors#red "Red"
* http://example.org/colors#green "Green"
* http://example.org/colors#blue "Blue"

Instance: ExamplePatient
InstanceOf: MyPatient
Usage: #example
* name.family = "Chalmers"
* name.given = "Peter"
* gender = #male
