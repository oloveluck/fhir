#!/usr/bin/env python3
"""Validation, compared: what each validator refuses, and how long each takes.

    python clients/python/bench/validation.py [--us-core <hl7.fhir.us.core.tgz>] [--hl7-validator <validator_cli.jar>]

The data is a published implementation guide's own: the 230 example resources of US Core 9.0.0,
which claim its profiles (the package is vendored in this repository's fhir-spec/).

Three validators, as a Python program meets them:
  fhir-toolkit     this package: the base specification, and the profiles a resource claims
  fhir.resources   pydantic models of the base specification (optional: pip install fhir.resources)
  HL7's validator  the reference implementation, a Java program run as a process (optional: the
                   path of validator_cli.jar; it needs Java and reads the packages it has cached)

Two things are printed. First what each refuses: one published example changed in ONE way, eight
ways, each a mistake of a different kind. Then the time: the whole guide's examples checked.
Numbers move with the machine; compare runs made on one machine, one after the other.
"""
import argparse
import copy
import json
import os
import pathlib
import re
import shutil
import subprocess
import tarfile
import tempfile
import time

from fhir_toolkit import Toolkit

try:
    from fhir.resources.R4B import get_fhir_model_class
except ImportError:                                    # pragma: no cover
    get_fhir_model_class = None

HERE = pathlib.Path(__file__).resolve().parent
US_CORE = HERE.parents[2] / "fhir-spec" / "hl7.fhir.us.core.tgz"


def examples(package):
    """The package's example resources, by file name."""
    found = {}
    with tarfile.open(package) as archive:
        for member in archive.getmembers():
            if member.name.startswith("package/example/") and member.name.endswith(".json"):
                found[member.name.rsplit("/", 1)[-1]] = json.load(archive.extractfile(member))
    return found


def changed(resource, change):
    copy_ = copy.deepcopy(resource)
    change(copy_)
    return copy_


def probes(found):
    """(what is wrong, the resource): a published example with one mistake, eight kinds of mistake."""
    patient = found["Patient-example.json"]
    pressure = found["Observation-blood-pressure.json"]

    def drop(key):
        return lambda r: r.pop(key)

    def put(key, value):
        return lambda r: r.__setitem__(key, value)

    def other_code(r):
        r["code"]["coding"][0]["code"] = "8480-6"

    return [
        ("a code its required value set does not hold (`gender: florp`)", changed(patient, put("gender", "florp"))),
        ("a day the calendar lacks (`birthDate: 1980-02-30`)", changed(patient, put("birthDate", "1980-02-30"))),
        ("an element the type does not have (`nmae`)", changed(patient, put("nmae", [{"family": "Shaw"}]))),
        ("a value of another type (`active: \"yes\"`)", changed(patient, put("active", "yes"))),
        ("an element the base type requires, left out (an Observation's `status`)", changed(pressure, drop("status"))),
        ("a rule of the base specification broken (a contact with no name, address or telecom: pat-1)",
         changed(patient, put("contact", [{"relationship": [{"text": "friend"}]}]))),
        ("an element the PROFILE requires, left out (a US Core Patient's `name`)", changed(patient, drop("name"))),
        ("a code the PROFILE fixes, changed (a blood pressure's `code`)", changed(pressure, other_code)),
    ]


def model_accepts(resource):
    try:
        get_fhir_model_class(resource["resourceType"]).model_validate(resource)
        return True
    except Exception:
        return False


