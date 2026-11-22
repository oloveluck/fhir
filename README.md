# fhir — a toolkit for AI agents on FHIR

[FHIR](https://hl7.org/fhir/) is the standard for health data. This is an implementation of it
built for an AI agent to work in — read a patient's record, write data that is valid, say what
valid means, compute over it — and for you to check what the agent did. Four ideas carry it:

- **Languages, not JSON.** FHIR comes with small languages: one for what valid data looks like,
  one for clinical logic, one for converting data, one for sets of codes, one for questions of a
  record, one for tables. An agent reads and writes those; FHIR JSON is what they compile to. In
  the model's own tokens a CQL library is 13% of the JSON it compiles to, a value set in VCL 28%,
  a mapping 52% — and a correction to a stored record is the rules that change, 26 tokens where
  the record as JSON is 535.
- **One workspace, nine tools.** `fhir-mcp` gives an agent a directory to work in over all six
  languages, a store, FHIR search and SQL: write, check, run, query, explain, describe, apply,
  stage, commit. As an MCP server or from a shell; answers are a table's rows, not a page of JSON.
- **The data as the tables you think in.** A record's facts are spread over many resources; a
  question is usually about a table. The agent defines the tables once over the FHIR store — a
  SQL on FHIR view for each kind of resource, a `.sql` file for a join — and from then on a
  question is one SQL statement. A table can keep, in a column, the resource each row came
  from, so an answer is still traced to the record (`fhir guide tables`).
- **Nothing is written unchecked, and every write can be traced.** A change is staged, validated
  against your rules, and committed with a FHIR Provenance: who, when, why, and the text that
  made it. A mistake is one line, at its place, saying what was found and what would fix it.

## Measured

With Claude Sonnet, on benchmarks other people wrote, graded by their own graders, against the
same data served as plain FHIR REST ([how, and every miss](https://github.com/oloveluck/fhir-examples/tree/main/agent-bench)):

| | this toolkit | plain REST calls |
|---|---|---|
| [MedAgentBench](https://github.com/stanfordmlgroup/MedAgentBench), 300 clinical tasks | 300 right, 6k tokens a task | 294 right, 38k |
| [FHIR-AgentBench](https://github.com/glee4810/FHIR-AgentBench), 150 questions of a hospital's records | 147 right, 10k tokens a question | 109 right, 69k |
| a profile written from stated requirements, 24 published profiles | 1427 of 1431 constraints, 0.9k tokens (as FSH) | 1431, 1.8k tokens (as JSON) |

How the first two rows are reached matters more than the rows. Through the nine workspace tools
from a shell, an agent got 300 of MedAgentBench's tasks right at 41k tokens and 122 of those
FHIR-AgentBench questions at 57k: more right answers than REST, for tokens of the same order. The
tokens went when the agent was given the few actions a task needs as the tools of one process, no
shell, and a prompt holding only what its first step uses. The answers came when FHIR-AgentBench's own relational
schema was defined over the store by an agent, as views, and the questions were answered in SQL
with an example query of the same kind from the benchmark's training questions (the REST agents,
run in an earlier round, had the data alone). Over that benchmark's whole test split, 409
questions asked three times, 402 are marked right each time, and every question whose recorded
answer can be held to is right every time, at 4.8 seconds a question.

What that does not show is that the tools alone beat REST. Tested on its own — one harness, the
data alone, 150 questions neither side had been run on, the protocol written first — the
workspace's reading tools and a plain REST server with Python are level: 125 and 126 right, at
25k and 30k tokens ([the experiment](https://github.com/oloveluck/fhir-examples/tree/main/value-experiment)).
The difference above comes from the tables an agent defines over the store, given with examples
from the benchmark's training questions; which of the two carries it has not been separated.

Where a language does show is in what is built from it. Four published quality measures were
implemented by independent agents, five from each measure's English narrative and five from its
CQL, and held to the authors' test cases: 93% right from the narrative, 98% from the CQL, 99%
with the CQL executed; the implementers agree with each other on 88% of cases from the
narrative and 96% from the CQL. English left open what the specification states (which
encounters are "a visit"; whether a diagnosis "during" a period starts in it).

Where a declaration did not show: three operations were built as servers by independent agents,
five declared in the capability language and five by hand in Python each, kept up through three
changes to the operation's definition, and held to requests an agent that had not seen the
toolkit wrote. The hand-built servers answered every request as the definition says; the
declared ones 94%, at two and a half times the tokens. Every miss was one leniency of the
framework (a value sent under another type's key was converted), since fixed; with it fixed the
same servers are level. An agent writes those checks by hand correctly, so the declaration is
no advantage to it there.

And against HL7's own test suites and published guides: [TESTING.md](TESTING.md).

## What working in it looks like

A reading is stored; a repeat sample corrects it. The agent writes the rules that change, not the
resource, and the store keeps who changed what, from which line of which text:

```
$ cat fix.fsh
Instance: Observation/a1c-1
* status = #amended
* valueQuantity = 9.1 '%'
* note.text = "repeat sample"
$ fhir-mcp call stage fsh=@fix.fsh
{"changes":[{"action":"update","changed":["note: added [{\"text\":\"repeat sample\"}]","status: \"final\" → \"amended\"","valueQuantity.value: 9.4 → 9.1"],"resource":"Observation/a1c-1"}],"errors":0,"next":"commit stage=stage-2 writes the 1 change(s) to the store fhir.db","stage":"stage-2"}
$ fhir-mcp call commit stage=latest reason="repeat sample" agent=Practitioner/dr-ng
$ fhir-mcp call describe ref=Observation/a1c-1/_history as=csv columns=versionId,agent,reason,value,at
versionId,agent,reason,value,at
2,Practitioner/dr-ng,repeat sample,9.1 %,fix.fsh:4
1,Practitioner/dr-ng,clinic intake,9.4 %,readings.fsh:15
```

A status FHIR does not have is refused before anything is written:
``bad2.fsh:2: Observation.status: code `finished` not in required value set … it holds amended, appended, cancelled, …``.

## The pieces

| You want to | Language | Tool |
|---|---|---|
| say what valid data looks like, and write data | FHIR Shorthand | [`fsh`](https://github.com/oloveluck/fsh) |
| compute over a patient's record: rules, cohorts, quality measures | Clinical Quality Language | [`cql`](https://github.com/oloveluck/cql) |
| convert data from one shape to another | FHIR Mapping Language | [`fml`](https://github.com/oloveluck/fml) |
| name a set of codes | ValueSet Compose Language | [`vcl`](https://github.com/oloveluck/vcl) |
| ask a question of one resource | FHIRPath | [`fhirpath`](https://github.com/oloveluck/fhirpath) |
| turn resources into tables | SQL on FHIR | [`sql-on-fhir`](https://github.com/oloveluck/sql-on-fhir) |

Around them, in this repository: `fhir-mcp` (the agent's workspace), `fhir-server` (a FHIR server
from an Implementation Guide, or over a store), `fhir-validate`, `fhir-tx` (terminology) and
`fhir-lsp` (your editor). Each language has a guide written for an agent — `fhir guide <topic>` —
whose every example the tests run.

## Install

There are no downloads yet. Build the tools once on a machine with
[Racket 9](https://racket-lang.org); the result runs without Racket on any machine of the same kind.

```sh
for r in fhir fhirpath vcl cql fml fsh sql-on-fhir; do git clone https://github.com/oloveluck/$r.git; done
raco pkg install --link --auto --batch --no-docs fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx \
  fhir/fhir-validation cql fml fsh fhir/fhir-server fhir/fhir-lsp fhir/fhir-mcp sql-on-fhir
fhir/build-tools.sh dist
export PATH="$PWD/dist/bin:$PATH"
```

Then `fhir-mcp init my-workspace` makes a directory an agent can work in: a store, the MCP
server's configuration (`.mcp.json`, which Claude Code reads), and a note telling the agent where
to start. To load data you already have: `fhir-server load my-workspace/fhir.db <dir of FHIR JSON or .ndjson>`.

## Documentation

**[oloveluck.github.io/fhir](https://oloveluck.github.io/fhir/)**: what each piece is for, a first
example of each, and the reference.

- For agents: the `fhir` skill, [.claude/skills/fhir/SKILL.md](.claude/skills/fhir/SKILL.md), and
  `fhir guide` (`fhir guide data` is one page on reading a store).
- The measurements: [fhir-examples](https://github.com/oloveluck/fhir-examples) (`results/`,
  `agent-bench/results/`).
- How it is built: [CLAUDE.md](CLAUDE.md).

License: MIT. The HL7 packages in `fhir-spec/` are CC0-1.0.
