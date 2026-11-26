"""pydantic with the toolkit: objects in, objects out, and the toolkit's checks as pydantic's.

Skipped where pydantic 2 is not installed; the cases with a FHIR model library where
fhir.resources is not.
"""
import dataclasses
import datetime
import os
import pathlib
import sys
import unittest
from typing import Annotated, List, Optional

HERE = pathlib.Path(__file__).resolve().parent
if not os.environ.get("FHIR_TOOLKIT_TEST_INSTALLED"):
    sys.path.insert(0, str(HERE.parent / "src"))

try:
    import pydantic
    from pydantic import BaseModel, Field, TypeAdapter, ValidationError
    HAVE = pydantic.VERSION.startswith("2.")
except ImportError:                                         # pragma: no cover
    HAVE = False
try:
    from fhir.resources.R4B.humanname import HumanName
    from fhir.resources.R4B.patient import Patient
except ImportError:                                         # pragma: no cover
    Patient = None

from fhir_toolkit import Toolkit  # noqa: E402
from fhir_toolkit._server import encode  # noqa: E402
from fhir_toolkit.toolkit import _parts  # noqa: E402

ANN = {"resourceType": "Patient", "id": "ann", "gender": "female", "birthDate": "1980-02-28", "name": [{"family": "Lee", "given": ["Ann"]}]}


