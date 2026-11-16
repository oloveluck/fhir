# Reading a FHIR store

`raco fhir-mcp call <verb> key=value …` in the workspace's directory. Answers are JSON; text answers (FSH, CSV) are printed as they are.

- What a type holds: `describe ref=data/<Type>` — its codes with their names, its kinds (`_profile`: a lab result, a chart event and a microbiology test are all Observations), what its references point at, its dates.
- A patient: `describe ref=Patient/<id> as=summary asof="<the current time>"` — how many resources of each type, and the encounters begun by then: which were still `open` ("this visit", "the current stay") and how many began `later`.
- Words to codes: `query language=find text="<words>"` — where they occur, and the search that finds them.
- Search, standard FHIR: `query language=search text="<Type>?patient=Patient/<id>&<param>=<value>&_sort=-date&_count=50"`. `date=ge2116-12-01`, `code:text=<words>`, `_profile=<url>`, a chain through a reference (`medication.identifier=Heparin`), `_summary=count` for a count, `_include`.
- A search's rows: one per resource. Cells every row shares are said once, under `every`. A Quantity's number is `value`, its unit `unit`. A reference to another resource carries its name in parentheses; `specimen` is what was sampled (`Blood`, `PERITONEAL FLUID`). A prescription's `validityPeriod` (when it is to be given) comes before `authoredOn` (when it was written).
- Whole resources, shorter than JSON: `describe ref=<Type>/<id> as=fsh`, or a search's page `describe ref=result://<n> as=fsh` (FHIR Shorthand: `* code = $loinc#4548-4 "Hemoglobin A1c"`). As a table: `as=csv`.
- SQL: `query language=sql text="SELECT …"` over an earlier result by its name (`SELECT count(*), sum(value) FROM r2 WHERE effective >= '2125-03-05'`: filter, count and add up a search's rows in one call) and over the search indexes (tables `refs`, `tokens`, `dates`, `quantities`, `strings`).
- Writing a resource: an FSH Instance (`Instance: x` / `InstanceOf: Observation` / `* status = #final` …), checked with `stage fsh=@file.fsh keep:=false`. Changing a stored one: only the rules that change, under `Instance: Observation/<id>` with no `InstanceOf` (`* status = #amended`, `* note[+].text = "…"`).

The full guide: `raco fhir guide workspace`. FHIR search: https://hl7.org/fhir/R4/search.html
