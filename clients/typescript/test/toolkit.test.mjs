// The client against the function server: the generated methods held to the table, every
// method of Toolkit, and what the process does when it dies or is not there.
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { after, describe, test } from "node:test";
import { fileURLToPath } from "node:url";

import { Commit, Compiled, FhirError, FUNCTIONS, Functions, Outcome, Project, PROTOCOL, Stage, Table, Toolkit, ToolkitNotFound,
         findCommand } from "../dist/index.js";

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, "..");
const table = JSON.parse(readFileSync(join(root, "..", "functions.json"), "utf8"));

const PATIENT = { resourceType: "Patient", id: "ann", gender: "female", birthDate: "1980-02-28", name: [{ family: "Lee", given: ["Ann"] }] };
const OBSERVATION = {
  resourceType: "Observation", id: "a1", status: "final",
  code: { coding: [{ system: "http://loinc.org", code: "4548-4" }] },
  subject: { reference: "Patient/ann" }, effectiveDateTime: "2025-03-01",
  valueQuantity: { value: 9.4, unit: "%", system: "http://unitsofmeasure.org", code: "%" },
};
const DATA = [PATIENT, OBSERVATION];
const PROFILE = "Profile: AdultPatient\nParent: Patient\n* birthDate 1..1\n";
const CQL = `library A1c version '1.0'
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'
context Patient
define "Latest": Last([Observation] O sort by (effective as dateTime))
define "Above 9": (Latest.value as Quantity) > 9 '%'
`;
const MAP = `/// url = "http://example.org/StructureMap/p2p"
/// name = "p2p"
uses "http://hl7.org/fhir/StructureDefinition/Patient" as source
uses "http://hl7.org/fhir/StructureDefinition/Patient" as target
group main(source src : Patient, target tgt : Patient) {
  src.birthDate as b -> tgt.birthDate = b;
  src.gender as g -> tgt.gender = g;
}
`;

const refused = async (promise, pattern) => {
  const error = await promise.then(() => assert.fail("the call was answered, and should have been refused"), (e) => e);
  assert.ok(error instanceof FhirError, `a FhirError, not ${error}`);
  assert.match(error.message, pattern);
  return error;
};

describe("generated from the table", () => {
  test("the generated module is up to date", () => {
    execFileSync(process.execPath, [join(root, "generate.mjs"), "--check"]);
  });

  test("protocol, names, and a method for each function", () => {
    assert.equal(PROTOCOL, table.protocol);
    assert.deepEqual([...FUNCTIONS], table.functions.map((f) => f.name));
    for (const f of table.functions) assert.equal(typeof Functions.prototype[f.name], "function", f.name);
  });

  test("each function sends the arguments it is given, under its name", async () => {
    const sent = [];
    class Recording extends Functions { call(name, args) { sent.push([name, args]); return Promise.resolve("answered"); } }
    const recording = new Recording();
    for (const f of table.functions) {
      const args = Object.fromEntries(f.order.map((p) => [p, `value of ${p}`]));
      assert.equal(await recording[f.name](args), "answered");
      assert.deepEqual(sent.at(-1), [f.name, args]);
    }
    // the declarations name every parameter of the table, required or not
    const declared = readFileSync(join(root, "src", "functions.ts"), "utf8");
    for (const f of table.functions) {
      const body = declared.slice(declared.indexOf(`export interface ${f.name[0].toUpperCase()}${f.name.slice(1)}Arguments {`));
      for (const p of f.order) {
        const required = f.parameters.required.includes(p);
        assert.match(body.slice(0, body.indexOf("\n}")), new RegExp(`\\n  ${p}${required ? "" : "\\?"}: `), `${f.name}.${p}`);
      }
    }
  });

  test("the toolkit reaches every function", () => {
    const source = readFileSync(join(root, "src", "toolkit.ts"), "utf8");
    for (const name of FUNCTIONS) assert.ok(source.includes(`this.raw.${name}(`), `Toolkit has no method over the function ${name}`);
  });
});

