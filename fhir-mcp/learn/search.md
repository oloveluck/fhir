# FHIR search in the workspace

`query("search", "Type?name=value&…")` runs a FHIR search when the data is a FHIR server. A directory
or file of JSON has no search engine, so use a FHIRPath query instead
(`query("fhirpath", "Observation.where(code.coding.code = '4548-4')")`).

## Official reference
- FHIR search: https://hl7.org/fhir/search.html

## Cheat sheet
```
Patient?family=smith&birthdate=ge1960-01-01
Observation?code=http://loinc.org|4548-4&date=ge2025-01-01
Observation?subject=Patient/123&_sort=-date&_count=10
Condition?patient=Patient/123&clinical-status=active
Encounter?date=ge2025-01-01&date=lt2026-01-01
```
A token is `system|code`, a reference is `Type/id`, and dates take the prefixes eq, ne, gt, lt, ge,
le, sa, eb and ap. A comma means or, and repeating a parameter means and.
