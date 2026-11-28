# fhir — a toolkit for AI agents on FHIR

[FHIR](https://hl7.org/fhir/) is the standard for health data, and it defines small languages: for
what valid data looks like, clinical logic, converting data, sets of codes, questions of a record
and tables. This implements all of them, with a validator, a terminology service, a store and
servers, built so that an AI agent writes the languages instead of JSON, nothing is stored
unchecked, and every write can be traced.

It is written in [Racket](https://racket-lang.org) and used from Racket (each language is a
`#lang`, each tool a `raco` command), from Python ([`agentfhir`](clients/python/README.md)),
from a shell, or by an agent as an MCP server (`fhir-mcp`; `agentfhir mcp` from Python).

A stored reading is corrected by the rules that change, and the store keeps who changed what:

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

## Install

There are no downloads yet. With [Racket 9](https://racket-lang.org), the second command installs
the packages (all Racket needs); the third builds the tools as programs that run without Racket.

```sh
for r in fhir fhirpath vcl cql fml fsh sql-on-fhir; do git clone https://github.com/oloveluck/$r.git; done
raco pkg install --link --auto --batch --no-docs fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx \
  fhir/fhir-validation cql fml fsh fhir/fhir-server fhir/fhir-lsp fhir/fhir-mcp sql-on-fhir
fhir/build-tools.sh dist
export PATH="$PWD/dist/bin:$PATH"
```

Then `fhir-mcp init my-workspace` makes a directory an agent can work in.

## Documentation

**[oloveluck.github.io/fhir](https://oloveluck.github.io/fhir/)**: what each piece is for, a first
example of each, the measurements, and the reference.

- The languages: [fsh](https://github.com/oloveluck/fsh), [cql](https://github.com/oloveluck/cql),
  [fml](https://github.com/oloveluck/fml), [vcl](https://github.com/oloveluck/vcl),
  [fhirpath](https://github.com/oloveluck/fhirpath), [sql-on-fhir](https://github.com/oloveluck/sql-on-fhir).
- For agents: the `fhir` skill, [.claude/skills/fhir/SKILL.md](.claude/skills/fhir/SKILL.md), and `fhir guide`.
- From Python: [clients/python/README.md](clients/python/README.md), with how it compares with other Python libraries.
- How it is tested and measured: [TESTING.md](TESTING.md), [fhir-examples](https://github.com/oloveluck/fhir-examples).
- How it is built: [CLAUDE.md](CLAUDE.md).

License: MIT. The HL7 packages in `fhir-spec/` are CC0-1.0.
