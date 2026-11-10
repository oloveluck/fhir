---
name: fhir
description: "Use FHIR as a tool for health data — create resources (FSH), store them (SQLite, JSONB), search them, compute on them (FHIRPath, CQL cohorts, value sets, FML transformations), analyze them (ViewDefinitions + SQL), and build FHIR servers with their own capabilities and operations (#lang fhir/capability), through the fhir-mcp workspace or its command line. Start here for any FHIR task; it says which language does what and where each one's guide is."
---

# FHIR as a tool

One workspace holds FHIR data and the programs that work on it, in seven languages that compose by
canonical url — six to describe and compute on health data (FSH, CQL, FHIRPath, VCL, FML, SQL on
FHIR views) and one to declare FHIR servers (capability apps). Every resource is stored in SQLite,
as JSONB. The `fhir-mcp` server gives an agent nine tools over it; every problem comes back as
one line, `file:line:col severity: message`, with "did you mean …" for a misspelt name.

**Which route?**
| you are … | start with |
|---|---|
| asking questions of health data, storing it under rules, keeping its trail | this skill: the workspace (MCP tools, or `raco fhir-mcp call` from the shell) |
| writing a Racket program (an FML map, an FSH profile and a CQL library required side by side) | "A Racket program" at the end (a quickstart), then the `fhir-authoring` skill — the workspace sections are not needed |
| building a FHIR server with your own operations | "Build a FHIR server" below, and `raco fhir-mcp guide capability` |
| using one language from the command line | its own skill: `cql`, `fsh`, `fml`, `fhirpath`, `vcl`, `sql-on-fhir` |