describe("the toolkit", () => {
  const fhir = new Toolkit();
  after(() => fhir.close());

  test("version and guides", async () => {
    const version = await fhir.version();
    assert.equal(version.fhirVersion, "4.0.1");
    assert.deepEqual(version.functions, [...FUNCTIONS]);
    assert.ok((await fhir.guide()).includes("cql"));
    assert.match(await fhir.guide("fhirpath"), /FHIRPath/);
    await refused(fhir.guide("nope"), /no guide nope/);
  });

  test("fhirpath", async () => {
    assert.deepEqual(await fhir.fhirpath("name.given.first() + ' ' + name.family.first()", PATIENT), ["Ann Lee"]);
    assert.deepEqual(await fhir.fhirpath("birthDate", PATIENT), ["1980-02-28"]);
    assert.deepEqual(await fhir.fhirpath("name", PATIENT), PATIENT.name);
    assert.deepEqual(await fhir.fhirpath("active", PATIENT), []);
    const error = await refused(fhir.fhirpath("nmae", PATIENT), /no element Patient.nmae \(did you mean `name`\?\)/);
    assert.equal(error.code, -32000);
  });

  test("validate, alone and against a profile of the project", async () => {
    const outcome = await fhir.validate(PATIENT);
    assert.ok(outcome instanceof Outcome);
    assert.ok(outcome.ok);
    const bad = await fhir.validate({ resourceType: "Patient", gender: "florp" });
    assert.equal(bad.ok, false);
    assert.deepEqual(bad.messages(), ["Patient.gender: error: code `florp` not in required value set http://hl7.org/fhir/ValueSet/administrative-gender; it holds female, male, other, unknown"]);
    assert.throws(() => bad.raiseForErrors(), FhirError);
    const young = { resourceType: "Patient", id: "x" };
    for (const profile of ["AdultPatient", "http://example.org/StructureDefinition/AdultPatient"]) {
      assert.deepEqual((await fhir.validate(young, profile, { project: { "p.fsh": PROFILE } })).messages(),
                       ["Patient.birthDate: error: minimum required = 1, but found 0"]);
    }
    assert.ok((await fhir.validate(PATIENT, "AdultPatient", { project: new Project({ files: { "p.fsh": PROFILE } }) })).ok);
  });

  test("fsh and its errors, decompile, compile and check", async () => {
    const resources = await fhir.fsh(PROFILE);
    assert.deepEqual(resources.map((r) => [r.resourceType, r.id]), [["StructureDefinition", "AdultPatient"]]);
    const error = await refused(fhir.fsh("Profile: P\nParent: Patient\n* nmae 1..1\n"), /^input.fsh:3:3: error: profile: P: `nmae` is not an element of Patient/);
    assert.deepEqual([error.diagnostics[0].source, error.diagnostics[0].line, error.diagnostics[0].column], ["input.fsh", 3, 3]);
    assert.ok(error.result instanceof Compiled);
    const text = await fhir.decompile(PATIENT);
    assert.match(text, /^Instance: ann\nInstanceOf: Patient/);
    assert.deepEqual((await fhir.fsh(text))[0].name, PATIENT.name);
    const compiled = await fhir.compile({ "p.fsh": PROFILE, "A1c.cql": CQL });
    assert.deepEqual(compiled.resources.map((r) => r.resourceType).sort(), ["Library", "StructureDefinition"]);
    assert.equal(compiled.resource("Library").name, "A1c");
    const problems = await fhir.check({ "bad.fsh": "Profile: P\nParent: Patient\n* nmae 1..1\n" });
    assert.deepEqual(problems.map((d) => [d.source, d.line, d.severity]), [["bad.fsh", 3, "error"]]);
  });

  test("cql over data, its parameters, translate, run and explain", async () => {
    const table = await fhir.cql(CQL, DATA);
    assert.ok(table instanceof Table);
    assert.deepEqual(table.columns, ["patient", "Latest", "Above 9"]);
    assert.deepEqual(table.rows, [{ patient: "ann", Latest: "Observation/a1", "Above 9": true }]);
    assert.deepEqual(table.column("Above 9"), [true]);
    assert.deepEqual(table.toArrays(true), [["patient", "Latest", "Above 9"], ["ann", "Observation/a1", true]]);
    assert.deepEqual((await fhir.cql(CQL, DATA, { entry: "Above 9" })).columns, ["patient", "Above 9"]);
    const elm = await fhir.translate(CQL);
    assert.equal(elm.library.identifier.id, "A1c");
    await refused(fhir.translate("library B version '1.0'\nusing FHIR version '4.0.1'\ncontext Patient\ndefine \"X\": Foo\n"), /unknown identifier 'Foo'/);
    const project = { "A1c.cql": CQL };
    assert.equal((await fhir.run("A1c.cql", { project, data: DATA })).length, 1);
    const explained = await fhir.explain("A1c.cql", "ann", { project, data: DATA, entry: "Above 9" });
    assert.equal(explained.value, true);
  });

  test("views, sql, search, transform, operation and expand", async () => {
    assert.deepEqual((await fhir.view("SELECT id, name.family.first() AS family, birthDate FROM Patient", DATA)).rows,
                     [{ id: "ann", family: "Lee", birthDate: "1980-02-28" }]);
    const views = {
      "obs.sof": "CREATE VIEW obs WITH (status = 'active') AS SELECT id, subject.getReferenceKey(Patient) AS patient, value.ofType(Quantity).value AS value FROM Observation",
      "pts.sof": "CREATE VIEW pts WITH (status = 'active') AS SELECT getResourceKey() AS id, name.family.first() AS family FROM Patient",
    };
    const joined = await fhir.sql("SELECT o.id, p.family, o.value FROM obs o JOIN pts p ON p.id = o.patient", { project: views, data: DATA });
    assert.deepEqual(joined.toArrays(true), [["id", "family", "value"], ["a1", "Lee", 9.4]]);
    assert.deepEqual((await fhir.search("Observation?code=4548-4", DATA)).column("resource"), ["Observation/a1"]);
    assert.equal((await fhir.search("Observation?code=nope", DATA)).length, 0);
    assert.deepEqual(await fhir.transform(MAP, PATIENT), { resourceType: "Patient", birthDate: "1980-02-28", gender: "female" });
    const error = await refused(fhir.transform(MAP.replace("tgt.gender", "tgt.gendr"), PATIENT), /gendr/);
    assert.equal(error.diagnostics[0].line, 7);
    assert.deepEqual((await fhir.expand("(http://hl7.org/fhir/administrative-gender)(female;male)")).map((c) => c.code), ["female", "male"]);
    assert.deepEqual((await fhir.expand("http://hl7.org/fhir/ValueSet/administrative-gender")).map((c) => c.code).sort(), ["female", "male", "other", "unknown"]);
    const lookup = await fhir.operation("$lookup", { inputs: { system: "http://hl7.org/fhir/administrative-gender", code: "female" } });
    assert.equal(lookup.resourceType, "Parameters");
  });

  test("a project that is a directory, and data on disk", async () => {
    const tmp = mkdtempSync(join(tmpdir(), "fhir-toolkit-ts-"));
    try {
      mkdirSync(join(tmp, "project"));
      mkdirSync(join(tmp, "data"));
      writeFileSync(join(tmp, "project", "p.fsh"), "Profile: P1\nParent: Patient\n");
      writeFileSync(join(tmp, "data", "Patient-ann.json"), JSON.stringify(PATIENT));
      assert.deepEqual((await fhir.compile(join(tmp, "project"))).resources.map((r) => r.id), ["P1"]);
      assert.deepEqual((await fhir.view("SELECT id FROM Patient", join(tmp, "data"))).rows, [{ id: "ann" }]);
      await refused(fhir.view("SELECT id FROM Patient", join(tmp, "nope")), /does not exist/);
      assert.throws(() => new Project({ files: {}, directory: "." }), /files or a directory, not both/);
      assert.throws(() => new Project({ directory: "." }).withFile("a.fsh", "x"), /takes its files from the directory/);
    } finally {
      rmSync(tmp, { recursive: true, force: true });
    }
  });

  test("stage, commit, write and the trail", async () => {
    const tmp = mkdtempSync(join(tmpdir(), "fhir-toolkit-ts-"));
    const store = join(tmp, "clinic.db");
    try {
      const staged = await fhir.stage({ data: store, resources: DATA });
      assert.ok(staged instanceof Stage);
      assert.ok(staged.ok);
      assert.deepEqual(staged.of("create"), ["Patient/ann", "Observation/a1"]);
      assert.equal((await fhir.search("Patient", store)).length, 0, "nothing is written until commit");
      const written = await staged.commit("first load", { agent: "intake desk" });
      assert.ok(written instanceof Commit);
      assert.deepEqual(written.versions, ["Patient/ann/_history/1", "Observation/a1/_history/1"]);
      assert.match(written.provenance, /^Provenance\//);
      assert.deepEqual([written.reason, written.agent], ["first load", "intake desk"]);
      const again = await fhir.stage({ data: store, resources: DATA });
      assert.equal(again.id, undefined);
      await refused(again.commit(), /nothing to commit/);
      const change = await fhir.stage({ data: store, fsh: "Instance: Observation/a1\n* status = #amended\n* valueQuantity = 9.1 '%'" });
      assert.deepEqual(change.changes[0].changed, ['status: "final" → "amended"', "valueQuantity.value: 9.4 → 9.1"]);
      assert.deepEqual((await change.commit("corrected against the lab's report")).versions, ["Observation/a1/_history/2"]);
      // write: one error and nothing is written, and the refused stage is not left behind
      const bad = { ...OBSERVATION, id: "a2", status: "finl" };
      await refused(fhir.write({ data: store, resources: [{ ...PATIENT, id: "bo" }, bad] }), /Observation\/a2: Observation.status: code `finl` not in required value set/);
      assert.equal((await fhir.search("Patient?_id=bo", store)).length, 0);
      assert.deepEqual((await fhir.raw.stage({ data: store, drop: "all" })).stages, []);
      assert.equal((await fhir.write({ data: store, resources: PATIENT })).length, 0);
      const check = await fhir.stage({ data: store, resources: bad, keep: false });
      assert.equal(check.ok, false);
      assert.equal(check.id, undefined);
      await refused(fhir.write({ data: store, fsh: "Instance: cy\nInstanceOf: AdultPatient\n* gender = #male", project: { "p.fsh": PROFILE } }), /birthDate/);
      const trail = await fhir.sql("SELECT type, id, versionId, agent, reason FROM trail ORDER BY type, id, versionId", { data: store });
      assert.deepEqual(trail.rows.map((r) => [r.type, r.id, r.versionId, r.agent, r.reason]),
                       [["Observation", "a1", 1, "intake desk", "first load"],
                        ["Observation", "a1", 2, "fhir-api", "corrected against the lab's report"],
                        ["Patient", "ann", 1, "intake desk", "first load"]]);
    } finally {
      rmSync(tmp, { recursive: true, force: true });
    }
  });

  test("raw is the table as it is, and calls made at once are each answered", async () => {
    assert.deepEqual(await fhir.raw.fhirpath({ expression: "name.family", resource: PATIENT }), { values: ["Lee"] });
    assert.deepEqual(Object.keys(await fhir.raw.compile({ files: { "p.fsh": PROFILE } })).sort(), ["diagnostics", "resources"]);
    const error = await refused(fhir.raw.fhirpath({ expresion: "name" }), /`expresion` is not a parameter of fhirpath/);
    assert.equal(error.code, -32602);
    const answers = await Promise.all(Array.from({ length: 12 }, (_, i) => fhir.fhirpath(`${i} + 1`, PATIENT)));
    assert.deepEqual(answers, Array.from({ length: 12 }, (_, i) => [i + 1]));
  });
});

describe("the process", () => {
  test("a toolkit starts at its first call, and again after close", async () => {
    const fhir = new Toolkit();
    assert.deepEqual(await fhir.fhirpath("id", PATIENT), ["ann"]);
    fhir.close();
    assert.deepEqual(await fhir.fhirpath("id", PATIENT), ["ann"]);
    fhir.close();
  });

  test("FHIR R5 is another process, and a version it does not read is said", async () => {
    const r5 = new Toolkit({ fhirVersion: "5.0.0" });
    try {
      assert.equal((await r5.version()).fhirVersion, "5.0.0");
      assert.ok((await r5.validate(PATIENT)).ok);
    } finally {
      r5.close();
    }
    const r3 = new Toolkit({ fhirVersion: "3.0.2" });
    await refused(r3.version(), /process ended/);
    r3.close();
  });

  test("a process that dies is said, and started again", async () => {
    const tmp = mkdtempSync(join(tmpdir(), "fhir-toolkit-ts-"));
    const script = join(tmp, "once.mjs");
    // a server that answers `version`, then one call, then ends
    writeFileSync(script, `import { createInterface } from "node:readline";
let n = 0;
createInterface({ input: process.stdin }).on("line", (line) => {
  const request = JSON.parse(line);
  if (request.method === "version") console.log(JSON.stringify({ jsonrpc: "2.0", id: request.id, result: { protocol: ${PROTOCOL} } }));
  else if (++n === 1) console.log(JSON.stringify({ jsonrpc: "2.0", id: request.id, result: { values: ["first"] } }));
  else process.exit(3);
});
`);
    const fhir = new Toolkit({ command: [process.execPath, script] });
    try {
      assert.deepEqual(await fhir.fhirpath("x", PATIENT), ["first"]);
      await refused(fhir.fhirpath("x", PATIENT), /process ended \(exit status 3\) while answering fhirpath; it starts again at the next call/);
      assert.deepEqual(await fhir.fhirpath("x", PATIENT), ["first"]);
    } finally {
      fhir.close();
      rmSync(tmp, { recursive: true, force: true });
    }
  });

  test("a toolkit of another protocol is refused; no toolkit to start is said", async () => {
    const tmp = mkdtempSync(join(tmpdir(), "fhir-toolkit-ts-"));
    const script = join(tmp, "other.mjs");
    writeFileSync(script, `import { createInterface } from "node:readline";
createInterface({ input: process.stdin }).on("line", (line) => {
  console.log(JSON.stringify({ jsonrpc: "2.0", id: JSON.parse(line).id, result: { protocol: 999 } }));
});
`);
    try {
      await refused(new Toolkit({ command: [process.execPath, script] }).version(), /speaks protocol 999 and this package protocol/);
      const missing = await refused(new Toolkit({ command: [join(tmp, "no-such-program")] }).version(), /could not start the FHIR toolkit/);
      assert.ok(missing instanceof ToolkitNotFound);
      assert.deepEqual(findCommand(["x", "y"]), ["x", "y"]);
      const saved = { PATH: process.env.PATH, FHIR_API_COMMAND: process.env.FHIR_API_COMMAND };
      try {
        process.env.FHIR_API_COMMAND = "raco  fhir-api";
        assert.deepEqual(findCommand(), ["raco", "fhir-api"]);
        delete process.env.FHIR_API_COMMAND;
        process.env.PATH = tmp;
        assert.throws(() => findCommand(), ToolkitNotFound);
      } finally {
        process.env.PATH = saved.PATH;
        if (saved.FHIR_API_COMMAND === undefined) delete process.env.FHIR_API_COMMAND; else process.env.FHIR_API_COMMAND = saved.FHIR_API_COMMAND;
      }
    } finally {
      rmSync(tmp, { recursive: true, force: true });
    }
  });
});
