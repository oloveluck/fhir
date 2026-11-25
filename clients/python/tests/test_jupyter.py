"""The cell magics, run in an IPython shell as a notebook runs them."""
import contextlib
import io
import os
import pathlib
import sys
import unittest

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
if not os.environ.get("FHIR_TOOLKIT_TEST_INSTALLED"):
    sys.path.insert(0, str(ROOT / "src"))

try:
    from IPython.core.interactiveshell import InteractiveShell
except ImportError:
    InteractiveShell = None

PATIENT = {"resourceType": "Patient", "id": "ann", "gender": "female", "birthDate": "1980-02-28",
           "name": [{"family": "Lee", "given": ["Ann"]}]}
OBSERVATION = {"resourceType": "Observation", "id": "a1", "status": "final",
               "code": {"coding": [{"system": "http://loinc.org", "code": "4548-4"}]},
               "subject": {"reference": "Patient/ann"}, "effectiveDateTime": "2025-03-01",
               "valueQuantity": {"value": 9.4, "unit": "%", "system": "http://unitsofmeasure.org", "code": "%"}}
PROFILE = 'Profile: AdultPatient\nParent: Patient\n* birthDate 1..1\n\nInstance: bo\nInstanceOf: AdultPatient\n* birthDate = "1990-01-01"\n'
LIBRARY = """library A1c version '1.0'
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'
valueset "A1c": 'http://example.org/ValueSet/a1c'
context Patient
define "Latest": Last([Observation: "A1c"] O sort by (effective as dateTime))
define "Above 9": (Latest.value as Quantity) > 9 '%'
"""
MAP = """/// url = "http://example.org/StructureMap/copy"
/// name = "copy"
uses "http://hl7.org/fhir/StructureDefinition/Patient" as source
uses "http://hl7.org/fhir/StructureDefinition/Patient" as target
group main(source src : Patient, target tgt : Patient) {
  src.birthDate as b -> tgt.birthDate = b;
}
"""


def rows(answer):
    """A magic's table as a list of dicts, DataFrame or Table."""
    return answer.to_dict("records") if hasattr(answer, "to_dict") else answer.rows


