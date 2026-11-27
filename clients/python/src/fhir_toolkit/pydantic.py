"""pydantic models held to FHIR by the toolkit.

pydantic checks the shape a model's fields declare. FHIR asks more of a resource: a code its
value set holds, a date the calendar has, the rules of the base specification, and whatever a
profile adds (US Core's Patient must have a name and an identifier). These put the toolkit's
validation, and FHIRPath, where pydantic runs its own:

    from typing import Annotated
    from pydantic import BaseModel
    from fhir.resources.R4B.patient import Patient
    from fhir_toolkit.pydantic import Valid, Holds, checked

    class Intake(BaseModel):                        # a field of any model, held to FHIR
        patient: Annotated[Patient, Valid(), Holds("birthDate.exists()", "a birth date is required")]

    USCorePatient = checked(Patient, "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient")

What is wrong is a pydantic `ValidationError` like any other: one error for each FHIR issue,
its `loc` the element (`("patient", "name", 0, "family")`), its `type` `fhir_` and the issue's
code. The value may be an object of a FHIR model library, a model of your own that writes FHIR
JSON, or a dict.

Each validation is one call of the toolkit (a fifth of a millisecond and the resource's own
work): negligible beside a request, noticeable in a loop over thousands, where
`Toolkit.validate_each` checks them all in one call.

This module needs pydantic 2.
"""
import re
from typing import Any, ClassVar, List, Optional, Tuple

from pydantic import GetCoreSchemaHandler, ValidationError, model_validator
from pydantic_core import InitErrorDetails, PydanticCustomError, core_schema

from .models import plain
from .results import Outcome
from .toolkit import ProjectLike, Toolkit

__all__ = ["Valid", "Holds", "checked", "use", "errors_of"]

_default: Optional[Toolkit] = None


def use(toolkit: Optional[Toolkit]) -> Optional[Toolkit]:
    """The Toolkit that `Valid`, `Holds` and `checked` ask when they were given none.

    Without this, one is made the first time it is needed: FHIR 4.0.1 and no package. Give
    one made for another version, or with an implementation guide's packages in context.
    """
    global _default
    _default = toolkit
    return toolkit


def _toolkit(given: Optional[Toolkit]) -> Toolkit:
    global _default
    if given is not None:
        return given
    if _default is None:
        _default = Toolkit()
    return _default


# ---- a FHIR issue as a pydantic error ---------------------------------------------------------
_STEP = re.compile(r"^([^\[\]]+)((?:\[\d+\])*)$")


def location(expression: str, root: Optional[str] = None) -> Optional[Tuple[Any, ...]]:
    """Where a FHIR issue is, as pydantic says where: `Patient.name[0].given` is
    ("name", 0, "given"). The resource's own type at the front is left out.

    None for a path rooted elsewhere than the resource (`HumanName.given`): the toolkit says
    where an issue is in the instance (`Patient.name[0].given[1]`); a path of the definition is
    left for the rare issue the walk cannot place (an invariant, a slice's own rule).
    """
    steps = [s for s in expression.split(".") if s]
    if steps and steps[0][:1].isupper():
        if root is not None and steps[0] != root:
            return None
        steps = steps[1:]
    loc: List[Any] = []
    for step in steps:
        found = _STEP.match(step)
        if not found:
            loc.append(step)
            continue
        loc.append(found.group(1))
        loc.extend(int(i) for i in re.findall(r"\[(\d+)\]", found.group(2)))
    return tuple(loc)


def _at(value: Any, loc: Tuple[Any, ...]) -> Any:
    """What a resource (as plain JSON) holds at a location; None where it holds nothing there."""
    for step in loc:
        if isinstance(step, int) and isinstance(value, list) and step < len(value):
            value = value[step]
        elif isinstance(value, dict) and step in value:
            value = value[step]
        else:
            return None
    return value


def errors_of(outcome: Outcome, value: Any = None) -> List[InitErrorDetails]:
    """An outcome's errors as pydantic's: `ValidationError.from_exception_data(title, errors_of(outcome, resource))`."""
    try:
        resource = plain(value) if value is not None else None
    except TypeError:
        resource = None
    root = resource.get("resourceType") if isinstance(resource, dict) else None
    details = []
    for issue in outcome.errors:
        where = (issue.get("expression") or issue.get("location") or [""])[0]
        loc = location(where, root)
        kind = "fhir_" + re.sub(r"[^a-z0-9]+", "_", str(issue.get("code") or "invalid").lower())
        message = str(issue.get("diagnostics") or issue.get("code") or "invalid")
        if loc is None:                 # inside a datatype: the path goes with the message
            loc, message = (), "%s: %s" % (where, message)
        message = message.replace("{", "{{").replace("}", "}}")
        details.append(InitErrorDetails(type=PydanticCustomError(kind, message), loc=loc, input=_at(resource, loc)))
    return details


