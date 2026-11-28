#!/usr/bin/env python3
"""Write src/agentfhir/_functions.py from ../functions.json.

clients/functions.json is the toolkit's table of functions (written by
`raco fhir-api functions --json`). This script turns it into one Python method
per function, so the client cannot drift from the server: run it after the
table changes. `--check` writes nothing and exits 1 when the file is stale.
"""
import json
import keyword
import pathlib
import sys
import textwrap

HERE = pathlib.Path(__file__).resolve().parent
TABLE = HERE.parent / "functions.json"
TARGET = HERE / "src" / "agentfhir" / "_functions.py"

HEADER = '''"""The toolkit's functions, one method each. GENERATED: do not edit.

Written by clients/python/generate.py from clients/functions.json, the table
the function server answers from (`raco fhir-api functions`). Each method sends
its arguments as they are and returns the server's answer as plain JSON values;
`agentfhir.FhirContext` builds the friendlier interface on top.
"""
from typing import Any, Dict, Optional

PROTOCOL = {protocol}
FUNCTIONS = {names!r}


class Functions:
    """One method per function of the table. A subclass provides `_call`."""

    def _call(self, name: str, arguments: Dict[str, Any]) -> Any:
        raise NotImplementedError
'''


def python_name(name):
    """A parameter's name in Python: `as` is a keyword, so it is `as_`."""
    return name + "_" if keyword.iskeyword(name) else name


def annotation(schema):
    if "anyOf" in schema:
        return "Any"
    if schema.get("type") == "string":
        return "str"
    if schema.get("type") == "boolean":
        return "bool"
    if schema.get("type") == "object":
        return "Dict[str, str]" if "additionalProperties" in schema else "Dict[str, Any]"
    return "Any"


def wrapped(text, indent):
    return textwrap.fill(text, width=96, initial_indent=indent, subsequent_indent=indent + "    ")


def method(function):
    schema = function["parameters"]
    required = [p for p in function["order"] if p in schema["required"]]
    optional = [p for p in function["order"] if p not in schema["required"]]
    signature = ["self"]
    signature += ["%s: %s" % (python_name(p), annotation(schema["properties"][p])) for p in required]
    if optional:
        signature.append("*")
        signature += ["%s: Optional[%s] = None" % (python_name(p), annotation(schema["properties"][p])) for p in optional]
    lines = ["", "    def %s(%s) -> Any:" % (function["name"], ", ".join(signature))]
    lines.append(textwrap.fill(function["summary"], width=96, initial_indent='        """', subsequent_indent="        "))
    if function["order"]:
        lines += ["", "        Args:"]
        lines += [wrapped("%s: %s" % (python_name(p), schema["properties"][p]["description"]), "            ")
                  for p in function["order"]]
    lines += ["", "        Returns:", wrapped(function["returns"], "            "), '        """']
    if function["order"]:
        lines.append("        arguments = {")
        lines += ["            %r: %s," % (p, python_name(p)) for p in function["order"]]
        lines.append("        }")
        lines.append("        return self._call(%r, {k: v for k, v in arguments.items() if v is not None})" % function["name"])
    else:
        lines.append("        return self._call(%r, {})" % function["name"])
    return "\n".join(lines)


def generated():
    table = json.loads(TABLE.read_text(encoding="utf-8"))
    names = [f["name"] for f in table["functions"]]
    return HEADER.format(protocol=table["protocol"], names=names) + "\n".join(method(f) for f in table["functions"]) + "\n"


def main(argv):
    text = generated()
    if "--check" in argv:
        if not TARGET.exists() or TARGET.read_text(encoding="utf-8") != text:
            print("%s is not what clients/functions.json generates: run clients/python/generate.py" % TARGET, file=sys.stderr)
            return 1
        return 0
    TARGET.write_text(text, encoding="utf-8")
    print("wrote %s (%d functions)" % (TARGET.relative_to(HERE), len(json.loads(TABLE.read_text())["functions"])))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
