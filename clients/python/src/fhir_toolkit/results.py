"""What the toolkit's functions answer, as Python values."""
from typing import Any, Dict, Iterator, List, Optional

from .errors import Diagnostic, FhirError


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

    def to_pandas(self):
        """The rows as a pandas DataFrame, columns in the table's order."""
        try:
            import pandas
        except ImportError as e:  # pragma: no cover - said when pandas is absent
            raise ImportError("Table.to_pandas() needs pandas: pip install pandas") from e
        return pandas.DataFrame(self.rows, columns=self.columns)

    def __repr__(self) -> str:
        return "Table(kind=%r, columns=%r, rows=%d)" % (self.kind, self.columns, len(self.rows))


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
            raise FhirError("\n".join(str(d) for d in self.errors), diagnostics=self.errors, result=self)
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
            raise FhirError("\n".join(self.messages()), outcome=self.resource)
        return self

    def __repr__(self) -> str:
        return "Outcome(ok=%r, errors=%d, warnings=%d)" % (self.ok, len(self.errors), len(self.warnings))
