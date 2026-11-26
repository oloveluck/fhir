#!/usr/bin/env python3
"""How long the toolkit takes from Python, beside two pure-Python libraries.

    python clients/python/bench/compare.py [--resources 5000] [--calls 300]

Each row is one task done each way, the median time of several runs. The other
libraries are optional: a row is left out when its library is not installed
(`pip install fhirpathpy fhir.resources`). They do not all do the same work —
the notes under the table say where — so read a row as "what this task costs
with each", not as one engine against another.

Numbers move with the machine: compare runs made on one machine, one after
the other.
"""
import argparse
import os
import statistics
import sys
import time

from fhir_toolkit import Toolkit

try:
    import fhirpathpy
except ImportError:                                    # pragma: no cover
    fhirpathpy = None
try:
    from fhir.resources.R4B.observation import Observation
    from fhir.resources.R4B.patient import Patient
except ImportError:                                    # pragma: no cover
    Observation = Patient = None


def median_ms(thunk, runs):
    """The median time of `runs` calls of thunk(i), in milliseconds."""
    times = []
    for i in range(runs):
        started = time.perf_counter()
        thunk(i)
        times.append(time.perf_counter() - started)
    return statistics.median(times) * 1000


def patient(i, gender="female", born="1980-02-28"):
    return {"resourceType": "Patient", "id": "p%d" % i, "gender": gender, "birthDate": born,
            "name": [{"family": "Lee%d" % i, "given": ["Ann"]}]}


def observation(i):
    return {"resourceType": "Observation", "id": "o%d" % i, "status": "final",
            "code": {"coding": [{"system": "http://loinc.org", "code": "4548-4"}]},
            "subject": {"reference": "Patient/p%d" % (i % 50)}, "effectiveDateTime": "2025-03-01",
            "valueQuantity": {"value": 5 + (i % 60) / 10, "unit": "%", "system": "http://unitsofmeasure.org", "code": "%"}}