@unittest.skipIf(InteractiveShell is None, "IPython is not installed")
class TheMagics(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.shell = InteractiveShell.instance()
        cls.shell.run_line_magic("load_ext", "fhir_toolkit.jupyter")
        from fhir_toolkit.jupyter import notebook
        cls.notebook = notebook

    @classmethod
    def tearDownClass(cls):
        cls.notebook.toolkit.close()

    def setUp(self):
        self.shell.run_line_magic("fhir", "reset")
        self.shell.user_ns.update(patient=PATIENT, data=[PATIENT, OBSERVATION])

    def cell(self, magic, line, text):
        """A cell run: (what it answered, what it printed, what it said was wrong)."""
        out, err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            answer = self.shell.run_cell_magic(magic, line, text)
        return answer, out.getvalue(), err.getvalue()

    def test_fsh_defines_for_the_cells_after_it(self):
        answer, printed, wrong = self.cell("fsh", "-o defined", PROFILE)
        self.assertEqual(wrong, "")
        self.assertEqual(printed, "StructureDefinition/AdultPatient  http://example.org/StructureDefinition/AdultPatient\nPatient/bo\n")
        self.assertEqual([r["resourceType"] for r in self.shell.user_ns["defined"]], ["StructureDefinition", "Patient"])
        self.assertEqual(self.shell.run_line_magic("fhir", ""), ["AdultPatient.fsh"])
        # the profile is there for Python cells, and for a later FSH cell
        outcome = self.notebook.toolkit.validate({"resourceType": "Patient", "id": "z"}, "AdultPatient", project=self.notebook.project)
        self.assertEqual(outcome.messages(), ["Patient.birthDate: error: minimum required = 1, but found 0"])
        _, _, wrong = self.cell("fsh", "", "Instance: cy\nInstanceOf: AdultPatient\n* gender = #male\n")
        self.assertRegex(wrong, r"^cy\.fsh:1:1: error: instance cy: Patient\.birthDate: minimum required = 1")
        self.assertIn("constrained by profile AdultPatient at AdultPatient.fsh:3:3", wrong)
        # a cell with an error defines nothing; run again, a cell replaces its file
        self.assertEqual(self.shell.run_line_magic("fhir", ""), ["AdultPatient.fsh"])
        self.cell("fsh", "", PROFILE.replace("1..1", "0..1"))
        self.assertEqual(self.shell.run_line_magic("fhir", ""), ["AdultPatient.fsh"])
        self.assertIn("0..1", self.notebook.project.files["AdultPatient.fsh"])

    def test_a_mistake_is_said_at_its_line_in_the_cell(self):
        answer, printed, wrong = self.cell("fsh", "-o broken", "Profile: Broken\nParent: Patient\n* nmae 1..1\n")
        self.assertEqual((answer, printed), (None, ""))
        self.assertEqual(wrong, "Broken.fsh:3:3: error: profile: Broken: `nmae` is not an element of Patient (did you mean `name`?)\n")
        self.assertNotIn("broken", self.shell.user_ns)
        self.assertEqual(self.shell.run_line_magic("fhir", ""), [])
        answer, _, wrong = self.cell("cql", "-d data", "library B version '1.0'\nusing FHIR version '4.0.1'\ncontext Patient\ndefine \"X\": Foo\n")
        self.assertIsNone(answer)
        self.assertEqual(wrong, "B.cql:4:1: error: in define \"X\": unknown identifier 'Foo'\n")
        answer, _, wrong = self.cell("fhirpath", "-d nope", "name")
        self.assertEqual(wrong, "no variable `nope` in the notebook (%%fhirpath -d names a resource)\n")

    def test_a_value_set_a_library_and_views_build_on_one_another(self):
        codes, _, wrong = self.cell("vcl", "-n a1c", "(http://loinc.org)(4548-4;17856-6)")
        self.assertEqual(wrong, "")
        self.assertEqual([r["code"] for r in rows(codes)], ["4548-4", "17856-6"])
        cohort, _, wrong = self.cell("cql", "-d data -o cohort", LIBRARY)
        self.assertEqual(wrong, "")
        self.assertEqual(rows(cohort), [{"patient": "ann", "Latest": "Observation/a1", "Above 9": True}])
        self.assertIs(self.shell.user_ns["cohort"], cohort)
        one, _, _ = self.cell("cql", "-d data -e 'Above 9'", LIBRARY)
        self.assertEqual(rows(one), [{"patient": "ann", "Above 9": True}])
        pts, _, _ = self.cell("sof", "-d data", "CREATE VIEW pts WITH (status = 'active') AS SELECT getResourceKey() AS id, name.family.first() AS family FROM Patient")
        self.assertEqual(rows(pts), [{"id": "ann", "family": "Lee"}])
        self.cell("sof", "-d data", "CREATE VIEW obs WITH (status = 'active') AS SELECT id, subject.getReferenceKey(Patient) AS patient, value.ofType(Quantity).value AS value FROM Observation")
        joined, _, wrong = self.cell("fhir_sql", "-d data", "SELECT p.family, o.value FROM obs o JOIN pts p ON p.id = o.patient")
        self.assertEqual(wrong, "")
        self.assertEqual(rows(joined), [{"family": "Lee", "value": 9.4}])
        unnamed, _, _ = self.cell("sof", "-d data", "SELECT id FROM Patient")
        self.assertEqual(rows(unnamed), [{"id": "ann"}])
        self.assertEqual(self.shell.run_line_magic("fhir", ""), ["A1c.cql", "a1c.vcl", "obs.sof", "pts.sof"])
        self.shell.run_line_magic("fhir", "forget obs.sof")
        self.assertEqual(self.shell.run_line_magic("fhir", ""), ["A1c.cql", "a1c.vcl", "pts.sof"])

    def test_data_loaded_once_is_a_cell_s_data(self):
        from fhir_toolkit.jupyter import notebook
        self.shell.user_ns["kept"] = notebook.toolkit.load([PATIENT, OBSERVATION])
        answer, _, wrong = self.cell("sof", "-d kept", "SELECT id FROM Patient")
        self.assertEqual(wrong, "")
        self.assertEqual(rows(answer), [{"id": "ann"}])
        self.shell.user_ns["kept"].close()

    def test_fhirpath_and_a_map(self):
        one, _, _ = self.cell("fhirpath", "-d patient", "name.given.first()")
        self.assertEqual(one, ["Ann"])
        several, _, _ = self.cell("fhirpath", "-d patient -o values", "name.family\n// a comment\nbirthDate\n")
        self.assertEqual(several, {"name.family": ["Lee"], "birthDate": ["1980-02-28"]})
        self.assertEqual(self.shell.user_ns["values"], several)
        copied, _, wrong = self.cell("fml", "-d patient -o copy", MAP)
        self.assertEqual(wrong, "")
        self.assertEqual(copied, {"resourceType": "Patient", "birthDate": "1980-02-28"})
        self.assertEqual(self.shell.run_line_magic("fhir", ""), ["copy.map"])


if __name__ == "__main__":
    unittest.main()