def hl7_run(jar, resources, package):
    """HL7's validator over the resources: (seconds for the whole run, {name: has an error}, its own
    seconds a resource or None)."""
    folder = pathlib.Path(tempfile.mkdtemp(prefix="hl7-"))
    try:
        for name, resource in resources.items():
            (folder / name).write_text(json.dumps(resource), encoding="utf-8")
        out = folder.with_suffix(".json")
        started = time.perf_counter()
        run = subprocess.run(["java", "-jar", str(jar), str(folder), "-version", "4.0.1", "-ig", str(package), "-tx", "n/a",
                              "-allow-example-urls", "true", "-output", str(out)],
                             env=dict(os.environ, JAVA_TOOL_OPTIONS=""), capture_output=True, text=True, check=False)
        seconds = time.perf_counter() - started
        # its own account of the run: "Times: Loading: 00:59.479, validation: 00:12.414 (#230)"
        own = re.search(r"validation: (\d+):(\d+\.\d+) \(#(\d+)\)", run.stdout)
        each = (int(own.group(1)) * 60 + float(own.group(2))) / int(own.group(3)) if own else None
        answer = json.loads(out.read_text(encoding="utf-8"))
        outcomes = [e["resource"] for e in answer["entry"]] if answer.get("resourceType") == "Bundle" else [answer]
        verdicts = {}
        for outcome in outcomes:
            name = next((x.get("valueString") for x in outcome.get("extension", []) if x.get("url", "").endswith("operationoutcome-file")), None)
            name = pathlib.Path(name).name if name else (next(iter(resources)) if len(resources) == 1 else None)
            verdicts[name] = any(i.get("severity") in ("error", "fatal") for i in outcome.get("issue", []))
        out.unlink()
        return seconds, verdicts, each
    finally:
        shutil.rmtree(folder, ignore_errors=True)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--us-core", default=str(US_CORE), help="the US Core package (.tgz)")
    parser.add_argument("--hl7-validator", help="validator_cli.jar, to run HL7's validator beside the others")
    options = parser.parse_args(argv)
    package = pathlib.Path(options.us_core)
    found = examples(package)
    jar = options.hl7_validator
    said = lambda refused: "refused" if refused else "accepted"

    # ---- what each refuses
    cases = probes(found)
    fhir = Toolkit(packages=[str(package)])
    ours = [not fhir.validate(resource).ok for _, resource in cases]
    models = [not model_accepts(resource) for _, resource in cases] if get_fhir_model_class else None
    theirs = None
    if jar:
        _, verdicts, _ = hl7_run(jar, {"probe-%d.json" % i: r for i, (_, r) in enumerate(cases)}, package)
        theirs = [verdicts.get("probe-%d.json" % i) for i in range(len(cases))]
    print("| one published example, with | fhir-toolkit | fhir.resources | HL7's validator (Java) |")
    print("|---|---|---|---|")
    for i, (what, _) in enumerate(cases):
        print("| %s | %s | %s | %s |" % (what, said(ours[i]), said(models[i]) if models else "—", said(theirs[i]) if theirs and theirs[i] is not None else "—"))
    print()

    # ---- how long each takes
    resources = list(found.values())
    n = len(resources)
    rows = []
    started = time.perf_counter()
    fresh = Toolkit(packages=[str(package)])
    outcomes = fresh.validate_each(resources)
    whole = time.perf_counter() - started
    started = time.perf_counter()
    again = fresh.validate_each(resources)
    warm = time.perf_counter() - started
    fresh.close()
    rows.append(("fhir-toolkit", "the base specification and the US Core profiles each claims",
                 "%.1f s" % whole, "%.1f ms" % (warm / n * 1000), "%d of %d" % (sum(1 for o in again if o.ok), n)))
    if get_fhir_model_class:
        started = time.perf_counter()
        accepted = sum(1 for r in resources if model_accepts(r))
        seconds = time.perf_counter() - started
        rows.append(("fhir.resources", "the base specification's shape (its R4B models)", "%.1f s" % seconds,
                     "%.1f ms" % (seconds / n * 1000), "%d of %d" % (accepted, n)))
    if jar:
        seconds, verdicts, each = hl7_run(jar, found, package)
        rows.append(("HL7's validator (Java)", "the base specification and the US Core profiles each claims",
                     "%.0f s" % seconds, "%.0f ms" % (each * 1000) if each else "—",
                     "%d of %d" % (sum(1 for bad in verdicts.values() if not bad), n)))
    print("| US Core's %d published examples, checked by | against | the whole run, from nothing | a resource, once running | passed |" % n)
    print("|---|---|---|---|---|")
    for row in rows:
        print("| %s |" % " | ".join(row))
    assert all(o.ok for o in outcomes) == all(o.ok for o in again)
    fhir.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
