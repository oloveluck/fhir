"""What the toolkit says when something is wrong."""
import os
import sys
import warnings
from dataclasses import dataclass
from typing import Any, Dict, Iterable, List, Optional


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


class FhirWarning(UserWarning):
    """Something the toolkit did that a caller should know, though the call was answered.

    A value of the data that is not valid FHIR and was not read (a date its
    month lacks, a time without a time zone), an element the FHIR version
    read does not have. Python shows each once per place by default; see the
    `warnings` module to make them errors (`warnings.simplefilter("error",
    FhirWarning)`) or to silence them.
    """


class FhirUsageError(FhirError, ValueError):
    """A call the toolkit does not take: an argument it has no use for, a value of the wrong kind,
    a function it does not have. The message says what it takes."""


class FhirSourceError(FhirError):
    """A source given had errors in it (FSH, CQL, a map, a view …): `diagnostics` says each, at its
    file, line and column."""


class FhirOperationError(FhirError):
    """An operation refused what it was asked: `outcome` is FHIR's OperationOutcome, `issue_code`
    its first issue's code ("not-found", "invalid", "processing" …)."""

    @property
    def issue_code(self) -> Optional[str]:
        issues = (self.outcome or {}).get("issue") or [{}]
        return issues[0].get("code")


class FhirNotFound(FhirOperationError, LookupError):
    """What a call names is not here: a value set, a code system, a ConceptMap, a profile that no
    package in context and nothing in the project defines (or a code its code system lacks)."""


class FhirValidationError(FhirError):
    """A resource was refused by validation, so nothing was written (`write`) or `raise_for_errors`
    was asked: `outcome` holds every issue, and `result` the `Outcome` or `Stage`."""


class FhirProcessError(FhirError):
    """The toolkit's process ended, or could not be started. The next call starts it again."""


class FhirTimeout(FhirProcessError, TimeoutError):
    """A call took longer than the Toolkit's `timeout`: its process was stopped."""


class ToolkitNotFound(FhirProcessError):
    """No toolkit to start: neither bundled with this package, nor on the PATH."""


def failure(message: str, code: Optional[int], data: Dict[str, Any]) -> FhirError:
    """The error a server's failure is, by what it carries: a call it does not take, problems in
    a source, an operation's refusal (not found, or another)."""
    diagnostics = [Diagnostic.from_json(d) for d in data.get("diagnostics", [])]
    outcome = data.get("outcome")
    if code in (-32600, -32601, -32602):
        kind = FhirUsageError
    elif diagnostics:
        kind = FhirSourceError
    elif outcome is not None:
        first = ((outcome.get("issue") or [{}])[0]).get("code")
        kind = FhirNotFound if first == "not-found" else FhirOperationError
    else:
        kind = FhirError
    return kind(message, diagnostics=diagnostics, outcome=outcome, code=code)


_HERE = os.path.dirname(os.path.abspath(__file__))


def warn(messages: Iterable[str]) -> None:
    """Each message as a FhirWarning at the caller's own line (the first frame outside this package)."""
    depth, frame = 1, sys._getframe(1)
    while frame is not None and os.path.dirname(os.path.abspath(frame.f_code.co_filename)) == _HERE:
        depth, frame = depth + 1, frame.f_back
    for message in messages:
        warnings.warn(message, FhirWarning, stacklevel=depth + 1)
