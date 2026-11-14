# FHIR search in the workspace

`query("search", "Type?name=value&…")` runs a FHIR search over the data. On a FHIR server the server
answers it. When the data is files, the first search indexes them by the search parameters of the
workspace's packages (FHIR core, then its IGs) and answers from that index, which is rebuilt when the
data changes.

The answer is a page: one row per resource, saying what it holds — `code`, `value`, `effective` (or
the type's own date), `status`, `subject`, `encounter` — and `total`, how many resources match in
all. The resources' JSON is kept in the result (`describe ref=result://rN`). A page is `_count`
resources (1,000 when the search names none) from `_offset`; `next` gives the search for the page
after. `_summary=count` answers the total alone.

## Before searching data you do not know
- `describe ref=data`: the resource types and how many of each.
- `describe ref=data/Observation`: for each search parameter, what the data holds — a code's
  commonest values with what they are called, a reference's targets, a date's span, a quantity's
  units — and which elements the resources carry (a choice's members by their JSON names).
- `query language=find text="hemoglobin"`: where the words occur — codes called so (a Coding's
  display, a concept's text), code and identifier values, names — each with how many resources and
  the search that finds them.
- `describe ref=Patient/<id> as=summary`: how many resources of each type name the patient, and
  the latest encounters.

## Official reference
- FHIR search: https://hl7.org/fhir/search.html

## Cheat sheet
```
Patient?family=smith&birthdate=ge1960-01-01
Observation?code=http://loinc.org|4548-4&date=ge2025-01-01
Observation?subject=Patient/123&_sort=-date&_count=10
Condition?patient=Patient/123&clinical-status=active
Encounter?date=ge2025-01-01&date=lt2026-01-01
Observation?code:text=hemoglobin&_summary=count
```
A token is `system|code`, a reference is `Type/id`, and dates take the prefixes eq, ne, gt, lt, ge,
le, sa, eb and ap. A comma means or, and repeating a parameter means and. A token's `:text` matches
what a code is called — the words anywhere in a Coding's display or its concept's text, any case.

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

## Counting and joining with SQL
On a store, `query language=sql` also has the search indexes as tables: `refs` (type, id, param,
target_type, target_id), `tokens` (type, id, param, system, code), `dates` (type, id, param, low,
high), `quantities`, `numbers`, `strings`, and `token_text` (what each code is called). A filter on
them is a lookup; a filter on the JSON (`resource ->> '$.subject.reference' = …`) reads every
resource of the type.
```sql
-- obs-per-encounter
SELECT target_id AS encounter, COUNT(*) AS observations
FROM refs WHERE type = 'Observation' AND param = 'encounter'
GROUP BY target_id ORDER BY observations DESC LIMIT 5
```
