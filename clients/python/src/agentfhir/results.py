"""What the engine's functions answer, as Python values."""
import csv
import html
import io
import json
from typing import Callable, Any, Dict, Iterator, List, Optional

from .errors import Diagnostic, FhirError, FhirSourceError, FhirUsageError, FhirValidationError


class Table:
    """Rows with named columns: what `run` and `query` answer.

    `columns` are the keys of each row in order, `rows` one dict per row,
    `kind` says what a row is ("patients", "resources", "rows", "table",
    "expansion", "transform") and `summary` holds counts and totals.
    """

    def __init__(self, js: Dict[str, Any]):
        self.kind: str = js.get("kind", "rows")
        self.columns: List[str] = list(js.get("columns", []))
        self.rows: List[Dict[str, Any]] = list(js.get("rows", []))
        self.summary: Dict[str, Any] = js.get("summary") or {}

    def __len__(self) -> int:
        return len(self.rows)

    def __iter__(self) -> Iterator[Dict[str, Any]]:
        return iter(self.rows)

    def __getitem__(self, index):
        return self.rows[index]

    def column(self, name: str) -> List[Any]:
        """One column's values, a None where a row has none."""
        if name not in self.columns:
            raise KeyError("no column %r (the columns: %s)" % (name, ", ".join(self.columns)))
        return [row.get(name) for row in self.rows]

    def to_models(self, model: Any) -> List[Any]:
        """Each row as an object of `model`: a pydantic model (or a dataclass) whose fields are
        the columns. pydantic reads the cells as its fields say (a date from its text)."""
        from .models import typed
        return [typed(model, row) for row in self.rows]

    def resources(self, model: Any = None) -> List[Any]:
        """The FHIR resources behind a search's rows, as FHIR JSON — or, with `model` (a class
        of a model library), as objects of it."""
        from .models import typed
        if "json" not in self.columns and not any("json" in row for row in self.rows):
            raise FhirUsageError("these rows are no resources (a search's rows are; the columns here: %s)" % ", ".join(self.columns))
        found = [row["json"] for row in self.rows if isinstance(row.get("json"), dict)]
        return found if model is None else [typed(model, resource) for resource in found]

    @property
    def notes(self) -> List[str]:
        """What the engine says of the answer besides its rows: values of the data that were
        not read (and why), a define that is null for every patient. Each is also a FhirWarning
        when the table is made."""
        said = []
        for key in ("unread", "notes"):
            value = self.summary.get(key)
            said += [value] if isinstance(value, str) else [v for v in (value or []) if isinstance(v, str)]
        return said

    def to_pandas(self):
        """The rows as a pandas DataFrame, columns in the table's order."""
        try:
            import pandas
        except ImportError as e:  # pragma: no cover - said when pandas is absent
            raise ImportError("Table.to_pandas() needs pandas: pip install pandas") from e
        return pandas.DataFrame(self.rows, columns=self.columns)

    def to_polars(self):
        """The rows as a polars DataFrame, columns in the table's order."""
        try:
            import polars
        except ImportError as e:  # pragma: no cover - said when polars is absent
            raise ImportError("Table.to_polars() needs polars: pip install polars") from e
        return polars.DataFrame({c: self.column(c) for c in self.columns})

    def to_csv(self, path: Any = None) -> Optional[str]:
        """The rows as CSV, a header line first: written to `path`, or answered as text without one.

        A cell that is a list or an object is its JSON text; a missing value is empty.
        """
        def cell(value: Any) -> Any:
            return "" if value is None else json.dumps(value, ensure_ascii=False) if isinstance(value, (list, dict)) else value

        def write(out: Any) -> None:
            writer = csv.writer(out, lineterminator="\n")
            writer.writerow(self.columns)
            writer.writerows([cell(row.get(c)) for c in self.columns] for row in self.rows)

        if path is None:
            out = io.StringIO()
            write(out)
            return out.getvalue()
        with open(path, "w", newline="", encoding="utf-8") as out:
            write(out)
        return None

    def __repr__(self) -> str:
        return "Table(kind=%r, columns=%r, rows=%d)" % (self.kind, self.columns, len(self.rows))

    #: how many rows a notebook shows of a table (the rest are counted under it)
    shown_rows = 20

    def _repr_html_(self) -> str:
        """The table as a notebook shows it: its first rows, without pandas."""
        def cell(value: Any) -> str:
            if value is None:
                return ""
            text = value if isinstance(value, str) else json.dumps(value, ensure_ascii=False)
            return html.escape(text if len(text) <= 80 else text[:79] + "…")

        head = "".join("<th>%s</th>" % html.escape(c) for c in self.columns)
        body = "".join("<tr>%s</tr>" % "".join("<td>%s</td>" % cell(row.get(c)) for c in self.columns)
                       for row in self.rows[:self.shown_rows])
        more = len(self.rows) - self.shown_rows
        foot = "<p>%d more rows (%d in all)</p>" % (more, len(self.rows)) if more > 0 else ""
        return "<table><thead><tr>%s</tr></thead><tbody>%s</tbody></table>%s" % (head, body, foot)