@unittest.skipUnless(HAVE, "pydantic 2 is not installed")
class WithPydantic(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from fhir_toolkit import pydantic as held
        cls.held = held
        cls.fhir = held.use(Toolkit())

    @classmethod
    def tearDownClass(cls):
        cls.held.use(None)
        cls.fhir.close()

    def models(self):
        class Name(BaseModel):
            family: str
            given: Optional[List[str]] = None

        class MyPatient(BaseModel):
            resourceType: str = "Patient"
            id: str
            gender: Optional[str] = None
            birth_date: Optional[datetime.date] = Field(None, alias="birthDate")
            name: Optional[List[Name]] = None
            model_config = {"populate_by_name": True}
        return Name, MyPatient

    def test_a_model_of_ones_own_goes_in_and_comes_back(self):
        Name, MyPatient = self.models()
        mine = MyPatient(id="cy", gender="female", birth_date=datetime.date(1990, 1, 1), name=[Name(family="Ito")])
        self.assertTrue(self.fhir.validate(mine).ok)
        self.assertEqual(self.fhir.fhirpath("birthDate", mine), ["1990-01-01"])           # by its alias, as FHIR names it
        self.assertEqual(self.fhir.fhirpath("name", mine, model=Name), [Name(family="Ito")])
        self.assertEqual(self.fhir.fhirpath_each("name", [mine, mine], model=Name), [[Name(family="Ito")]] * 2)
        back = self.fhir.fsh("Instance: bo\nInstanceOf: Patient\n* gender = #male\n* birthDate = \"1970-01-01\"\n", model=MyPatient)
        self.assertEqual(back, [MyPatient(id="bo", gender="male", birth_date=datetime.date(1970, 1, 1))])
        found = self.fhir.search("Patient?gender=female", [mine, ANN]).resources(model=MyPatient)
        self.assertEqual(sorted(p.id for p in found), ["ann", "cy"])

    def test_rows_as_models(self):
        class Row(BaseModel):
            id: str
            born: Optional[datetime.date] = None

        @dataclasses.dataclass
        class Plain:
            id: str
            born: Optional[str] = None
        table = self.fhir.view("SELECT id, birthDate AS born FROM Patient", [ANN])
        self.assertEqual(table.to_models(Row), [Row(id="ann", born=datetime.date(1980, 2, 28))])
        self.assertEqual(table.to_models(Plain), [Plain("ann", "1980-02-28")])

        @dataclasses.dataclass
        class Resource:
            id: str
            gender: Optional[str] = None
            resourceType: str = "Patient"
        self.assertEqual(self.fhir.fhirpath("id | gender", Resource("x")), ["x"])        # a dataclass goes in as its fields, None left out
        with self.assertRaisesRegex(Exception, "no resources"):
            table.resources()

    def test_a_models_own_json_goes_into_the_request_as_it_is(self):
        Name, MyPatient = self.models()
        mine = MyPatient(id='a"b\n', name=[Name(family="é")])
        line = encode({"params": {"resources": [mine, {"k": mine}], "text": "\x00fhir:0:0\x00"}})
        self.assertTrue(line.endswith(b"\n") and line.count(b"\n") == 1)
        import json
        read = json.loads(line)
        self.assertEqual(read["params"]["resources"][0], {"resourceType": "Patient", "id": 'a"b\n', "name": [{"family": "é"}]})
        self.assertEqual(read["params"]["resources"][1]["k"]["id"], 'a"b\n')
        self.assertEqual(read["params"]["text"], "\x00fhir:0:0\x00")                      # a text that looks like a mark is a text

    def test_valid_and_holds_are_pydantic_errors_at_the_element(self):
        Valid, Holds = self.held.Valid, self.held.Holds

        class Intake(BaseModel):
            patient: Annotated[dict, Valid(), Holds("birthDate.exists()", "a birth date is required")]
        self.assertEqual(Intake(patient=ANN).patient["id"], "ann")
        with self.assertRaises(ValidationError) as caught:
            Intake(patient=dict(ANN, gender="florp"))
        (error,) = caught.exception.errors()
        self.assertEqual((error["type"], error["loc"], error["input"]), ("fhir_code_invalid", ("patient", "gender"), "florp"))
        self.assertIn("not in required value set", error["msg"])
        with self.assertRaises(ValidationError) as caught:
            Intake(patient={"resourceType": "Patient", "gender": "female"})
        (error,) = caught.exception.errors()
        self.assertEqual((error["type"], error["loc"], error["msg"]), ("fhir_invariant", ("patient",), "a birth date is required"))
        # an issue inside a datatype is said with its path, at the value
        with self.assertRaises(ValidationError) as caught:
            TypeAdapter(Annotated[dict, Valid()]).validate_python(dict(ANN, name=[{"family": "Lee", "nmae": 1}]))
        (error,) = caught.exception.errors()
        self.assertEqual(error["loc"], ())
        self.assertTrue(error["msg"].startswith("HumanName.nmae: "), error["msg"])
        self.assertEqual(self.held.location("Patient.name[0].given[1]", "Patient"), ("name", 0, "given", 1))
        self.assertEqual(self.held.location("contact.name", "Patient"), ("contact", "name"))
        self.assertIsNone(self.held.location("HumanName.given", "Patient"))

    def test_checked_holds_a_class_to_a_profile(self):
        _, MyPatient = self.models()
        project = {"adult.fsh": "Profile: Adult\nParent: Patient\n* birthDate 1..1\n* name 1..*\n"}
        Adult = self.held.checked(MyPatient, "Adult", project=project)
        self.assertTrue(issubclass(Adult, MyPatient) and Adult.__name__ == "MyPatient" and Adult.fhir_profile == "Adult")
        ok = Adult.model_validate({"id": "a", "birthDate": "1980-01-01", "name": [{"family": "Lee"}]})
        self.assertEqual(ok.birth_date, datetime.date(1980, 1, 1))
        with self.assertRaises(ValidationError) as caught:
            Adult(id="b")
        self.assertEqual(sorted((e["loc"], e["type"]) for e in caught.exception.errors()),
                         [(("birthDate",), "fhir_required"), (("name",), "fhir_required")])

        @self.held.checked(profile="Adult", project=project)
        class Decorated(MyPatient):
            pass
        with self.assertRaises(ValidationError):
            Decorated(id="c")
        self.assertEqual(MyPatient(id="d").id, "d")                                       # the class given is as it was

    @unittest.skipIf(Patient is None, "fhir.resources is not installed")
    def test_a_fhir_model_librarys_objects(self):
        ann = Patient(id="ann", gender="female", name=[HumanName(family="Lee")])
        self.assertEqual(self.fhir.fhirpath("name", ann, model=HumanName)[0].family, "Lee")
        self.assertEqual(self.fhir.search("Patient?gender=female", [ann]).resources(model=Patient)[0].id, "ann")
        Checked = self.held.checked(Patient)
        with self.assertRaises(ValidationError) as caught:
            Checked(id="x", gender="florp")
        self.assertEqual(caught.exception.errors()[0]["loc"], ("gender",))
        self.assertIsInstance(Checked(id="x", gender="male"), Patient)


class Workers(unittest.TestCase):
    def test_a_list_is_cut_into_runs_in_order(self):
        self.assertEqual(_parts(list(range(10)), 4), [[0, 1, 2], [3, 4, 5], [6, 7], [8, 9]])
        self.assertEqual(_parts([1, 2], 4), [[1], [2]])
        self.assertEqual(_parts([], 3), [[]])

    def test_workers_answer_as_one_process_does(self):
        patients = [dict(ANN, id="p%d" % i, gender="florp" if i % 7 == 0 else "female") for i in range(300)]
        with Toolkit() as one, Toolkit(workers=3) as three:
            self.assertEqual(repr(three), "Toolkit(FHIR 4.0.1, running, 3 workers)")
            self.assertEqual(three.fhirpath_each("id", patients), one.fhirpath_each("id", patients))
            self.assertEqual([o.resource for o in three.validate_each(patients)], [o.resource for o in one.validate_each(patients)])
            self.assertEqual(three.fhirpath_each("id", patients[:5]), [["p%d" % i] for i in range(5)])   # a short list: this process
            with self.assertRaisesRegex(Exception, "parse error"):                                     # a mistake is raised once
                three.fhirpath_each("nosuch(", patients)
            self.assertEqual(three.fhirpath_each("id", patients[:70])[69], ["p69"])                    # and the workers go on
        with self.assertRaises(ValueError):
            Toolkit(workers=0, start=False)


if __name__ == "__main__":
    unittest.main()
