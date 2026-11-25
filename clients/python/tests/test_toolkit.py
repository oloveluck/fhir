"""The Python client held to the toolkit: the generated functions to the table, and every
method to what the function server answers. The server is started as `Toolkit()` starts it
(FHIR_API_COMMAND, a bundled executable, `fhir-api` or `raco fhir-api` on the PATH).

    python3 -m unittest discover -s clients/python/tests
"""
import inspect
import json
import os
import pathlib
import subprocess
import sys
import tempfile
import threading
import unittest

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
# FHIR_TOOLKIT_TEST_INSTALLED=1 tests the package as installed (a wheel with its executable), not this source tree
if not os.environ.get("FHIR_TOOLKIT_TEST_INSTALLED"):
    sys.path.insert(0, str(ROOT / "src"))

import fhir_toolkit  # noqa: E402
from fhir_toolkit import Commit, Compiled, Diagnostic, FhirError, Outcome, Project, Stage, Table, Toolkit, ToolkitNotFound, plain, typed  # noqa: E402
from fhir_toolkit._functions import Functions  # noqa: E402

TABLE = ROOT.parent / "functions.json"

PATIENT = {"resourceType": "Patient", "id": "ann", "gender": "female", "birthDate": "1980-02-28",
           "name": [{"family": "Lee", "given": ["Ann"]}]}
OBSERVATION = {"resourceType": "Observation", "id": "a1", "status": "final",
               "code": {"coding": [{"system": "http://loinc.org", "code": "4548-4"}]},
               "subject": {"reference": "Patient/ann"}, "effectiveDateTime": "2025-03-01",
               "valueQuantity": {"value": 9.4, "unit": "%", "system": "http://unitsofmeasure.org", "code": "%"}}
DATA = [PATIENT, OBSERVATION]
PROFILE = "Profile: AdultPatient\nParent: Patient\n* birthDate 1..1\n"
CQL = """library A1c version '1.0'
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'
context Patient
define "Latest": Last([Observation] O sort by (effective as dateTime))
define "Above 9": (Latest.value as Quantity) > 9 '%'
"""
MAP = """/// url = "http://example.org/StructureMap/p2p"
/// name = "p2p"
uses "http://hl7.org/fhir/StructureDefinition/Patient" as source
uses "http://hl7.org/fhir/StructureDefinition/Patient" as target
group main(source src : Patient, target tgt : Patient) {
  src.birthDate as b -> tgt.birthDate = b;
  src.gender as g -> tgt.gender = g;
}
"""
VIEWS = {
    "obs.sof": "CREATE VIEW obs WITH (status = 'active') AS SELECT id, subject.getReferenceKey(Patient) AS patient, "
               "value.ofType(Quantity).value AS value FROM Observation",
    "pts.sof": "CREATE VIEW pts WITH (status = 'active') AS SELECT getResourceKey() AS id, name.family.first() AS family FROM Patient",
}


class GeneratedFromTheTable(unittest.TestCase):
    """The client's functions are the table's: names, parameters, their order, which are required."""

    def setUp(self):
        self.table = json.loads(TABLE.read_text(encoding="utf-8"))

    def test_the_generated_module_is_up_to_date(self):
        done = subprocess.run([sys.executable, str(ROOT / "generate.py"), "--check"], capture_output=True, text=True)
        self.assertEqual(done.returncode, 0, done.stderr)

    def test_protocol_and_names(self):
        self.assertEqual(fhir_toolkit.PROTOCOL, self.table["protocol"])
        self.assertEqual(fhir_toolkit.FUNCTIONS, [f["name"] for f in self.table["functions"]])

    def test_each_function_is_a_method_with_the_tables_parameters(self):
        for f in self.table["functions"]:
            method = getattr(Functions, f["name"])
            given = [p for p in inspect.signature(method).parameters.values() if p.name != "self"]
            self.assertEqual([p.name.rstrip("_") for p in given], f["order"], f["name"])
            required = [p.name.rstrip("_") for p in given if p.default is inspect.Parameter.empty]
            self.assertEqual(required, [p for p in f["order"] if p in f["parameters"]["required"]], f["name"])
            self.assertIn(f["summary"].split(".")[0].split(":")[0][:40], " ".join(method.__doc__.split()), f["name"])

    def test_each_function_sends_what_it_is_given(self):
        sent = []

        class Recorder(Functions):
            def _call(self, name, arguments):
                sent.append((name, arguments))
                return {}

        recorder = Recorder()
        for f in self.table["functions"]:
            arguments = {(p + "_" if p == "as" else p): "value of " + p for p in f["order"]}
            getattr(recorder, f["name"])(**arguments)
            self.assertEqual(sent[-1], (f["name"], {p: "value of " + p for p in f["order"]}))
            # an argument not given is not sent
            getattr(recorder, f["name"])(**{k: v for k, v in arguments.items() if k.rstrip("_") in f["parameters"]["required"]})
            self.assertEqual(sorted(sent[-1][1]), sorted(f["parameters"]["required"]), f["name"])

    def test_the_toolkit_reaches_every_function(self):
        source = (ROOT / "src" / "fhir_toolkit" / "toolkit.py").read_text(encoding="utf-8")
        for name in fhir_toolkit.FUNCTIONS:
            self.assertIn("self.raw.%s(" % name, source, "Toolkit has no method over the function %s" % name)