class Compiled:
    """What a project's files define, and every problem in them."""

    def __init__(self, js: Dict[str, Any]):
        self.resources: List[Dict[str, Any]] = list(js.get("resources", []))
        self.diagnostics: List[Diagnostic] = [Diagnostic.from_json(d) for d in js.get("diagnostics", [])]

    @property
    def errors(self) -> List[Diagnostic]:
        return [d for d in self.diagnostics if d.is_error]

    @property
    def warnings(self) -> List[Diagnostic]:
        return [d for d in self.diagnostics if d.severity == "warning"]

    @property
    def ok(self) -> bool:
        """No error (warnings do not count)."""
        return not self.errors

    def of_type(self, resource_type: str) -> List[Dict[str, Any]]:
        return [r for r in self.resources if r.get("resourceType") == resource_type]

    def resource(self, resource_type: str, id: Optional[str] = None) -> Dict[str, Any]:
        """The one resource of a type (and id): KeyError when there is none or several."""
        found = [r for r in self.of_type(resource_type) if id is None or r.get("id") == id]
        if len(found) != 1:
            raise KeyError("%d resources of type %s%s" % (len(found), resource_type, "" if id is None else " with id " + id))
        return found[0]

    def raise_for_errors(self) -> "Compiled":
        if self.errors:
            raise FhirSourceError("\n".join(str(d) for d in self.errors), diagnostics=self.errors, result=self)
        return self

    def __iter__(self) -> Iterator[Dict[str, Any]]:
        return iter(self.resources)

    def __len__(self) -> int:
        return len(self.resources)

    def __repr__(self) -> str:
        return "Compiled(resources=%d, errors=%d, warnings=%d)" % (len(self.resources), len(self.errors), len(self.warnings))


class Outcome:
    """A validation's answer: the FHIR OperationOutcome, read."""

    def __init__(self, resource: Dict[str, Any]):
        self.resource = resource
        self.issues: List[Dict[str, Any]] = list(resource.get("issue", []))

    @property
    def errors(self) -> List[Dict[str, Any]]:
        return [i for i in self.issues if i.get("severity") in ("error", "fatal")]

    @property
    def warnings(self) -> List[Dict[str, Any]]:
        return [i for i in self.issues if i.get("severity") == "warning"]

    @property
    def ok(self) -> bool:
        """Valid: no issue is an error (warnings do not count)."""
        return not self.errors

    def __bool__(self) -> bool:
        return self.ok

    def messages(self) -> List[str]:
        """Each error and warning as a line: `Patient.gender: error: …`."""
        lines = []
        for i in self.errors + self.warnings:
            where = (i.get("expression") or i.get("location") or [""])[0]
            lines.append("%s%s%s: %s" % (where, ": " if where else "", i.get("severity"), i.get("diagnostics") or i.get("code")))
        return lines

    def raise_for_errors(self) -> "Outcome":
        if self.errors:
            raise FhirValidationError("\n".join(self.messages()), outcome=self.resource, result=self)
        return self

    def __repr__(self) -> str:
        return "Outcome(ok=%r, errors=%d, warnings=%d)" % (self.ok, len(self.errors), len(self.warnings))

    def __str__(self) -> str:
        """`valid`, or each error and warning on a line."""
        return "\n".join(self.messages()) or "valid"

    def _repr_html_(self) -> str:
        lines = self.messages()
        if not lines:
            return "<p>valid</p>"
        return "<ul>%s</ul>" % "".join("<li>%s</li>" % html.escape(line) for line in lines)


