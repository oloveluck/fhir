# fhir

Tools for working with [FHIR](https://hl7.org/fhir/), the standard for exchanging health data.

FHIR comes with a handful of small languages: one for saying what valid data looks like, one for
clinical logic, one for converting data, one for naming sets of codes, one for asking questions of a
record, one for turning records into tables. This project implements them all, with a validator, a
terminology service and FHIR servers around them. Every tool tells you where a problem is, to the
line and column.

| You want to | Language | Tool |
|---|---|---|
| say what valid data looks like, and write examples of it | FHIR Shorthand | [`fsh`](https://github.com/oloveluck/fsh) |
| compute over a patient's record: rules, cohorts, quality measures | Clinical Quality Language | [`cql`](https://github.com/oloveluck/cql) |
| convert data from one shape to another | FHIR Mapping Language | [`fml`](https://github.com/oloveluck/fml) |
| name a set of codes | ValueSet Compose Language | [`vcl`](https://github.com/oloveluck/vcl) |
| ask a question of one resource | FHIRPath | [`fhirpath`](https://github.com/oloveluck/fhirpath) |
| turn resources into tables | SQL on FHIR | [`sql-on-fhir`](https://github.com/oloveluck/sql-on-fhir) |

Around them, in this repository: `fhir-validate` (check a resource), `fhir-tx` (terminology),
`fhir-server` (a FHIR server from an Implementation Guide), `fhir-lsp` (your editor) and `fhir-mcp`
(a workspace for an AI agent such as Claude).

```
$ fhir-validate bad-patient.json --format text
bad-patient.json: error code-invalid at Patient.gender: code `femme` not in required value set http://hl7.org/fhir/ValueSet/administrative-gender
bad-patient.json: error invalid at Patient.birthDate: '1974-13-40' is not a valid date
```

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

For an AI agent, `fhir-mcp init my-workspace` then makes a directory it can work in.

## Documentation

**[oloveluck.github.io/fhir](https://oloveluck.github.io/fhir/)** is where to start: what each
piece is for, a first example of each, and the reference.

- How well it works, measured against HL7's own test suites: [TESTING.md](TESTING.md).
- For AI agents: the `fhir` skill, [.claude/skills/fhir/SKILL.md](.claude/skills/fhir/SKILL.md).
- How it is built: [CLAUDE.md](CLAUDE.md).

License: MIT. The HL7 packages in `fhir-spec/` are CC0-1.0.
