# fhir-toolkit for TypeScript and JavaScript

FHIR is the standard health systems use to exchange clinical data. This package gives Node
programs the tools that usually take several installs: a validator, FHIR Shorthand (FSH),
Clinical Quality Language (CQL), FHIRPath, the FHIR Mapping Language, value sets in VCL and
SQL on FHIR views. You call methods; problems come back with the file, line and column they
are at.

It is a thin client. The work is done by the toolkit's own program, `fhir-api`, which this
package starts and talks to; its methods are generated from the same table of functions the
Python client is generated from, so the two cannot drift apart.

## Install

Not on npm yet. From a checkout of the repository:

```sh
cd clients/typescript
npm install
npm run build
```

The package needs the toolkit's program on the machine: a standalone build's `fhir-api` on
the `PATH`, or Racket with the toolkit's packages installed (`raco fhir-api`), or the command
named in `FHIR_API_COMMAND`. Unlike the Python wheel, this package does not carry it yet.

## A first example

Every method answers a promise. The toolkit's process starts at the first call and does not
keep your program running when it is done.

```js
import { Toolkit } from "fhir-toolkit";

const fhir = new Toolkit();

const patient = {
  resourceType: "Patient", id: "ann", gender: "female", birthDate: "1980-02-28",
  name: [{ family: "Lee", given: ["Ann"] }],
};

console.log(await fhir.fhirpath("name.given.first() + ' ' + name.family.first()", patient));
console.log((await fhir.validate(patient)).ok);
console.log((await fhir.validate({ resourceType: "Patient", gender: "florp" })).messages());
```

```text
[ 'Ann Lee' ]
true
[
  'Patient.gender: error: code `florp` not in required value set http://hl7.org/fhir/ValueSet/administrative-gender; it holds female, male, other, unknown'
]
```

## Say what valid means, then hold data to it

A profile written in FSH is a project: an object of file name to text. Give it to `validate`
and name the profile. A mistake in the FSH throws a `FhirError` that knows where it is.

```js
import { FhirError } from "fhir-toolkit";

const profiles = {
  "profiles.fsh": `
Profile: AdultPatient
Parent: Patient
* birthDate 1..1
`,
};

const outcome = await fhir.validate({ resourceType: "Patient", id: "x" }, "AdultPatient", { project: profiles });
console.log(outcome.messages());

try {
  await fhir.fsh("Profile: P\nParent: Patient\n* nmae 1..1\n");
} catch (error) {
  if (!(error instanceof FhirError)) throw error;
  const where = error.diagnostics[0];
  console.log(where.line, where.column, where.message);
}
```

```text
[ 'Patient.birthDate: error: minimum required = 1, but found 0' ]
3 3 profile: P: `nmae` is not an element of Patient (did you mean `name`?)
```

## Tables from FHIR

A view is a `SELECT` whose columns are FHIRPath expressions. Several views are tables SQL
joins.

```js
const a1c = {
  resourceType: "Observation", id: "a1c-1", status: "final",
  code: { coding: [{ system: "http://loinc.org", code: "4548-4" }] },
  subject: { reference: "Patient/ann" }, effectiveDateTime: "2025-03-01",
  valueQuantity: { value: 9.4, unit: "%", system: "http://unitsofmeasure.org", code: "%" },
};
const data = [patient, a1c];

const people = await fhir.view("SELECT id, name.family.first() AS family, birthDate FROM Patient", data);
console.log(people.columns, people.rows);

const views = {
  "obs.sof": "CREATE VIEW obs WITH (status = 'active') AS SELECT subject.getReferenceKey(Patient) AS patient, value.ofType(Quantity).value AS percent FROM Observation",
  "pts.sof": "CREATE VIEW pts WITH (status = 'active') AS SELECT getResourceKey() AS id, name.family.first() AS family FROM Patient",
};
const joined = await fhir.sql("SELECT p.family, o.percent FROM obs o JOIN pts p ON p.id = o.patient", { project: views, data });
console.log(joined.toArrays(true));
```

```text
[ 'id', 'family', 'birthDate' ] [ { birthDate: '1980-02-28', family: 'Lee', id: 'ann' } ]
[ [ 'family', 'percent' ], [ 'Lee', 9.4 ] ]
```

## Clinical logic in CQL

`cql` runs a library over the data: a row for each patient, a column for each definition.

```js
const library = `
library A1c version '1.0'
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'
context Patient
define "Latest": Last([Observation] O sort by (effective as dateTime))
define "Above 9": (Latest.value as Quantity) > 9 '%'
`;

const cohort = await fhir.cql(library, data);
console.log(cohort.toArrays(true));
```

```text
[
  [ 'patient', 'Latest', 'Above 9' ],
  [ 'ann', 'Observation/a1c-1', true ]
]
```

## Write data, with a record of who and why

`write` puts resources into a store: a SQLite file, made the first time. Each resource is
validated first, and one error means nothing is written. `stage` is the first half alone; a
correction can be said as the FSH rules that change. What is written leaves a trail SQL reads.

```js
import { mkdtempSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const store = join(mkdtempSync(join(tmpdir(), "clinic-")), "clinic.db");

const written = await fhir.write({ data: store, resources: data, reason: "first load", agent: "intake desk" });
console.log(written.versions);

const change = await fhir.stage({ data: store, fsh: "Instance: Observation/a1c-1\n* valueQuantity = 9.1 '%'" });
console.log(change.changes[0].changed);
await change.commit("corrected against the lab's report");

const trail = await fhir.sql("SELECT type, id, versionId, agent, reason FROM trail ORDER BY type, id, versionId", { data: store });
for (const row of trail) console.log(row.type, row.id, row.versionId, row.agent, "-", row.reason);
```

```text
[ 'Patient/ann/_history/1', 'Observation/a1c-1/_history/1' ]
[ 'valueQuantity.value: 9.4 → 9.1' ]
Observation a1c-1 1 intake desk - first load
Observation a1c-1 2 fhir-api - corrected against the lab's report
Patient ann 1 intake desk - first load
```

## What is where

| you have | call |
|---|---|
| one resource and a question | `fhirpath(expression, resource)` |
| a resource to check | `validate(resource, profile?, { project })` |
| FSH | `fsh(text)` gives resources; `decompile(resource)` gives FSH back |
| a CQL library | `cql(text, data)` runs it; `translate(text)` gives ELM |
| a view | `view(text, data)`; `sql(statement, { project: views, data })` |
| a map | `transform(map, source)` |
| a value set | `expand(urlOrVcl)` |
| a FHIR search | `search("Observation?code=4548-4", data)` |
| any FHIR operation | `operation("$expand", { inputs })` |
| resources to store | `write({ data: store, resources })`; `stage(…)` then `.commit(reason)` |
| several files in several languages | `compile(project)`, `check(project)`, `run(path, { project, data })`, `explain(…)` |

`fhir.raw` has every function exactly as the toolkit defines it: one argument object in,
plain JSON out. `new Toolkit({ fhirVersion: "5.0.0" })` is a second process, for FHIR R5.

## Limits

- The package does not carry the toolkit's program: it has to be on the machine (above).
- It is not published to npm.
- Values are JSON; there are no resource classes.
- `write` and `stage` write to a SQLite store or a directory of FHIR JSON, not to a FHIR
  server.
- Numbers pass through JSON, so a decimal written `1.50` arrives as `1.5`.

## Tests

```sh
npm test
```

runs the generator's check (the methods are what `clients/functions.json` gives), the
compiler, every method against the toolkit, and this page's examples, held to the output
shown.