def _title(value: Any) -> str:
    if isinstance(value, dict):
        return str(value.get("resourceType") or "resource")
    return type(value).__name__


# ---- the annotations ----------------------------------------------------------------------------
class Valid:
    """A value that is valid FHIR: `Annotated[Patient, Valid()]`, `Annotated[dict, Valid(profile)]`.

    The value is held to its resource type, to the profiles it claims and to `profile` (a
    canonical, or the id or name of a profile `project` defines), after pydantic has read it.
    `toolkit` is the Toolkit to ask (see `use`); `project` the FSH, value sets and the like
    that the profile comes from.
    """

    def __init__(self, profile: Optional[str] = None, *, toolkit: Optional[Toolkit] = None, project: ProjectLike = None):
        self.profile = profile
        self.toolkit = toolkit
        self.project = project

    def check(self, value: Any) -> Any:
        outcome = _toolkit(self.toolkit).validate(value, self.profile, project=self.project)
        if not outcome.ok:
            raise ValidationError.from_exception_data(_title(value), errors_of(outcome, value))
        return value

    def __get_pydantic_core_schema__(self, source: Any, handler: GetCoreSchemaHandler) -> core_schema.CoreSchema:
        return core_schema.no_info_after_validator_function(self.check, handler(source))

    def __repr__(self) -> str:
        return "Valid(%s)" % ("" if self.profile is None else repr(self.profile))


class Holds:
    """A value of which a FHIRPath expression is true: `Annotated[Patient, Holds("name.family.exists()")]`.

    The expression holds when its answer is the one value `true`; anything else (false,
    nothing, several values) is an error of type `fhir_invariant`, with `message` or the
    expression and what it answered.
    """

    def __init__(self, expression: str, message: Optional[str] = None, *, toolkit: Optional[Toolkit] = None):
        self.expression = expression
        self.message = message
        self.toolkit = toolkit

    def check(self, value: Any) -> Any:
        values = _toolkit(self.toolkit).fhirpath(self.expression, value)
        if values != [True]:
            said = self.message or "`%s` does not hold (it answered %s)" % (self.expression, "nothing" if values == [] else repr(values)[:80])
            raise PydanticCustomError("fhir_invariant", said.replace("{", "{{").replace("}", "}}"))
        return value

    def __get_pydantic_core_schema__(self, source: Any, handler: GetCoreSchemaHandler) -> core_schema.CoreSchema:
        return core_schema.no_info_after_validator_function(self.check, handler(source))

    def __repr__(self) -> str:
        return "Holds(%r)" % self.expression


def checked(model: Any = None, profile: Optional[str] = None, *, toolkit: Optional[Toolkit] = None,
            project: ProjectLike = None) -> Any:
    """A pydantic model class whose every object is valid FHIR.

        USCorePatient = checked(Patient, "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient")

        @checked(profile="IntakePatient", project={"intake.fsh": fsh})     # as a decorator
        class IntakePatient(Patient):
            pass

    The class answered is a subclass of `model`, of the same name: making an object of it, or
    reading one (`model_validate`, `model_validate_json`), runs the toolkit's validation after
    pydantic's own, and what is wrong is raised as pydantic's `ValidationError`.
    """
    if model is None or isinstance(model, str):
        stated = profile if model is None else model
        return lambda decorated: checked(decorated, stated, toolkit=toolkit, project=project)
    valid = Valid(profile, toolkit=toolkit, project=project)

    def held_to_fhir(self: Any) -> Any:
        return valid.check(self)

    return type(model.__name__, (model,), {
        "__module__": model.__module__,
        "__qualname__": getattr(model, "__qualname__", model.__name__),
        "__doc__": model.__doc__,
        "__annotations__": {"fhir_profile": ClassVar[Optional[str]]},
        "fhir_profile": profile,
        "_held_to_fhir": model_validator(mode="after")(held_to_fhir),
    })
