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

## What a search does not apply
A parameter the search cannot apply — a name the type does not search on, a misspelling, an
unsupported modifier, chaining (`subject.name=…`) or reverse chaining (`_has:Observation:…`) — is
left out, and the answer says so at its top: `ignored` lists each one (with the nearest name), and
`note` says the answer is the search WITHOUT them. With `strict:=true` (`query language=search
text="…" strict:=true`) such a search is refused instead. Chaining and reverse chaining
(`Patient?_has:Observation:subject:code=4548-4`) are always refused: answered without them, the
search would list every patient.
"Which patients have an HbA1c" (or have none) is a CQL question — `exists [Observation: …]`, or the
`"No HbA1c"` define of `raco fhir guide cql --block LatestA1c` — or SQL over a view.
