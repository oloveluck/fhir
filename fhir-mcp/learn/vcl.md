# ValueSet Compose Language (VCL) in the workspace

VCL writes a value set in one line. A `.vcl` file defines the ValueSet
`<canonical>/ValueSet/<file name>`, and CQL libraries, FSH bindings and validation see it by that
url. `run` expands it with the terminology service, using the code systems in the packages and the
workspace. `explain` says which part of the expression admits or excludes a code.

## Official reference
- VCL specification: https://build.fhir.org/ig/FHIR/ig-guidance/vcl.html

## Cheat sheet
```
(http://loinc.org)(4548-4; 17856-6)                     two codes from LOINC
(http://snomed.info/sct)concept<<73211009               a concept and its descendants
(http://snomed.info/sct)concept<73211009                descendants only
(http://loinc.org)(4548-4; 17856-6) - (http://loinc.org)17856-6    exclusion
(http://loinc.org)*                                     every code of a system
^http://hl7.org/fhir/ValueSet/administrative-gender     another value set
(http://loinc.org)(COMPONENT="Hemoglobin A1c")          a property filter
```
`;` is or and `,` is and; there is no precedence between them, so bracket compound parts. A system
in brackets applies to what follows.

## Worked example
```vcl
(http://loinc.org)(4548-4; 17856-6; 4549-2)
```

## Common problems
- "does not expand": a code system that is not in the packages (SNOMED CT and LOINC are not
  shipped). Enumerated codes still work as members; filters over them need the code system.