def shown(ms):
    if ms is None:
        return "—"
    return "%.0f ms" % ms if ms >= 20 else "%.2f ms" % ms if ms >= 0.1 else "%.3f ms" % ms


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--resources", type=int, default=5000, help="how many resources the tasks over many read")
    parser.add_argument("--calls", type=int, default=300, help="how many times a single call is timed")
    options = parser.parse_args(argv)
    n, calls = options.resources, options.calls
    rows = []                                           # (task, toolkit, fhirpathpy, fhir.resources)

    started = time.perf_counter()
    fhir = Toolkit()
    made = (time.perf_counter() - started) * 1000
    fhir.fhirpath("name.family", patient(0))
    first = (time.perf_counter() - started) * 1000
    rows.append(("Toolkit() returns; then the first answer", "%s; %s" % (shown(made), shown(first)), "no start", "no start"))
    fhir.close()
    # a first validation reads the definitions too: asked of a new process, at once
    started = time.perf_counter()
    fhir = Toolkit()
    assert fhir.validate(patient(0)).ok
    rows.append(("A new Toolkit's first validation", shown((time.perf_counter() - started) * 1000), "no start", "no start"))

    expression = "name.given.first() + ' ' + name.family.first()"
    path = fhirpathpy.compile(expression) if fhirpathpy else None
    assert fhir.fhirpath(expression, patient(1)) == ["Ann Lee1"]
    rows.append(("One FHIRPath expression, one Patient",
                 shown(median_ms(lambda i: fhir.fhirpath(expression, patient(i)), calls)),
                 shown(median_ms(lambda i: path(patient(i)), calls)) if path else None, None))

    patients = [patient(i) for i in range(n)]
    each = fhir.fhirpath_each(expression, patients)
    assert len(each) == n and each[7] == ["Ann Lee7"]
    rows.append(("The same expression over %d Patients" % n,
                 shown(median_ms(lambda i: fhir.fhirpath_each(expression, patients), 5)) + " (one call)",
                 shown(median_ms(lambda i: [path(p) for p in patients], 5)) + " (a loop)" if path else None, None))

    rows.append(("Validate one Patient",
                 shown(median_ms(lambda i: fhir.validate(patient(i)), calls)), None,
                 shown(median_ms(lambda i: Patient.model_validate(patient(i)), calls)) if Patient else None))
    assert all(fhir.validate_each(patients[:20]))
    rows.append(("Validate %d Patients" % n,
                 shown(median_ms(lambda i: fhir.validate_each(patients), 3)) + " (one call)", None,
                 shown(median_ms(lambda i: [Patient.model_validate(p) for p in patients], 3)) + " (a loop)" if Patient else None))

    workers = os.cpu_count() or 1
    if workers > 1:
        shared = Toolkit(workers=min(workers, 4))
        assert all(shared.validate_each(patients))          # (every worker has started and validated)
        rows.append(("…with `Toolkit(workers=%d)`" % min(workers, 4),
                     shown(median_ms(lambda i: shared.validate_each(patients), 3)) + " (one call)", None, None))
        shared.close()
    if Patient:
        objects = [Patient.model_validate(p) for p in patients]
        rows.append(("…the Patients given as `fhir.resources` objects",
                     shown(median_ms(lambda i: fhir.validate_each(objects), 3)) + " (one call)", None,
                     shown(median_ms(lambda i: [o.model_dump_json(exclude_none=True) for o in objects], 3)) + " (writing them as JSON)"))

    observations = [observation(i) for i in range(n)]
    view = "SELECT id, value.ofType(Quantity).value AS percent FROM Observation"
    assert len(fhir.view(view, observations)) == n
    value = fhirpathpy.compile("valueQuantity.value") if fhirpathpy else None
    rows.append(("One value from each of %d Observations" % n,
                 shown(median_ms(lambda i: fhir.view(view, observations), 5)) + " (a view)",
                 shown(median_ms(lambda i: [value(o) for o in observations], 5)) + " (a loop)" if value else None,
                 shown(median_ms(lambda i: [Observation.model_validate(o).valueQuantity.value for o in observations], 5)) + " (a loop)"
                 if Observation else None))
    started = time.perf_counter()
    loaded = fhir.load(observations)
    load_ms = (time.perf_counter() - started) * 1000
    # a view over loaded data is computed once and kept, so each timing asks a view not asked before
    fresh = ["SELECT id, value.ofType(Quantity).value AS percent%d FROM Observation" % i for i in range(5)]
    assert len(fhir.view(view, loaded)) == n
    rows.append(("…the same, the data loaded once (%s)" % shown(load_ms),
                 shown(median_ms(lambda i: fhir.view(fresh[i], loaded), 5)) + " (a view)", None, None))
    rows.append(("…and that view asked again",
                 shown(median_ms(lambda i: fhir.view(view, loaded), 5)), None, None))
    count = "SELECT count(*) AS n, avg(percent) AS mean FROM results WHERE percent > 9"
    views = {"results.sof": "CREATE VIEW results WITH (status = 'active') AS " + view}
    assert fhir.sql(count, project=views, data=loaded).rows[0]["n"] > 0
    rows.append(("A SQL aggregate over that view, data loaded",
                 shown(median_ms(lambda i: fhir.sql(count, project=views, data=loaded), 5)), None, None))

    print("| task | fhir-toolkit | fhirpathpy | fhir.resources |")
    print("|---|---|---|---|")
    for task, ours, theirs, models in rows:
        print("| %s | %s | %s | %s |" % (task, ours or "—", theirs or "—", models or "—"))

    print()
    print("What each refuses (validation is not the same work in each):")
    wrong = {"a gender no value set holds": patient(1, gender="florp"), "a date the calendar lacks": patient(1, born="1980-02-30")}
    for what, resource in wrong.items():
        ours = "refused" if not fhir.validate(resource).ok else "accepted"
        if Patient:
            try:
                Patient.model_validate(resource)
                theirs = "accepted"
            except Exception:
                theirs = "refused"
        else:
            theirs = "—"
        print("  %s: fhir-toolkit %s, fhir.resources %s" % (what, ours, theirs))
    fhir.close()
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
