# FHIR search in the workspace

`query("search", "Type?name=value&…")` runs a FHIR search over the data. On a FHIR server the server
answers it. When the data is files, the first search indexes them by the search parameters of the
workspace's packages (FHIR core, then its IGs) and answers from that index, which is rebuilt when the
data changes. The answer is the resources themselves, as the files hold them.

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
