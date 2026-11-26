#!/usr/bin/env python3
"""fhirpathpy asked one expression at a time, for bench/fhirpath-suite.rkt.

It decides nothing: each line of standard input is a job {"id", "expression", "input"} (input: the
path of a JSON resource, or null); each line written is {"id", "values": [{"kind", "text"}, ...]} or
{"id", "error": message}. Which answers are right is the Racket program's to say.
"""
import decimal
import json
import sys

import fhirpathpy
from fhirpathpy.models import models

MODEL = models[sys.argv[1] if len(sys.argv) > 1 else "r4"]
out = sys.stdout
sys.stdout = sys.stderr                             # what the library prints (trace()) is no answer
resources = {}


def resource(path):
    if path is None:
        return {}
    if path not in resources:
        with open(path, encoding="utf-8") as f:
            resources[path] = json.load(f)
    return resources[path]


def shown(value):
    """A value as its kind and text, as a FHIRPath literal would write it."""
    if isinstance(value, bool):
        return {"kind": "boolean", "text": "true" if value else "false"}
    if isinstance(value, int):
        return {"kind": "integer", "text": str(value)}
    if isinstance(value, (float, decimal.Decimal)):
        return {"kind": "decimal", "text": format(decimal.Decimal(str(value)), "f")}
    if isinstance(value, str):
        return {"kind": "string", "text": value}
    if isinstance(value, (dict, list)):
        return {"kind": "complex", "text": json.dumps(value, sort_keys=True)[:200]}
    name = type(value).__name__
    kind = {"FP_DateTime": "temporal", "FP_Date": "temporal", "FP_Time": "time", "FP_Quantity": "quantity"}.get(name, name)
    return {"kind": kind, "text": str(value)}


for line in sys.stdin:
    job = json.loads(line)
    try:
        values = fhirpathpy.evaluate(resource(job["input"]), job["expression"], {}, MODEL)
        answer = {"id": job["id"], "values": [shown(v) for v in values]}
    except BaseException as e:                       # a parse error, a function it lacks, a crash
        if isinstance(e, KeyboardInterrupt):
            raise
        answer = {"id": job["id"], "error": "%s: %s" % (type(e).__name__, str(e)[:200])}
    out.write(json.dumps(answer) + "\n")
    out.flush()