class Stage:
    """A write prepared and not yet made: what would be created or changed, and every problem.

    `changes` is one entry per resource: `resource` (Type/id), `action` (create,
    update, unchanged), `changed` (an update's paths, each `path: old → new`),
    `errors` and `warnings`. `id` names the stage for `commit` (None when
    nothing differs, or when it was a check only).
    """

    def __init__(self, js: Dict[str, Any], commit: Optional[Callable[..., "Commit"]] = None,
                 drop: Optional[Callable[[], None]] = None):
        self.raw = js
        self.id: Optional[str] = js.get("stage")
        self.changes: List[Dict[str, Any]] = list(js.get("changes", []))
        self._commit = commit
        self._drop = drop

    def _lines(self, key: str) -> List[str]:
        return ["%s: %s" % (c.get("resource"), line) for c in self.changes for line in c.get(key, [])]

    @property
    def errors(self) -> List[str]:
        """Each error as a line: `Observation/a2: Observation.status: …`."""
        return self._lines("errors")

    @property
    def warnings(self) -> List[str]:
        return self._lines("warnings")

    @property
    def ok(self) -> bool:
        """Nothing stands in the way of a commit (warnings do not)."""
        return not self.errors

    def __bool__(self) -> bool:
        return self.ok

    def of(self, action: str) -> List[str]:
        """The resources (Type/id) with that action: create, update or unchanged."""
        return [c.get("resource") for c in self.changes if c.get("action") == action]

    def raise_for_errors(self) -> "Stage":
        if self.errors:
            raise FhirValidationError("\n".join(self.errors), result=self)
        return self

    def commit(self, reason: Optional[str] = None, *, agent: Optional[str] = None) -> "Commit":
        """Write this stage to the data it was staged for, with its trail."""
        if self._commit is None or self.id is None:
            raise FhirUsageError("nothing to commit: " + ("the stage was a check only, or nothing differs from the data"
                                                    if self.ok else "the stage has errors"))
        return self._commit(reason=reason, agent=agent)

    def drop(self) -> None:
        """Discard this stage without writing it (nothing happens when there is nothing to drop)."""
        if self._drop is not None:
            self._drop()
            self._drop = self._commit = None

    def __repr__(self) -> str:
        return "Stage(%s, create=%d, update=%d, unchanged=%d, errors=%d)" % (
            self.id, len(self.of("create")), len(self.of("update")), len(self.of("unchanged")), len(self.errors))


class Commit:
    """What a commit wrote: each resource's new version, and the Provenance that records it."""

    def __init__(self, js: Dict[str, Any]):
        self.raw = js
        self.written: List[Dict[str, Any]] = list(js.get("written", []))
        self.provenance: Optional[str] = js.get("provenance")
        self.reason: Optional[str] = js.get("reason")
        self.agent: Optional[str] = js.get("agent")

    @property
    def versions(self) -> List[str]:
        """The versions written, each as `Type/id/_history/n`."""
        return [w.get("version") for w in self.written if w.get("version")]

    def __len__(self) -> int:
        return len(self.written)

    def __repr__(self) -> str:
        return "Commit(%d written, provenance=%s)" % (len(self.written), self.provenance)


# ---- terminology --------------------------------------------------------------------------------

