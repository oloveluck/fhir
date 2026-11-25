"""The FHIR toolkit from Python: FHIR and its languages (FSH, CQL, FHIRPath, the
mapping language, VCL, SQL on FHIR views) compiled, checked, run and validated.

    from fhir_toolkit import Toolkit

    with Toolkit() as fhir:
        fhir.fhirpath("name.family", patient)

See `Toolkit`.
"""
from ._functions import FUNCTIONS, PROTOCOL
from ._server import COMMAND_VARIABLE, find_command
from .errors import Diagnostic, FhirError, ToolkitNotFound
from .results import Compiled, Outcome, Table
from .toolkit import Project, Toolkit

__version__ = "0.1.0"

__all__ = [
    "Toolkit", "Project", "Table", "Compiled", "Outcome", "Diagnostic", "FhirError", "ToolkitNotFound",
    "find_command", "COMMAND_VARIABLE", "FUNCTIONS", "PROTOCOL", "__version__",
]
