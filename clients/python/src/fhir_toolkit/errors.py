"""What the toolkit says when something is wrong."""
from dataclasses import dataclass
from typing import Any, Dict, List, Optional


@dataclass(frozen=True)
class Diagnostic:
    """One problem, at its place in a source text.

    `source` is a file of the project by its name there; `line` and `column`
    count from 1. Any of the three may be None when the problem has no place.
    """

    severity: str
    message: str
    lang: Optional[str] = None
    phase: Optional[str] = None
    source: Optional[str] = None
    line: Optional[int] = None
    column: Optional[int] = None

    @classmethod
    def from_json(cls, js: Dict[str, Any]) -> "Diagnostic":
        return cls(
            severity=js.get("severity", "error"),
            message=js.get("message", ""),
            lang=js.get("lang"),
            phase=js.get("phase"),
            source=js.get("source"),
            line=js.get("line"),
            column=js.get("column"),
        )

    @property
    def is_error(self) -> bool:
        return self.severity == "error"

    def __str__(self) -> str:
        where = self.source or ""
        if self.line is not None:
            where += ":%d" % self.line
            if self.column is not None:
                where += ":%d" % self.column
        return "%s%s%s: %s" % (where, ": " if where else "", self.severity, self.message)


class FhirError(Exception):
    """A call the toolkit could not answer, or an answer with errors in it.

    Attributes:
        diagnostics: the problems that have a place in a source text, if any.
        outcome: the FHIR OperationOutcome, when an operation refused.
        code: the protocol's error code, when the server refused the call.
        result: what was produced all the same (a `Compiled`), when there is one.
    """

    def __init__(self, message: str, *, diagnostics: Optional[List[Diagnostic]] = None,
                 outcome: Optional[Dict[str, Any]] = None, code: Optional[int] = None, result: Any = None):
        super().__init__(message)
        self.diagnostics = diagnostics or []
        self.outcome = outcome
        self.code = code
        self.result = result


class ToolkitNotFound(FhirError):
    """No toolkit to start: neither bundled with this package, nor on the PATH."""