def _value(parameter: Dict[str, Any]) -> Any:
    """A Parameters entry's value: its one value[x], or its parts as a dict of name -> value."""
    for key, value in parameter.items():
        if key.startswith("value"):
            return value
    if "part" in parameter:
        return _params(parameter["part"])
    return parameter.get("resource")


def _params(parameters: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Parameters as a dict: name -> value, a list for a name given more than once."""
    out: Dict[str, Any] = {}
    for p in parameters:
        name, value = p.get("name"), _value(p)
        if name in out:
            out[name] = (out[name] if isinstance(out[name], list) else [out[name]]) + [value]
        else:
            out[name] = value
    return out


def _listed(value: Any) -> List[Any]:
    return [] if value is None else value if isinstance(value, list) else [value]


class CodeCheck:
    """Whether a value set holds a code: what `FhirContext.validate_code` answers.

    It is true when it holds it (`if fhir.validate_code(...)`); `ok` says the same.
    `display` is the code's display where the code system has one, `message` why
    it is not held (or what is wrong with the display given).
    """

    def __init__(self, parameters: Dict[str, Any]):
        p = _params(parameters.get("parameter", []))
        self.ok: bool = p.get("result") is True
        self.code: Optional[str] = p.get("code")
        self.system: Optional[str] = p.get("system")
        self.version: Optional[str] = p.get("version")
        self.display: Optional[str] = p.get("display")
        self.message: Optional[str] = p.get("message")

    def __bool__(self) -> bool:
        return self.ok

    def __repr__(self) -> str:
        said = "held" if self.ok else "not held"
        return "CodeCheck(%s|%s: %s%s)" % (self.system, self.code, said, "" if not self.message else "; " + self.message)


class Concept:
    """A code looked up in its code system: what `FhirContext.lookup` answers.

    `display` and `definition` as the code system gives them; `name` and
    `version` are the code system's; `designations` each a dict of language,
    use and value; `properties` property code -> its value (a list when there
    are several).
    """

    def __init__(self, system: str, code: str, parameters: Dict[str, Any]):
        p = _params(parameters.get("parameter", []))
        self.system = system
        self.code = code
        self.name: Optional[str] = p.get("name")
        self.version: Optional[str] = p.get("version")
        self.display: Optional[str] = p.get("display")
        self.definition: Optional[str] = p.get("definition")
        self.designations: List[Dict[str, Any]] = _listed(p.get("designation"))
        properties: Dict[str, Any] = {}
        for prop in _listed(p.get("property")):
            code_, value = prop.get("code"), prop.get("value")
            if code_ in properties:
                properties[code_] = _listed(properties[code_]) + [value]
            else:
                properties[code_] = value
        self.properties: Dict[str, Any] = properties

    def __repr__(self) -> str:
        return "Concept(%s|%s %r)" % (self.system, self.code, self.display)


class Match:
    """One code a code maps to: what `FhirContext.translate` answers a list of.

    `relationship` is how the source code relates to it ("equivalent",
    "source-is-narrower-than-target", … or R4's "equal", "wider", …). `source` is the
    ConceptMap that made the match (its canonical and version), when no map was named.
    """

    def __init__(self, part: Dict[str, Any]):
        concept = part.get("concept") or {}
        self.relationship: Optional[str] = part.get("relationship") or part.get("equivalence")
        self.system: Optional[str] = concept.get("system")
        self.code: Optional[str] = concept.get("code")
        self.display: Optional[str] = concept.get("display")
        self.source: Optional[str] = part.get("source") or part.get("originMap")

    def coding(self) -> Dict[str, Any]:
        """The code mapped to, as a FHIR Coding."""
        return {k: v for k, v in (("system", self.system), ("code", self.code), ("display", self.display)) if v is not None}

    def __eq__(self, other: Any) -> bool:
        return isinstance(other, Match) and (self.relationship, self.system, self.code) == (other.relationship, other.system, other.code)

    def __repr__(self) -> str:
        return "Match(%s %s|%s)" % (self.relationship, self.system, self.code)