class TheToolkit(unittest.TestCase):
    """Every method against the function server."""

    @classmethod
    def setUpClass(cls):
        cls.fhir = Toolkit()

    @classmethod
    def tearDownClass(cls):
        cls.fhir.close()

    # ---- what it is ---------------------------------------------------------------------------
    def test_version_and_guides(self):
        version = self.fhir.version()
        self.assertEqual(version["fhirVersion"], "4.0.1")
        self.assertEqual(version["functions"], fhir_toolkit.FUNCTIONS)
        self.assertIn("cql", self.fhir.guide())
        self.assertIn("FHIRPath", self.fhir.guide("fhirpath"))
        with self.assertRaisesRegex(FhirError, "no guide nope"):
            self.fhir.guide("nope")

    # ---- one resource -------------------------------------------------------------------------
    def test_fhirpath(self):
        self.assertEqual(self.fhir.fhirpath("name.given.first() + ' ' + name.family.first()", PATIENT), ["Ann Lee"])
        self.assertEqual(self.fhir.fhirpath("name", PATIENT), [{"family": "Lee", "given": ["Ann"]}])
        self.assertEqual(self.fhir.fhirpath("birthDate", PATIENT), ["1980-02-28"])
        self.assertEqual(self.fhir.fhirpath("birthDate < @1990-01-01", PATIENT), [True])
        self.assertEqual(self.fhir.fhirpath("name.where(use = 'old')", PATIENT), [])
        with self.assertRaisesRegex(FhirError, "no element HumanName.nmae"):
            self.fhir.fhirpath("name.nmae", PATIENT)
        with self.assertRaises(FhirError) as syntax:
            self.fhir.fhirpath("name.(", PATIENT)
        self.assertEqual(syntax.exception.diagnostics[0].lang, "fhirpath")

    def test_validate(self):
        valid = self.fhir.validate(PATIENT)
        self.assertIsInstance(valid, Outcome)
        self.assertTrue(valid.ok)
        self.assertTrue(valid)
        self.assertIs(valid.raise_for_errors(), valid)
        invalid = self.fhir.validate({"resourceType": "Patient", "gender": "florp"})
        self.assertFalse(invalid)
        self.assertEqual(len(invalid.errors), 1)
        self.assertRegex(invalid.messages()[0], r"^Patient.gender: error: code `florp` not in required value set")
        with self.assertRaises(FhirError) as raised:
            invalid.raise_for_errors()
        self.assertEqual(raised.exception.outcome["resourceType"], "OperationOutcome")

    def test_validate_against_a_profile_of_the_project(self):
        no_birth_date = {"resourceType": "Patient", "gender": "female"}
        for named in ("AdultPatient", "http://example.org/StructureDefinition/AdultPatient"):
            outcome = self.fhir.validate(no_birth_date, named, project={"p.fsh": PROFILE})
            self.assertEqual(outcome.errors[0]["expression"], ["Patient.birthDate"], named)
        self.assertTrue(self.fhir.validate(PATIENT, "AdultPatient", project={"p.fsh": PROFILE}).ok)
        with self.assertRaises(FhirError) as unknown:
            self.fhir.validate(PATIENT, "http://example.org/StructureDefinition/Nope")
        self.assertIsNotNone(unknown.exception.outcome)

    def test_decompile_and_compile_are_inverse(self):
        text = self.fhir.decompile(PATIENT)
        self.assertTrue(text.startswith("Instance: ann\nInstanceOf: Patient"))
        self.assertEqual(self.fhir.fsh(text), [PATIENT])
        structure_map = self.fhir.compile({"p2p.map": MAP}).resource("StructureMap")
        self.assertEqual(self.fhir.compile({"again.map": self.fhir.decompile(structure_map)}).resources, [structure_map])
        view = self.fhir.compile({"pts.sof": VIEWS["pts.sof"]}).resource("ViewDefinition")
        self.assertIn("FROM Patient", self.fhir.decompile(view))
        value_set = {"resourceType": "ValueSet", "compose": {"include": [{"system": "http://loinc.org", "concept": [{"code": "4548-4"}]}]}}
        self.assertEqual(self.fhir.decompile(value_set, "vcl"), "(http://loinc.org)4548-4")
        library = self.fhir.compile({"A1c.cql": CQL}).resource("Library")
        self.assertEqual(self.fhir.decompile(library), CQL)
        with self.assertRaisesRegex(FhirError, "written as fsh, fml, sof, vcl or cql"):
            self.fhir.decompile(PATIENT, "xml")

    def test_transform(self):
        self.assertEqual(self.fhir.transform(MAP, PATIENT), {"resourceType": "Patient", "birthDate": "1980-02-28", "gender": "female"})
        with self.assertRaises(FhirError) as misspelt:
            self.fhir.transform(MAP.replace("tgt.gender", "tgt.gendr"), PATIENT)
        self.assertIn("gendr", str(misspelt.exception))
        self.assertEqual(misspelt.exception.diagnostics[0].line, 7)

    def test_operation_and_expand(self):
        value_set = self.fhir.operation("$expand", inputs={"url": "http://hl7.org/fhir/ValueSet/administrative-gender"})
        self.assertEqual([c["code"] for c in value_set["expansion"]["contains"]], ["male", "female", "other", "unknown"])
        self.assertEqual([c["code"] for c in self.fhir.expand("http://hl7.org/fhir/ValueSet/administrative-gender")],
                         ["male", "female", "other", "unknown"])
        self.assertEqual(self.fhir.expand("(http://hl7.org/fhir/administrative-gender)(female;male)"),
                         [{"system": "http://hl7.org/fhir/administrative-gender", "code": "female", "display": "Female"},
                          {"system": "http://hl7.org/fhir/administrative-gender", "code": "male", "display": "Male"}])
        with self.assertRaises(FhirError):
            self.fhir.operation("$nope")

    # ---- a project ----------------------------------------------------------------------------
    def test_fsh_and_its_errors(self):
        resources = self.fhir.fsh(PROFILE)
        self.assertEqual([(r["resourceType"], r["url"]) for r in resources],
                         [("StructureDefinition", "http://example.org/StructureDefinition/AdultPatient")])
        self.assertEqual(self.fhir.fsh(PROFILE, canonical="http://clinic.example/fhir")[0]["url"],
                         "http://clinic.example/fhir/StructureDefinition/AdultPatient")
        with self.assertRaises(FhirError) as raised:
            self.fhir.fsh("Profile: P\nParent: Patient\n* nmae 1..1\n")
        problem = raised.exception.diagnostics[0]
        self.assertEqual((problem.source, problem.line, problem.column, problem.severity), ("input.fsh", 3, 3, "error"))
        self.assertIn("`nmae` is not an element of Patient (did you mean `name`?)", problem.message)
        self.assertTrue(str(problem).startswith("input.fsh:3:3: error: "))
        # an example that breaks its profile, with the profile it instantiates given as the project
        with self.assertRaisesRegex(FhirError, "Patient.birthDate: minimum required = 1"):
            self.fhir.fsh("Instance: bo\nInstanceOf: AdultPatient\n* gender = #male\n", project={"p.fsh": PROFILE})

    def test_compile_and_check(self):
        project = {"p.fsh": PROFILE, "A1c.cql": CQL, "p2p.map": MAP,
                   "sexes.vcl": "(http://hl7.org/fhir/administrative-gender)(female;male)", **VIEWS}
        compiled = self.fhir.compile(project)
        self.assertIsInstance(compiled, Compiled)
        self.assertEqual(sorted(r["resourceType"] for r in compiled),
                         ["Library", "StructureDefinition", "StructureMap", "ValueSet", "ViewDefinition", "ViewDefinition"])
        self.assertEqual(len(compiled), 6)
        self.assertTrue(compiled.ok)
        self.assertEqual(compiled.resource("ViewDefinition", "pts")["resource"], "Patient")
        with self.assertRaises(KeyError):
            compiled.resource("ViewDefinition")
        broken = {"p.fsh": PROFILE + "\nInstance: bo\nInstanceOf: AdultPatient\n* gender = #male\n"}
        unchecked = self.fhir.compile(broken, check=False)
        self.assertFalse(unchecked.ok)
        self.assertEqual(len(unchecked.resources), 2)
        problems = self.fhir.check(broken)
        self.assertEqual([(d.source, d.line) for d in problems], [("p.fsh", 5)])
        self.assertIsInstance(problems[0], Diagnostic)
        with self.assertRaises(FhirError) as raised:
            self.fhir.compile(broken)
        self.assertEqual(len(raised.exception.result.resources), 2)
        self.assertEqual(self.fhir.check({"p.fsh": PROFILE}), [])

    def test_translate(self):
        elm = self.fhir.translate(CQL)
        self.assertEqual(elm["library"]["identifier"], {"id": "A1c", "version": "1.0"})
        with self.assertRaises(FhirError) as raised:
            self.fhir.translate(CQL.replace("Last(", "Lst("), name="A1c.cql")
        problem = raised.exception.diagnostics[0]
        self.assertEqual((problem.source, problem.line, problem.column), ("A1c.cql", 5, 18))
        self.assertIsNone(self.fhir.translate(CQL.replace("Last(", "Lst("), check=False))
        uses = "library Uses\nusing FHIR version '4.0.1'\ninclude A1c version '1.0' called A\ncontext Patient\ndefine X: A.\"Above 9\"\n"
        self.assertIn("library", self.fhir.translate(uses, project={"A1c.cql": CQL}))

    def test_cql_over_data(self):
        table = self.fhir.cql(CQL, DATA)
        self.assertIsInstance(table, Table)
        self.assertEqual((table.kind, table.columns), ("patients", ["patient", "Latest", "Above 9"]))
        self.assertEqual(table.rows, [{"patient": "ann", "Latest": "Observation/a1", "Above 9": True}])
        self.assertEqual(table.column("Above 9"), [True])
        self.assertEqual(len(table), 1)
        self.assertEqual(table[0]["patient"], "ann")
        lower = dict(OBSERVATION, valueQuantity=dict(OBSERVATION["valueQuantity"], value=6.1))
        self.assertEqual(self.fhir.cql(CQL, [PATIENT, lower]).column("Above 9"), [False])
        self.assertEqual(self.fhir.cql(CQL, DATA, entry="Above 9").columns, ["patient", "Above 9"])
        self.assertEqual(self.fhir.query("cql", "AgeInYearsAt(@2026-01-01)", data=DATA).rows, [{"patient": "ann", "Query": 45}])
        with self.assertRaises(KeyError):
            table.column("Nope")

    def test_cql_parameters_are_cql_expressions(self):
        library = ("library P\nusing FHIR version '4.0.1'\ninclude FHIRHelpers version '4.0.1'\nparameter Threshold Integer default 9\n"
                   "context Patient\ndefine \"Above\": exists([Observation] O where (O.value as Quantity).value > Threshold)\n")
        self.assertEqual(self.fhir.cql(library, DATA).column("Above"), [True])
        self.assertEqual(self.fhir.cql(library, DATA, parameters={"Threshold": "10"}).column("Above"), [False])
        with self.assertRaisesRegex(TypeError, "CQL expression as text"):
            self.fhir.cql(library, DATA, parameters={"Threshold": 10})

    def test_run_and_explain(self):
        project = Project({"A1c.cql": CQL})
        self.assertEqual(self.fhir.run("A1c.cql", project=project, data=DATA).rows[0]["Above 9"], True)
        explained = self.fhir.explain("A1c.cql", "ann", project=project, data=DATA, entry="Above 9")
        self.assertEqual((explained["value"], explained["uses"][0]["define"]), (True, "Latest"))
        with self.assertRaisesRegex(FhirError, "no file nope.cql in the project"):
            self.fhir.run("nope.cql", project=project, data=DATA)

    def test_views_tables_and_data_frames(self):
        view = self.fhir.view("SELECT id, name.family.first() AS family, birthDate FROM Patient", DATA)
        self.assertEqual(view.rows, [{"id": "ann", "family": "Lee", "birthDate": "1980-02-28"}])
        joined = self.fhir.sql("SELECT o.id, p.family, o.value FROM obs o JOIN pts p ON p.id = o.patient", project=VIEWS, data=DATA)
        self.assertEqual((joined.columns, joined.rows), (["id", "family", "value"], [{"id": "a1", "family": "Lee", "value": 9.4}]))
        try:
            import pandas
        except ImportError:
            self.skipTest("pandas is not installed")
        frame = joined.to_pandas()
        self.assertIsInstance(frame, pandas.DataFrame)
        self.assertEqual(list(frame.columns), ["id", "family", "value"])
        self.assertEqual(frame.to_dict("records"), [{"id": "a1", "family": "Lee", "value": 9.4}])
        # no rows is a frame with the view's columns
        empty = self.fhir.view("SELECT id FROM Encounter", DATA).to_pandas()
        self.assertEqual((list(empty.columns), len(empty)), (["id"], 0))

    def test_search(self):
        found = self.fhir.search("Observation?code=4548-4", DATA)
        self.assertEqual(found.column("resource"), ["Observation/a1"])
        self.assertEqual(found.rows[0]["json"]["id"], "a1")
        self.assertEqual(len(self.fhir.search("Observation?code=nope", DATA)), 0)

    # ---- projects and data in other forms -------------------------------------------------------
    def test_a_project_that_is_a_directory_and_data_on_disk(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = pathlib.Path(tmp)
            (root / "project").mkdir()
            (root / "data").mkdir()
            (root / "project" / "p.fsh").write_text("Profile: P1\nParent: Patient\n")
            (root / "data" / "Patient-ann.json").write_text(json.dumps(PATIENT))
            self.assertEqual([r["id"] for r in self.fhir.compile(root / "project")], ["P1"])
            (root / "project" / "q.fsh").write_text("Profile: P2\nParent: Patient\n")
            self.assertEqual(sorted(r["id"] for r in self.fhir.compile(Project(directory=root / "project"))), ["P1", "P2"])
            self.assertEqual(self.fhir.view("SELECT id FROM Patient", root / "data").rows, [{"id": "ann"}])
            self.assertEqual(self.fhir.view("SELECT id FROM Patient", str(root / "data")).rows, [{"id": "ann"}])
            with self.assertRaisesRegex(FhirError, "does not exist"):
                self.fhir.view("SELECT id FROM Patient", root / "nope")
            with self.assertRaisesRegex(ValueError, "takes its files from the directory"):
                self.fhir.cql(CQL, DATA, project=root / "project")

    def test_data_in_every_form(self):
        bundle = {"resourceType": "Bundle", "type": "collection", "entry": [{"resource": PATIENT}]}
        for data in (PATIENT, [PATIENT], (PATIENT,), bundle):
            self.assertEqual(self.fhir.view("SELECT id FROM Patient", data).rows, [{"id": "ann"}])

    def test_what_a_project_may_not_be(self):
        with self.assertRaisesRegex(ValueError, "files or a directory, not both"):
            Project({"a.fsh": PROFILE}, directory=".")
        with self.assertRaisesRegex(FhirError, "is not a file name inside the project"):
            self.fhir.compile({"../x.fsh": PROFILE})
        with self.assertRaisesRegex(FhirError, "the project is FHIR 5.0.0 and this process reads FHIR 4.0.1"):
            self.fhir.compile({"sushi-config.yaml": "id: x\ncanonical: http://x.org\nfhirVersion: 5.0.0\nversion: 1.0.0\n"})

    # ---- writing: stage, commit, write ----------------------------------------------------------
    def test_stage_then_commit_and_the_trail(self):
        with tempfile.TemporaryDirectory() as tmp:
            store = pathlib.Path(tmp) / "clinic.db"
            staged = self.fhir.stage(DATA, data=store)
            self.assertIsInstance(staged, Stage)
            self.assertTrue(staged.ok)
            self.assertEqual(staged.of("create"), ["Patient/ann", "Observation/a1"])
            self.assertEqual(len(self.fhir.search("Patient", store)), 0, "nothing is written until commit")
            written = staged.commit("first load", agent="intake desk")
            self.assertIsInstance(written, Commit)
            self.assertEqual(written.versions, ["Patient/ann/_history/1", "Observation/a1/_history/1"])
            self.assertTrue(written.provenance.startswith("Provenance/"))
            self.assertEqual((written.reason, written.agent), ("first load", "intake desk"))
            # the same resources again differ in nothing: no stage, and nothing to commit
            again = self.fhir.stage(DATA, data=store)
            self.assertIsNone(again.id)
            self.assertEqual(again.of("unchanged"), ["Patient/ann", "Observation/a1"])
            with self.assertRaisesRegex(FhirError, "nothing to commit"):
                again.commit()
            # a change said as the FSH rules that change
            change = self.fhir.stage(fsh="Instance: Observation/a1\n* status = #amended\n* valueQuantity = 9.1 '%'", data=store)
            self.assertEqual(change.changes[0]["changed"], ['status: "final" → "amended"', "valueQuantity.value: 9.4 → 9.1"])
            self.assertEqual(change.commit("corrected against the lab's report").versions, ["Observation/a1/_history/2"])
            trail = self.fhir.sql("SELECT type, id, versionId, agent, reason FROM trail ORDER BY type, id, versionId", data=store)
            self.assertEqual([(r["type"], r["id"], r["versionId"], r["agent"], r["reason"]) for r in trail.rows],
                             [("Observation", "a1", 1, "intake desk", "first load"),
                              ("Observation", "a1", 2, "fhir-api", "corrected against the lab's report"),
                              ("Patient", "ann", 1, "intake desk", "first load")])

    def test_write_is_stage_and_commit_and_refuses_whole(self):
        with tempfile.TemporaryDirectory() as tmp:
            store = pathlib.Path(tmp) / "clinic.db"
            bad = dict(OBSERVATION, id="a2", status="finl")
            with self.assertRaisesRegex(FhirError, r"Observation/a2: Observation.status: code `finl` not in required value set"):
                self.fhir.write([PATIENT, bad], data=store, reason="load")
            self.assertEqual(len(self.fhir.search("Patient", store)), 0, "one error and nothing is written")
            self.assertEqual(self.fhir.raw.stage(str(store), drop="all")["stages"], [], "the refused stage was dropped")
            written = self.fhir.write([PATIENT, OBSERVATION], data=store, reason="load")
            self.assertEqual(len(written), 2)
            self.assertEqual(len(self.fhir.write(PATIENT, data=store)), 0)
            # a check only: the same answer, nothing kept
            check = self.fhir.stage(bad, data=store, keep=False)
            self.assertFalse(check.ok)
            self.assertIsNone(check.id)
            self.assertIn("did you mean `final`?", check.errors[0])
            # a profile of the project is what an instance written in FSH is held to
            with self.assertRaisesRegex(FhirError, "birthDate"):
                self.fhir.write(fsh="Instance: bo\nInstanceOf: AdultPatient\n* gender = #male", data=store, project={"p.fsh": PROFILE})
            with self.assertRaisesRegex(FhirError, "give one of `resources`, `fsh`"):
                self.fhir.stage(data=store)

    # ---- typed models -------------------------------------------------------------------------
    def test_a_model_object_goes_in_as_the_json_it_writes(self):
        class Pydantic2:                                   # what pydantic 2 models offer
            def model_dump_json(self, **options):
                self.options = options
                return json.dumps(PATIENT)

            @classmethod
            def model_validate(cls, resource):
                made = cls()
                made.read = resource
                return made

        class Pydantic1:                                   # what pydantic 1 models offer
            def json(self):
                return json.dumps(PATIENT)

            def dict(self):
                return PATIENT

            @classmethod
            def parse_obj(cls, resource):
                made = cls()
                made.read = resource
                return made

        class Fhirclient:                                  # what fhirclient's models offer
            def __init__(self, jsondict=None):
                self.read = jsondict

            def as_json(self):
                return PATIENT

        model = Pydantic2()
        self.assertEqual(plain(model), PATIENT)
        self.assertEqual(model.options, {"exclude_none": True, "by_alias": True})
        for model in (Pydantic2(), Pydantic1(), Fhirclient()):
            self.assertEqual(plain({"resource": model, "list": [model]}), {"resource": PATIENT, "list": [PATIENT]})
            self.assertEqual(self.fhir.fhirpath("name.family", model), ["Lee"])
            self.assertTrue(self.fhir.validate(model).ok)
            self.assertEqual(self.fhir.view("SELECT id FROM Patient", [model]).rows, [{"id": "ann"}])
            self.assertEqual(self.fhir.view("SELECT id FROM Patient", model).rows, [{"id": "ann"}])
            self.assertEqual(typed(type(model), {"resourceType": "Patient"}).read, {"resourceType": "Patient"})
            self.assertEqual(self.fhir.transform(MAP, model, model=type(model)).read, {"resourceType": "Patient", "birthDate": "1980-02-28", "gender": "female"})
        self.assertEqual([m.read["id"] for m in typed(Fhirclient, [PATIENT, PATIENT])], ["ann", "ann"])
        import datetime
        import decimal
        self.assertEqual(plain({"when": datetime.date(1980, 2, 28), "value": decimal.Decimal("7.20"), "count": decimal.Decimal("3"),
                                "where": pathlib.PurePosixPath("a/b")}),
                         {"when": "1980-02-28", "value": 7.2, "count": 3, "where": "a/b"})
        with self.assertRaisesRegex(TypeError, "object is not FHIR JSON"):
            plain(object())

    def test_fhir_resources_models(self):
        try:
            from fhir.resources.R4B.patient import Patient
        except ImportError:
            self.skipTest("fhir.resources is not installed")
        ann = Patient(id="ann", gender="female", birthDate="1980-02-28", name=[{"family": "Lee", "given": ["Ann"]}])
        self.assertEqual(plain(ann), PATIENT)
        self.assertEqual(self.fhir.fhirpath("name.given", ann), ["Ann"])
        self.assertTrue(self.fhir.validate(ann).ok)
        copy = self.fhir.transform(MAP, ann, model=Patient)
        self.assertIsInstance(copy, Patient)
        self.assertEqual(copy.birthDate.isoformat(), "1980-02-28")
        made = self.fhir.fsh('Instance: bo\nInstanceOf: Patient\n* birthDate = "1990-01-01"\n', model=Patient)
        self.assertEqual([(type(m).__name__, m.id) for m in made], [("Patient", "bo")])
        with tempfile.TemporaryDirectory() as tmp:
            self.assertEqual(self.fhir.write(ann, data=pathlib.Path(tmp) / "s.db").versions, ["Patient/ann/_history/1"])

    # ---- the plain functions, and calls from several threads ------------------------------------
    def test_raw_is_the_table_as_it_is(self):
        self.assertEqual(self.fhir.raw.fhirpath("name.family", PATIENT), {"values": ["Lee"]})
        answer = self.fhir.raw.compile(files={"p.fsh": PROFILE})
        self.assertEqual(sorted(answer), ["diagnostics", "resources"])
        with self.assertRaises(FhirError) as refused:
            self.fhir.raw._call("fhirpath", {"expresion": "name"})
        self.assertEqual(refused.exception.code, -32602)
        with self.assertRaises(FhirError) as unknown:
            self.fhir.raw._call("nope", {})
        self.assertEqual(unknown.exception.code, -32601)

    def test_calls_from_several_threads(self):
        answers = {}

        def ask(i):
            answers[i] = self.fhir.fhirpath("name.family.first() + '%d'" % i, PATIENT)

        threads = [threading.Thread(target=ask, args=(i,)) for i in range(16)]
        for t in threads:
            t.start()
        for t in threads:
            t.join()
        self.assertEqual(answers, {i: ["Lee%d" % i] for i in range(16)})


class TheProcess(unittest.TestCase):
    """Starting, stopping, another FHIR version, and what goes wrong before a call is answered."""

    def test_a_toolkit_starts_at_its_first_call_and_again_after_close(self):
        fhir = Toolkit()
        self.assertFalse(fhir._server.running)
        self.assertEqual(fhir.fhirpath("gender", PATIENT), ["female"])
        self.assertTrue(fhir._server.running)
        fhir.close()
        self.assertFalse(fhir._server.running)
        self.assertEqual(fhir.fhirpath("gender", PATIENT), ["female"])
        fhir.close()
        fhir.close()

    def test_a_process_that_dies_is_said_and_started_again(self):
        with Toolkit() as fhir:
            fhir.version()
            fhir._server._process.kill()
            fhir._server._process.wait()
            self.assertEqual(fhir.fhirpath("gender", PATIENT), ["female"])
            process = fhir._server._process
            process.stdout.close()
            with self.assertRaisesRegex(FhirError, "process ended .* it starts again at the next call"):
                fhir.version()
            self.assertEqual(fhir.fhirpath("gender", PATIENT), ["female"])

    def test_fhir_r5_is_another_process(self):
        encounter = {"resourceType": "Encounter", "status": "completed", "actualPeriod": {"start": "2025-01-01"}}
        with Toolkit("5.0.0") as r5:
            self.assertEqual(r5.version()["fhirVersion"], "5.0.0")
            self.assertEqual(r5.fhirpath("actualPeriod.start", encounter), ["2025-01-01"])
            self.assertEqual(r5.fsh("Profile: P\nParent: Patient\n")[0]["fhirVersion"], "5.0.0")
        with self.assertRaisesRegex(FhirError, "FHIR version 3.0.2 is not one this toolkit reads|ended"):
            Toolkit("3.0.2").version()

    def test_no_toolkit_to_start(self):
        environment = dict(os.environ)
        try:
            os.environ["PATH"] = ""
            os.environ.pop("FHIR_API_COMMAND", None)
            if fhir_toolkit._server.bundled_command():
                self.skipTest("this installation carries the executable")
            with self.assertRaisesRegex(ToolkitNotFound, "no FHIR toolkit to start"):
                Toolkit().version()
        finally:
            os.environ.clear()
            os.environ.update(environment)
        with self.assertRaisesRegex(ToolkitNotFound, "could not start the FHIR toolkit"):
            Toolkit(command=["/nonexistent/fhir-api"]).version()

    def test_the_command_can_be_named(self):
        self.assertEqual(fhir_toolkit.find_command(["x", "y"]), ["x", "y"])
        environment = dict(os.environ)
        try:
            os.environ["FHIR_API_COMMAND"] = "raco fhir-api"
            self.assertEqual(fhir_toolkit.find_command(), ["raco", "fhir-api"])
        finally:
            os.environ.clear()
            os.environ.update(environment)

    def test_a_toolkit_of_another_protocol_is_refused(self):
        fake = "import sys, json\nfor line in sys.stdin:\n    r = json.loads(line)\n    print(json.dumps({'jsonrpc': '2.0', 'id': r['id'], 'result': {'protocol': 99}}), flush=True)\n"
        with tempfile.NamedTemporaryFile("w", suffix=".py", delete=False) as script:
            script.write(fake)
        try:
            with self.assertRaisesRegex(FhirError, "speaks protocol 99 and this package protocol %d" % fhir_toolkit.PROTOCOL):
                Toolkit(command=[sys.executable, script.name]).version()
        finally:
            os.unlink(script.name)


if __name__ == "__main__":
    unittest.main()
