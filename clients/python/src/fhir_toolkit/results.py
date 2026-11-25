"""What the toolkit's functions answer, as Python values."""
from typing import Callable, Any, Dict, Iterator, List, Optional

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


class Stage:
    """A write prepared and not yet made: what would be created or changed, and every problem.

    `changes` is one entry per resource: `resource` (Type/id), `action` (create,
    update, unchanged), `changed` (an update's paths, each `path: old → new`),
    `errors` and `warnings`. `id` names the stage for `commit` (None when
    nothing differs, or when it was a check only).
    """

    def __init__(self, js: Dict[str, Any], commit: Optional[Callable[..., "Commit"]] = None):
        self.raw = js
        self.id: Optional[str] = js.get("stage")
        self.changes: List[Dict[str, Any]] = list(js.get("changes", []))
        self._commit = commit

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
            raise FhirError("\n".join(self.errors))
        return self

    def commit(self, reason: Optional[str] = None, *, agent: Optional[str] = None) -> "Commit":
        """Write this stage to the data it was staged for, with its trail."""
        if self._commit is None or self.id is None:
            raise FhirError("nothing to commit: " + ("the stage was a check only, or nothing differs from the data"
                                                    if self.ok else "the stage has errors"))
        return self._commit(reason=reason, agent=agent)

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