**Which call answers which question** (each one a tested recipe):
| question | where |
|---|---|
| is the latest HbA1c above 9 %, per patient (and "never tested") | `raco fhir-mcp guide cql`, "the latest value per patient" (copy its library as `LatestA1c.cql`); the table: `run path=LatestA1c.cql as=csv columns="Name,Latest Number,Latest Date,Above 9"` |
| was any result above a threshold | a FHIR search: `query language=search text="Observation?code=…&value-quantity=gt9"`; per patient beside the latest, the CQL guide's `Ever Above 9` |
| whose mean blood pressure is at or above 140/90 | `raco fhir-mcp guide workspace`, the `bp` view and its summary SQL — read clinically as systolic ≥ 140 OR diastolic ≥ 90 |
| where did each stored value come from (who, when, why, which file and line) | `describe ref=Observation as=trail` (one resource's versions: `ref=Observation/a1/_history as=trail`) |
| what changed in a resource, version by version | `describe ref=Observation/a1/_history` |
| a rule every resource of a type must meet | "Constraints and the trail" below; the rules cookbook in `raco fhir-mcp guide workspace` |
| correct a stored value with a reason | the correction recipe in `raco fhir-mcp guide workspace` |
| a table of values to join or chart | a ViewDefinition (`raco fhir-mcp guide sql-on-fhir`), then `query language=sql` |
| a FHIR server with an operation of your own | "Build a FHIR server" below |
| a Racket program: map, validate, decide | "A Racket program" at the end |

**A Racket program, in brief** (the workspace below is not needed): `raco fhir new pipeline my-pipeline`
copies a working template (an FSH profile, an FML map, a CQL library, `main.rkt`, a sample input and
`tests.rkt`); `cd my-pipeline && raco test tests.rkt` checks it all, `racket main.rkt qr.json` runs it;
then change the files — "A Racket program" at the end and the `fhir-authoring` skill say how.

## Set up
```sh
raco fhir-mcp init my-workspace   # [--fhir-version 5.0.0]; `fhir-mcp init` once the standalone tools are on PATH
```
writes `workspace.yaml` (FHIR 4.0.1, `data: fhir.db`), a `.mcp.json` that registers the server for
Claude Code, and a `CLAUDE.md`. The data is **`fhir.db`, a SQLite FHIR store**: every resource as
JSONB with its version history and search indexes, written only through `stage` and `commit`,
searched with FHIR search, and open to SQL (`resource ->> '$.gender'`). `data:` may instead name a
directory of JSON files or a FHIR server's base url. To import JSON files:
`raco fhir-server load fhir.db <dir|bundle.json>`. Elsewhere: `claude mcp add fhir -- fhir-mcp --workspace <dir>`.
Without an MCP client, every tool runs from the shell, each call its own process; stages and results
are kept in the workspace (`.fhir-mcp/`), so one call's stage is committed by the next and a result
is described or joined in SQL later. Arguments are a JSON object and/or `key=value`, `key=@file`
(a file's text: no escaping FSH, CQL or SQL into JSON) and `key:=<json>`:

```sh
raco fhir-mcp call stage fsh=@patients.fsh --workspace ws
raco fhir-mcp call commit stage=latest reason="intake" --workspace ws        # or stage=stage-1
raco fhir-mcp call write path=Diabetes.cql text=@Diabetes.cql --workspace ws
raco fhir-mcp call run path=Diabetes.cql --workspace ws                      # result://Diabetes
raco fhir-mcp call query language=sql text=@summary.sql name=summary --workspace ws
raco fhir-mcp call describe ref=result://summary as=csv --workspace ws
```
Each call is a process of its own (1–4 s of startup): for more than two calls, prefer
`raco fhir-mcp batch calls.txt`
(or `-` for stdin) runs one call per line — `stage fsh=@patients.fsh`, `commit stage=latest
reason="intake"`, quoted as a shell would — in one process, each answer under a `### <line>`
header, every line run (exit 1 if any failed). Its `--workspace` applies to every line:
```sh
printf '%s\n' 'stage fsh=@patients.fsh' 'commit stage=latest reason="intake"' \
  'query language=sql text="SELECT count(*) AS n FROM Patient"' | raco fhir-mcp batch - --workspace ws
```

A run is named by its file and a query by its `name` (as a SQL table: letters, digits, `_`); the
name means the latest result of it, in SQL (`FROM Diabetes`) and in `result://`, in any case.
`write text=@file` copies the file into the workspace: edit the workspace's copy, or write it again.
`--workspace` defaults to the current directory. A call prints the tool's answer (JSON, or text) and exits 0; 1 when the tool failed or its answer
counts errors (`"errors": 2`: a stage that cannot be committed, a check with errors); 2 for a usage
error. `describe ref=stages` lists the stages not committed; `stage drop=stage-3` discards one
(`drop=all`, every one); a dropped stage's id is never given to a new one. A tool answering text (`describe … as=fsh`, `as=csv`, `as=source`) prints
the text itself, not a JSON string.

Keep data files like `patients.fsh` outside the workspace directory: the workspace's own `.fsh`
files are its project (profiles, value sets, a few examples), compiled and checked together, so a
patient written there and staged too is a duplicate id. The trail names the agent `raco fhir-mcp call` unless `commit … agent="intake desk"` (or `FHIR_MCP_AGENT`) names who is writing. A capability
app that `run` serves lives as long as the process that ran it: from the shell, serve it with
`raco fhir-server serve app.capability.rkt --port 8080 --store fhir.db`.
Not installed: the README's "Getting the tools" (Racket 9, then `raco pkg install` of the repositories).

Files in the workspace are its files: one you put there yourself is used as it is (`run path=…`
reads it); `write` saves a file and answers its problems in the same call, `check` answers every
file's.

## The guides
`raco fhir-mcp guide` lists them and `raco fhir-mcp guide <topic>` prints one (`raco fhir guide <topic>`
is the same, for the Racket route); an MCP client reads the
same text as `learn://<topic>`. Read `fhir` (resources, codes, quantities, references) and
`workspace` (the tools) first, then the language you write:

| Topic | For |
|---|---|
| `fhir` | which resource holds which fact; the shapes that recur; the code systems |
| `workspace` | the nine tools, workspace.yaml, which language for which question |
| `fsh` | FHIR Shorthand: example data, profiles, extensions, value sets, code systems |
| `cql` | Clinical Quality Language: per-patient logic, cohorts, measures |
| `fhirpath` | a value inside a resource; invariants; search parameters |
| `vcl` | a value set in one line |
| `fml` | the FHIR Mapping Language: one structure to another |
| `sql-on-fhir` | ViewDefinitions: resources flattened into tables |
| `capability` | FHIR servers you declare: resources, interactions, search parameters, operations (new ones, and $validate, $expand, $transform … by reference) |
| `search` | FHIR search syntax |

## The tools
| Tool | Does |
|---|---|
| `write(path, text)` | saves a file; answers its problems |
| `check()` | every file's problems |
| `run(path)` | a file against the data: a summary, the first rows, a handle `result://rN` and `result://<file name>` |
| `query(language, text)` | once, without a file: `fhirpath`, `cql`, `vcl`, `search`, `view`, `sql` |
| `explain(ref, subject)` | why one patient's (resource's) answer is what it is, step by step |
| `describe(ref)` | a result (paged; `as: "csv"`), `Type/id` (`as: "fsh"`), a canonical, a type or element, an operation |
| `apply(operation, inputs)` | any FHIR operation: `$validate`, `$expand`, `$lookup`, `$translate`, `$evaluate-measure`, … |
| `stage(…)`, `commit(stage)` | write data: validated and diffed first; a stage with errors is refused |

## A session
Two patients and their HbA1c results, written as FSH, stored in `fhir.db`, searched, put through a
CQL rule, flattened into a table and joined with the rule's answer in SQL. Each call is shown with the part of
its answer that matters (this exact session runs in the fhir-mcp tests).

Create the data. FSH writes a coding, a quantity or a reference in one value; `Reference(ann)` is
the instance `ann` written in the same text:

```fsh
Instance: ann
InstanceOf: Patient
* name.given = "Ann"
* name.family = "Ng"
* gender = #female
* birthDate = "1961-04-12"

Instance: bob
InstanceOf: Patient
* name.given = "Bob"
* name.family = "Okafor"
* gender = #male
* birthDate = "1988-09-30"

Instance: ann-a1c
InstanceOf: Observation
* status = #final
* code = http://loinc.org#4548-4 "Hemoglobin A1c"
* subject = Reference(ann)
* effectiveDateTime = "2025-02-10"
* valueQuantity = 9.4 '%'

Instance: bob-a1c
InstanceOf: Observation
* status = #final
* code = http://loinc.org#4548-4 "Hemoglobin A1c"
* subject = Reference(bob)
* effectiveDateTime = "2025-03-02"
* valueQuantity = 5.6 '%'
```

```call
stage {"fsh": "<the FSH above>"}
```
```answer
{"errors": 0, "stage": "stage-1", "changes": [{"action": "create", "resource": "Patient/ann"}, {"action": "create", "resource": "Patient/bob"},
 {"action": "create", "resource": "Observation/ann-a1c"}, {"action": "create", "resource": "Observation/bob-a1c"}]}
```
```call
commit {"stage": "stage-1", "reason": "two patients' HbA1c results"}
```

The commit leaves a Provenance in the store beside the data: the versions it wrote, the agent, the
reason, and the FSH it came from (the text itself, with its SHA-1).

Find results above 9% with a FHIR search (the store indexes every resource by FHIR's own search
parameters):

```call
query {"language": "search", "text": "Observation?code=http://loinc.org|4548-4&value-quantity=gt9"}
```
```answer
{"result": "result://r1", "total": 1, "rows": [{"resource": "Observation/ann-a1c"}]}
```

That search answers "was ANY result above 9%?". A rule per patient — "is the LATEST result above
9%?" — is CQL (the recipe in `learn://cql`, "the latest value per patient"):

```cql
library Diabetes version '1.0.0'
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers
codesystem "LOINC": 'http://loinc.org'
code "HbA1c": '4548-4' from "LOINC"
context Patient
define "A1c Results": [Observation: "HbA1c"] O where O.status in { 'final', 'amended', 'corrected' }
define "Latest": Last("A1c Results" O sort by (effective as dateTime))
define "Poor Control": ("Latest".value as Quantity) > 9 '%'
```

```call
write {"path": "Diabetes.cql", "text": "<the CQL above>"}
```
```answer
{"problems": []}
```
```call
run {"path": "Diabetes.cql"}
```
```answer
{"result": "result://r2", "name": "result://Diabetes", "summary": {"patients": 2, "defines": {"Poor Control": {"true": 1, "false": 1}}},
 "rows": [{"patient": "ann", "Poor Control": true}, {"patient": "bob", "Poor Control": false}]}
```
This is the short form of learn://cql's latest-value recipe, which spells the same library out in
full (`"Latest Value"`, `"Poorly Controlled"`, a number and a unit to print, "never tested"): start
from the recipe for a real question, and set its threshold (9 % in both) to the one asked.
A run's preview lists every define per patient; `explain(ref, subject, entry: "<define>")` answers one.

A table of every HbA1c result, as a ViewDefinition:

```view
{"resourceType": "ViewDefinition", "name": "a1c", "status": "active", "resource": "Observation",
 "where": [{"path": "code.coding.exists(system = 'http://loinc.org' and code = '4548-4')"}],
 "select": [{"column": [
   {"name": "patient", "path": "subject.getReferenceKey(Patient)"},
   {"name": "date", "path": "effective.ofType(dateTime)"},
   {"name": "value", "path": "value.ofType(Quantity).value"}]}]}
```

```call
write {"path": "a1c.view.json", "text": "<the view above>"}
```
```answer
{"problems": []}
```

Then SQL over the tables: each view by its name, each earlier result by its name (`Diabetes`, the
latest run of Diabetes.cql — SQL kept in a file stays right when the CQL is run again) or its number
(`r2`); a column whose name has a space is quoted:

```call
query {"language": "sql", "text": "SELECT a1c.patient, a1c.value FROM a1c JOIN Diabetes d ON d.patient = a1c.patient WHERE d.\"Poor Control\" = 1"}
```
```answer
{"columns": ["patient", "value"], "rows": [{"patient": "ann", "value": 9.4}]}
```

SQL reads the stored resources too: each resource type is a table of `id`, `versionId`,
`lastUpdated` and `resource`, the resource as JSONB (`->>` takes a value out of it, `json_each`
walks a list):

```call
query {"language": "sql", "text": "SELECT resource ->> '$.gender' AS gender, count(*) AS n FROM Patient GROUP BY gender ORDER BY gender"}
```
```answer
{"rows": [{"gender": "female", "n": 1}, {"gender": "male", "n": 1}]}
```

Every version of a resource, what changed and why (its Provenance):

```call
describe {"ref": "Observation/ann-a1c/_history"}
```
```answer
{"resource": "Observation/ann-a1c", "versions": [{"version": "1", "changed": "created", "reason": "two patients' HbA1c results"}]}
```

Read one resource back in its compact form:

```call
describe {"ref": "Observation/ann-a1c", "as": "fsh"}
```
```answer
"Instance: ann-a1c\nInstanceOf: Observation\n* code = http://loinc.org#4548-4 \"Hemoglobin A1c\"\n* effectiveDateTime = \"2025-02-10\"\n* status = #final\n* subject = Reference(Patient/ann)\n* valueQuantity = 9.4 '%'"
```

## Constraints and the trail
Rules about the data are FHIR profiles: write one in FSH (cardinalities, fixed codes, value sets,
FHIRPath invariants for anything more complex) and name it in workspace.yaml —
`profiles:` / `  Observation: <canonical>`. Every staged resource of the type is held to it and
claims it in `meta.profile`; a stage that breaks it lists the rule and cannot commit; `check`
holds the workspace's FSH examples to it, `check(data: true)` everything already stored, counting
violations by rule. `write path=rules.fsh text=@rules.fsh enforce:=true` writes the profile AND names it
in workspace.yaml. `raco fhir-mcp guide workspace` has what to copy: a rules cookbook (a range, a
unit, not in the future), a complete blood-pressure rule (systolic and diastolic in mm[Hg], a
subject), and the correction recipe (`describe … as=fsh`, edit, stage, commit with a reason) — each
tested as written.
Every commit writes a Provenance (versions, agent, `reason`, source text and hash) and an AuditEvent
into the store; `audit: all` in workspace.yaml records every run, query and apply as an AuditEvent
too. All of it is data: `describe("Observation", as: "trail")` — every stored Observation with its
subject, value and date beside who wrote it, when, why and from which file and line, as CSV: "where did
each value come from" in one call; `describe("Type/id/_history")` (each version's changes as `path: old → new`),
`describe("Provenance/<id>", as: "source")` (the source text, decoded), `query("search", "Provenance?target=Patient/ann")`,
and SQL over `trail` (each written version with its agent, reason and source), `history` (every
version), `Provenance` and `AuditEvent`. A result's `describe` names
its source (file, SHA-1, the data as of when).

## Build a FHIR server
A file `<name>.capability.rkt` in `#lang fhir/capability` declares a server: `(resource Patient
#:interactions (read create search-type) #:search-params ([gender token]))`, existing operations by
reference (`(operation "StructureMap/$transform")` serves FML transformations, `$validate`, `$expand`,
`$evaluate-measure`), and operations of your own with a Racket handler, which can call any of the
languages. `write` checks it (problems at their lines), `run` serves it on a free port over the
workspace's `fhir.db` — what the workspace commits, the server serves, and what the server writes,
the workspace's search and SQL see — and `apply("$yourOperation", inputs)` calls the running server.
From the shell each call is its own process, so a server `run` started is gone with it: serve it
yourself and give `apply` its url (`apply … url=` needs no workspace: it only POSTs to the server).
After editing the app, stop the server (the pid it printed) and serve it again. The store: `(server
#:store "study.db")` in the file names one beside it; `--store fhir.db` on the command line overrides
it (here, the workspace's own store, so the workspace sees what the server writes).
```
raco fhir-server serve study.capability.rkt --port 8080 --store fhir.db &       # check it first: racket study.capability.rkt
raco fhir-mcp call apply operation='$egfr' url=http://localhost:8080 inputs:='{"creatinine": 1.1, "age": 60, "sex": "female"}'
```
`raco fhir-mcp guide capability` has the cheat sheet and a worked example (a clinic server with a
`$bmi` operation), tested as written.

## When something is off
- A problem line names the file, line and column: fix it there and `write` again.
- An answer you did not expect: `explain(ref: "result://r2", subject: "Patient/bob", entry: "Poor Control")`
  walks the CQL down to the retrieve and says which resources it kept.
- A stage with errors lists them per resource; nothing is written until they are gone.

## Without MCP
Each language also has a command line and a Racket `#lang` (its repository's README and
`.claude/skills/<language>/SKILL.md`): `raco fsh check <dir>`, `raco cql <file> --data <dir>`,
`raco fhirpath '<expr>' <resource.json>`, `raco vcl '<expr>'`, `raco fml <map> --transform <src>`,
`raco sql-on-fhir run <view> <data>`, `raco fhir-validate <resource.json> [profile.json]`,
`raco fhir-tx expand <url>`, `raco fhir-server serve-ig <package>`. Writing the languages in Racket
modules: the `fhir-authoring` skill; serving FHIR over HTTP: `fhir-serving`.

## A Racket program
A QuestionnaireResponse → FML → a Patient validated against an FSH profile → a CQL answer
(fhir-authoring explains each piece):
```sh
raco fhir new pipeline my-pipeline && cd my-pipeline          # a copy of the template
raco fsh check fsh                                                # the profile and its valid example: exit 0
raco fsh check fsh-invalid --context fsh || true                  # the example meant to fail, at its line (exit 1)
raco fml check qr2patient.map --examples qr.json --profile fsh   # the map's result held to the profile
racket main.rkt --now 2026-01-01 qr.json                          # the Patient, then "65 or older: true"
raco test tests.rkt                                               # all of the above as one gate
```
To write the four files yourself instead: `fsh/intake.fsh` (`#lang fsh`: a Profile with `1..1` rules and
an Instance — the fsh skill), `qr2patient.map` (`#lang fml`: a group from QuestionnaireResponse to
Patient, one rule per item — the fml guide's cheat sheet), `Intake.cql` (`#lang cql`: `define "Is 65 Or
Older": AgeInYears() >= 65` — the cql guide) and `main.rkt` (fhir-authoring shows it whole). The map and
the validation read FHIR R5 and the CQL library FHIR 4.0.1: a Patient's name, gender and birthDate are
the same in both. A Racket program needs none of the workspace sections above; go on in `fhir-authoring`, "The languages
together in one program" (its API card lists every function `main.rkt` uses).
