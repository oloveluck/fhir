"""Codes and value sets as Python values; the kinds of error; calls answered at the same time
(threads, asyncio, workers). Runs against the toolkit the package finds, as test_toolkit does."""
import asyncio
import os
import pathlib
import tempfile
import sys
import threading
import time
import unittest

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
if str(ROOT / "src") not in sys.path:
    sys.path.insert(0, str(ROOT / "src"))

from fhir_toolkit import (AsyncToolkit, CodeCheck, Concept, FhirError, FhirNotFound, FhirOperationError,  # noqa: E402
                          FhirSourceError, FhirTimeout, FhirUsageError, FhirValidationError, Match, Toolkit)

GENDER = "http://hl7.org/fhir/administrative-gender"
GENDERS = "http://hl7.org/fhir/ValueSet/administrative-gender"
V2 = "http://terminology.hl7.org/CodeSystem/v2-0001"
TO_V2 = "http://hl7.org/fhir/ConceptMap/cm-administrative-gender-v2"
PATIENT = {"resourceType": "Patient", "id": "ann", "gender": "female", "birthDate": "1980-02-28"}


class Codes(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.fhir = Toolkit()

    @classmethod
    def tearDownClass(cls):
        cls.fhir.close()

    def test_validate_code(self):
        held = self.fhir.validate_code(GENDERS, "female", GENDER)
        self.assertIsInstance(held, CodeCheck)
        self.assertTrue(held)
        self.assertEqual((held.code, held.system, held.display), ("female", GENDER, "Female"))
        missing = self.fhir.validate_code(GENDERS, "florp", GENDER)
        self.assertFalse(missing)
        self.assertIn("florp", missing.message)
        # a Coding, a CodeableConcept, a VCL expression, a value set a project defines
        self.assertTrue(self.fhir.validate_code(GENDERS, {"system": GENDER, "code": "male"}))
        self.assertTrue(self.fhir.validate_code(GENDERS, {"coding": [{"system": GENDER, "code": "other"}]}))
        self.assertFalse(self.fhir.validate_code("(%s)(female;male)" % GENDER, "other", GENDER))
        project = {"vs.fsh": "ValueSet: Sexes\nId: sexes\n* %s#female\n* %s#male\n" % (GENDER, GENDER)}
        self.assertFalse(self.fhir.validate_code("http://example.org/ValueSet/sexes", "other", GENDER, project=project))
        self.assertTrue(self.fhir.validate_code("http://example.org/ValueSet/sexes", "male", GENDER, project=project))
        # a display is checked when given
        self.assertIn("Female", self.fhir.validate_code(GENDERS, "female", GENDER, display="Woman").message)
        with self.assertRaises(FhirNotFound):
            self.fhir.validate_code("http://example.org/ValueSet/none", "a", "http://example.org")

    def test_lookup(self):
        concept = self.fhir.lookup(GENDER, "female")
        self.assertIsInstance(concept, Concept)
        self.assertEqual((concept.display, concept.definition, concept.name), ("Female", "Female.", "AdministrativeGender"))
        # nothing to look up is an error that says so, and a LookupError
        with self.assertRaisesRegex(FhirNotFound, "Unknown code 'femal'"):
            self.fhir.lookup(GENDER, "femal")
        with self.assertRaisesRegex(LookupError, "http://loinc.org is not here"):
            self.fhir.lookup("http://loinc.org", "4548-4")

    def test_subsumes(self):
        acts = "http://terminology.hl7.org/CodeSystem/v3-ActCode"
        self.assertEqual(self.fhir.subsumes(acts, "AMB", "_ActEncounterCode"), "subsumed-by")
        self.assertEqual(self.fhir.subsumes(acts, "_ActEncounterCode", "AMB"), "subsumes")
        self.assertEqual(self.fhir.subsumes(GENDER, "male", "male"), "equivalent")

    def test_translate(self):
        self.assertEqual(self.fhir.translate("female", GENDER, concept_map=TO_V2),
                         [Match({"relationship": "equal", "concept": {"system": V2, "code": "F"}})])
        self.assertEqual([m.code for m in self.fhir.translate({"system": GENDER, "code": "male"}, concept_map=TO_V2)], ["M"])
        self.assertEqual(self.fhir.translate("florp", GENDER, concept_map=TO_V2), [])
        # no map named: the maps in context between the two systems, each match saying which
        found = self.fhir.translate("female", GENDER, target=V2)
        self.assertEqual([(m.code, m.source) for m in found], [("F", TO_V2)])
        self.assertEqual(found[0].coding(), {"system": V2, "code": "F"})
        self.assertGreater(len(self.fhir.translate("female", GENDER)), 1)

    def test_the_kinds_of_error(self):
        with self.assertRaises(FhirSourceError) as e:
            self.fhir.fsh("Profile: P\nParent: Patient\n* nmae 1..1\n")
        self.assertEqual(e.exception.diagnostics[0].line, 3)
        with self.assertRaises(FhirSourceError):
            self.fhir.elm("library X using FHIR version '4.0.1' define A: Lst(1)")
        with self.assertRaises(FhirUsageError):
            self.fhir.raw._call("validate", {"resource": PATIENT, "nonsense": 1})
        with self.assertRaises(ValueError):            # a usage error is a ValueError too
            self.fhir.fhirpath("name", "not json")
        with self.assertRaises(FhirValidationError) as e:
            self.fhir.validate(dict(PATIENT, gender="florp")).raise_for_errors()
        self.assertFalse(e.exception.result.ok)
        with self.assertRaises(FhirOperationError) as e:
            self.fhir.operation("$lookup", inputs={"system": "http://loinc.org", "code": "1"})
        self.assertEqual(e.exception.issue_code, "not-found")
        # every one of them is a FhirError, as before
        for kind in (FhirSourceError, FhirUsageError, FhirValidationError, FhirOperationError, FhirNotFound, FhirTimeout):
            self.assertTrue(issubclass(kind, FhirError))


class AtTheSameTime(unittest.TestCase):
    PATIENTS = [dict(PATIENT, id="p%d" % i, gender="florp" if i % 3 == 0 else "female") for i in range(3000)]

    def test_calls_from_threads_go_to_the_processes_free(self):
        with Toolkit(workers=3) as fhir:
            answers = [None] * 6

            def work(i):
                answers[i] = [o.ok for o in fhir.validate_each(self.PATIENTS[i * 100:(i + 1) * 100])]
            threads = [threading.Thread(target=work, args=(i,)) for i in range(6)]
            for t in threads:
                t.start()
            for t in threads:
                t.join()
            self.assertEqual(answers, [[(i * 100 + k) % 3 != 0 for k in range(100)] for i in range(6)])

    def test_loaded_data_is_loaded_where_it_is_used(self):
        with Toolkit(workers=2) as fhir:
            clinic = fhir.load(self.PATIENTS[:5])
            first, second = fhir._raws
            first.busy += 1                          # the first is busy: the next call goes to the second
            try:
                self.assertEqual(len(fhir.view("SELECT id FROM Patient", clinic)), 5)
            finally:
                first.busy -= 1
            self.assertEqual(set(clinic._keys), {first, second})
            clinic.close()
            with self.assertRaisesRegex(FhirUsageError, "closed"):
                fhir.view("SELECT id FROM Patient", clinic)

    def test_a_stage_is_committed_where_it_was_made(self):
        with Toolkit(workers=2) as fhir, tempfile.TemporaryDirectory() as d:
            store = os.path.join(d, "s.db")
            staged = fhir.stage([PATIENT], data=store)
            fhir._raws[0].busy += 5                  # whichever made it, the other is now "freer"
            try:
                self.assertEqual(staged.commit("first").versions, ["Patient/ann/_history/1"])
            finally:
                fhir._raws[0].busy -= 5

    def test_asyncio(self):
        async def main():
            async with AsyncToolkit(workers=2) as fhir:
                self.assertEqual(await fhir.fhirpath("gender", PATIENT), ["female"])
                checks = await asyncio.gather(*[fhir.validate_code(GENDERS, code, GENDER) for code in ("female", "florp")])
                self.assertEqual([bool(c) for c in checks], [True, False])
                outcomes = await asyncio.gather(*[fhir.validate_each(self.PATIENTS[i::4]) for i in range(4)])
                self.assertEqual(sum(1 for part in outcomes for o in part if not o.ok), 1000)
                staged = await fhir.stage([PATIENT], data=os.path.join(d, "a.db"))
                self.assertEqual((await fhir.commit(staged, "async")).versions, ["Patient/ann/_history/1"])
                with self.assertRaises(FhirNotFound):
                    await fhir.lookup("http://loinc.org", "1")
                # the event loop is not held while the toolkit works
                ticks = 0

                async def tick():
                    nonlocal ticks
                    while True:
                        ticks += 1
                        await asyncio.sleep(0.001)
                ticker = asyncio.ensure_future(tick())
                await fhir.validate_each(self.PATIENTS)
                ticker.cancel()
                self.assertGreater(ticks, 5)
        with tempfile.TemporaryDirectory() as d:
            asyncio.run(main())

    def test_two_processes_answer_twice_as_fast(self):
        """Calls made together with workers=2 take about the time of one each (on two cores)."""
        if (len(os.sched_getaffinity(0)) if hasattr(os, "sched_getaffinity") else os.cpu_count() or 1) < 2:
            self.skipTest("one core")
        work = self.PATIENTS * 2

        def timed(fhir):
            fhir.validate_each(work[:50])
            for server in fhir._servers:
                server.call("validate", {"resources": work[:50]})
            start = time.perf_counter()
            threads = [threading.Thread(target=lambda: fhir.validate(PATIENT) and fhir.raw._call(
                "validate", {"resources": work})) for _ in range(2)]
            for t in threads:
                t.start()
            for t in threads:
                t.join()
            return time.perf_counter() - start
        with Toolkit() as one:
            alone = timed(one)
        with Toolkit(workers=2) as two:
            together = timed(two)
        self.assertLess(together, alone * 0.9, "two processes %.2f s, one %.2f s" % (together, alone))


if __name__ == "__main__":
    unittest.main()
