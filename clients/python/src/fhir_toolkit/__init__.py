"""The FHIR toolkit from Python: FHIR and its languages (FSH, CQL, FHIRPath, the
mapping language, VCL, SQL on FHIR views) compiled, checked, run and validated.

    from fhir_toolkit import Toolkit

    with Toolkit() as fhir:
        fhir.fhirpath("name.family", patient)

See `Toolkit`.
"""
from ._functions import FUNCTIONS, PROTOCOL
from ._server import COMMAND_VARIABLE, find_command
from .errors import (Diagnostic, FhirError, FhirNotFound, FhirOperationError, FhirProcessError, FhirSourceError,
                     FhirTimeout, FhirUsageError, FhirValidationError, FhirWarning, ToolkitNotFound)
from .models import plain, typed
from .results import CodeCheck, Commit, Compiled, Concept, Match, Outcome, Stage, Table
from .toolkit import Data, Project, Toolkit
from .aio import AsyncToolkit

__version__ = "0.1.0"

__all__ = [
    "Toolkit", "AsyncToolkit", "Project", "Data", "Table", "Compiled", "Outcome", "Stage", "Commit", "CodeCheck", "Concept", "Match",
    "plain", "typed", "Diagnostic", "FhirError", "FhirUsageError", "FhirSourceError", "FhirOperationError", "FhirNotFound",
    "FhirValidationError", "FhirProcessError", "FhirTimeout", "FhirWarning", "ToolkitNotFound",
    "find_command", "COMMAND_VARIABLE", "FUNCTIONS", "PROTOCOL", "__version__",
]
