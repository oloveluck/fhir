# Reading a FHIR store

`raco fhir-mcp call <verb> key=value …` in the workspace's directory. Answers are JSON; text answers (FSH, CSV) are printed as they are.

A question is asked at a time: the current time it names. Three things follow from that, each a common wrong answer:
- "This visit", "the current stay", "this encounter" mean an encounter open at that time, and only that. `describe ref=Patient/<id> as=summary asof="<the current time>"` says in `asof` which were open. When it says NO encounter was open, the answer is "none", not a value from an earlier stay. When the question names no time, leave `asof` out and read `current`.
- Nothing dated after the current time has happened: end every search there, `date=le<the current time>`. A record dated later is not an answer.
- "Today", "this month", "this year" ask about that day, month or year only: `date=<YYYY-MM-DD>`, `date=<YYYY-MM>`, `date=<YYYY>`. A date with no time zone is the day as each record wrote it.

- What a type holds: `describe ref=data/<Type>` — its codes with their names, its kinds (`_profile`: a lab result, a chart event and a microbiology test are all Observations), what its references point at, its dates.
- A patient: `describe ref=Patient/<id> as=summary` — how many resources of each type, the latest encounters, and in `current` which encounter is still open (or that none is).
- Words to codes: `query language=find text="<words>"` — where they occur, and the search that finds them.
- Search, standard FHIR: `query language=search text="<Type>?patient=Patient/<id>&<param>=<value>&_sort=-date&_count=50"`. `date=ge<YYYY-MM-DD>`, `code:text=<words>`, `_profile=<url>`, a chain through a reference (`medication.identifier=Heparin`), `_summary=count` for a count, `_include`.
- A search's rows: one per resource. Cells every row shares are said once, under `every`. A Quantity's number is `value`, its unit `unit`. A reference to another resource carries its name in parentheses; `specimen` is what was sampled (`Blood`, `PERITONEAL FLUID`). A prescription's `validityPeriod` (when it is to be given) comes before `authoredOn` (when it was written).
- Whole resources, shorter than JSON: `describe ref=<Type>/<id> as=fsh`, or a search's page `describe ref=result://<n> as=fsh` (FHIR Shorthand: `* code = $loinc#4548-4 "Hemoglobin A1c"`). As a table: `as=csv`.
- SQL: `query language=sql text="SELECT …"` over an earlier result by its name (`SELECT count(*), sum(value) FROM r2 WHERE effective >= '2125-03-05'`: filter, count and add up a search's rows in one call) and over the search indexes (tables `refs`, `tokens`, `dates`, `quantities`, `strings`).
- Writing a resource: an FSH Instance (`Instance: x` / `InstanceOf: Observation` / `* status = #final` …), checked with `stage fsh=@file.fsh keep:=false`. Changing a stored one: only the rules that change, under `Instance: Observation/<id>` with no `InstanceOf` (`* status = #amended`, `* note[+].text = "…"`).

The full guide: `raco fhir guide workspace`. FHIR search: https://hl7.org/fhir/R4/search.html
