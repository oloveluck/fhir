"""Typed FHIR models in and out.

The toolkit's values are FHIR JSON: dicts and lists. A program that holds its
resources as objects of a model library gives them as they are, and asks for
answers as objects with `model=`:

    from fhir.resources.R4B.patient import Patient

    fhir.validate(Patient(id="ann", gender="female"))        # an object goes in as its JSON
    fhir.transform(map, response, model=Patient)             # the answer comes back as a Patient

`plain` and `typed` are the two conversions. They know no library by name: an
object is read by the method it has for writing itself as JSON (pydantic 2's
`model_dump_json`, pydantic 1's `json`, fhirclient's `as_json`), a model is
built by the method it has for reading a dict (`model_validate`, `parse_obj`,
else its constructor).
"""
import datetime
import decimal
import json
import os
from typing import Any, Mapping


def _written(method, **options):
    """What a model's JSON-writing method gives, asked without nulls where it takes that."""
    try:
        return method(**options)
    except TypeError:
        return method()


def plain(value: Any) -> Any:
    """A value as plain JSON: dicts, lists, strings, numbers, booleans, None.

    A model object becomes the JSON it writes; a path its text; a date or time
    its ISO text; a Decimal a number. Raises TypeError for anything else.
    """
    if value is None or isinstance(value, (str, bool, int, float)):
        return value
    if isinstance(value, Mapping):
        return {str(k): plain(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [plain(v) for v in value]
    if hasattr(value, "model_dump_json"):                                   # pydantic 2
        return json.loads(_written(value.model_dump_json, exclude_none=True, by_alias=True))
    if callable(getattr(value, "json", None)) and hasattr(value, "dict"):   # pydantic 1
        return json.loads(_written(value.json, exclude_none=True, by_alias=True))
    if callable(getattr(value, "as_json", None)):                           # fhirclient's models
        return plain(value.as_json())
    if isinstance(value, os.PathLike):
        return os.fspath(value)
    if isinstance(value, (datetime.date, datetime.time)):
        return value.isoformat()
    if isinstance(value, decimal.Decimal):
        return int(value) if value == value.to_integral_value() and value.as_tuple().exponent >= 0 else float(value)
    raise TypeError("%s is not FHIR JSON, and has no method that writes it as JSON" % type(value).__name__)


def typed(model: Any, resource: Any) -> Any:
    """A resource (a dict) as an object of `model`; a list of them one by one."""
    if isinstance(resource, list):
        return [typed(model, r) for r in resource]
    for reader in ("model_validate", "parse_obj"):
        if hasattr(model, reader):
            return getattr(model, reader)(resource)
    return model(resource)
