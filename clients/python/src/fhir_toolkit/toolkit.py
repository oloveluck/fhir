"""The FHIR toolkit from Python.

    from fhir_toolkit import Toolkit

    with Toolkit() as fhir:
        fhir.fhirpath("name.family", patient)             # ['Lee']
        fhir.validate(patient).ok                         # True
        fhir.view("SELECT id, birthDate FROM Patient", data).to_pandas()

A `Toolkit` is one process of the toolkit, started in the background when the
Toolkit is made and kept for every call. A PROJECT is the sources a call may refer to — profiles
in FSH, CQL libraries, maps, value sets in VCL, views, FHIR JSON definitions —
given as a dict of file name -> text, as a directory, or as a `Project`. DATA
is the FHIR a call reads: resources (a list, one resource, a Bundle), or the
path of a directory of FHIR JSON, a JSON file or a SQLite FHIR store, or a FHIR
server's base url. A resource is FHIR JSON (a dict), or an object of a model
library that writes itself as JSON (`fhir_toolkit.models`).

Data used by several calls is given once: `clinic = fhir.load(resources)`, then
`data=clinic`. One question of many resources is one call: `fhirpath_each`,
`validate_each`, or a view.
"""
import atexit
import os
import re
from typing import Any, Dict, List, Mapping, Optional, Sequence, Union

from ._functions import Functions
from ._server import Server
from .errors import Diagnostic, FhirError
from .models import typed
from .results import Commit, Compiled, Outcome, Stage, Table

Resource = Dict[str, Any]
ProjectLike = Union["Project", Mapping[str, str], str, "os.PathLike[str]", None]
DataLike = Union["Data", Sequence[Resource], Resource, str, "os.PathLike[str]", None]


class Project:
    """The sources a call may refer to.

    Either `files` (file name -> text; the name's ending says the language:
    .fsh, .cql, .map, .vcl, .sof, .fhirpath, .json) or a `directory` on disk.
    `canonical` is the base of the canonicals files define when they state none.
    """

    def __init__(self, files: Optional[Mapping[str, str]] = None, *, directory: Union[str, "os.PathLike[str]", None] = None,
                 canonical: Optional[str] = None):
        if files is not None and directory is not None:
            raise ValueError("a project is files or a directory, not both")
        self.files: Optional[Dict[str, str]] = dict(files) if files is not None else None
        self.directory: Optional[str] = os.fspath(directory) if directory is not None else None
        self.canonical = canonical

    def with_file(self, name: str, text: str) -> "Project":
        """This project and one more file (a project of files only)."""
        if self.directory is not None:
            raise ValueError("a project that is a directory takes its files from the directory: write %s there" % name)
        files = dict(self.files or {})
        files[name] = text
        return Project(files, canonical=self.canonical)

    def arguments(self) -> Dict[str, Any]:
        """The project as the functions' `files`, `directory` and `canonical`."""
        return {"files": self.files, "directory": self.directory, "canonical": self.canonical}


def as_project(project: ProjectLike) -> Project:
    if project is None:
        return Project()
    if isinstance(project, Project):
        return project
    if isinstance(project, Mapping):
        return Project(project)
    return Project(directory=project)


class Data:
    """Data given to the toolkit once and kept there: what `Toolkit.load` answers.

    Give it as any call's `data`. The resources (or the directory's files) were
    read when it was loaded, so a call does not send or read them again, and a
    search's index over them is built once. `count` is how many resources were
    given (None for a place). `close()` lets the toolkit forget it; it is also
    a context manager. Should the toolkit's process start again, the data is
    loaded again from what was given, at the next call that names it.
    """

    def __init__(self, toolkit: "Toolkit", source: Any, project: "Project"):
        self._toolkit = toolkit
        self._source = source
        self._project = project
        self._key: Optional[str] = None
        self._generation = -1
        self.count: Optional[int] = None
        self._argument()

    def _argument(self) -> Dict[str, str]:
        """This data as a function's `data`; loaded (again) when this process does not hold it."""
        if self._source is None:
            raise FhirError("the data was closed: load it again")
        server = self._toolkit._server
        # (a process that has ended starts again at the next call, without this data)
        if self._key is None or self._generation != server.generation or not server.running:
            answer = self._toolkit._load(self._source, self._project)
            self._key, self.count, self._generation = answer["loaded"], answer.get("count"), server.generation
        return {"loaded": self._key}

    def close(self) -> None:
        """Let the toolkit forget the data. Using it after this is an error."""
        key, self._key, self._source = self._key, None, None
        server = self._toolkit._server
        if key is not None and server.running and self._generation == server.generation:
            self._toolkit._unload(key)

    def __enter__(self) -> "Data":
        return self

    def __exit__(self, *exc) -> None:
        self.close()

    def __len__(self) -> int:
        if self.count is None:
            raise TypeError("the data is a place (a directory, a store, a server): it has no count here")
        return self.count

    def __repr__(self) -> str:
        if self._source is None:
            return "Data(closed)"
        return "Data(%s)" % ("%d resources" % self.count if self.count is not None else repr(self._source))


def as_data(data: DataLike) -> Any:
    """Data as the functions take it: a path as text, resources as they are, loaded data by its key."""
    if isinstance(data, Data):
        return data._argument()
    if data is None or isinstance(data, (str, dict, list)):
        return data
    if isinstance(data, os.PathLike):
        return os.fspath(data)
    if isinstance(data, (tuple, set, frozenset)) or hasattr(data, "__next__"):
        return list(data)
    return data            # one typed model: written as its JSON when the call is made


class _Raw(Functions):
    """The generated functions over a server: plain JSON in, plain JSON out."""

    def __init__(self, server: Server):
        self._server = server

    def _call(self, name: str, arguments: Dict[str, Any]) -> Any:
        # (typed models among the arguments go as the JSON they write: Server encodes them)
        return self._server.call(name, arguments)


class Toolkit:
    """One process of the FHIR toolkit.

    Args:
        fhir_version: "4.0.1" (the default) or "5.0.0". A process reads one
            version; make a second Toolkit for the other.
        packages: FHIR packages in context for every call, by name
            ("hl7.fhir.us.core-6.1.0") or as .tgz paths.
        command: the command that starts the toolkit, when it should not be
            found the usual way (see `fhir_toolkit.find_command`).
        start: True (the default) starts the process now, in the background:
            making a Toolkit does not wait for it, and the first call waits
            only for what is left of its start (well under a second in all).
            False leaves it until the first call.

    `raw` has every function of the toolkit exactly as the server defines it
    (plain JSON values); the methods here are the convenient forms.
    """

    def __init__(self, fhir_version: str = "4.0.1", *, packages: Sequence[str] = (), command: Optional[Sequence[str]] = None,
                 start: bool = True):
        self._server = Server(fhir_version, packages, command, start=start)
        self.raw = _Raw(self._server)
        atexit.register(self.close)

    def __repr__(self) -> str:
        return "Toolkit(FHIR %s, %s)" % (self._server.fhir_version, "running" if self._server.running else "not started")

    def close(self) -> None:
        """Stop the process. A call after this starts it again."""
        self._server.close()

    def __enter__(self) -> "Toolkit":
        return self

    def __exit__(self, *exc) -> None:
        self.close()

    # ---- what the toolkit is --------------------------------------------------------------------
    def version(self) -> Dict[str, Any]:
        """The protocol, the FHIR version read, the packages in context, the functions."""
        return self.raw.version()

    def guide(self, topic: Optional[str] = None) -> Union[str, List[str]]:
        """A guide to a language or to FHIR as text; without a topic, the topics."""
        answer = self.raw.guide(topic=topic)
        return answer["topics"] if topic is None else answer["text"]

    # ---- one resource ---------------------------------------------------------------------------
    def fhirpath(self, expression: str, resource: Resource) -> List[Any]:
        """A FHIRPath expression's values over one resource.

        An element comes back as its FHIR JSON, a System value as a number,
        a boolean or a string (a date as FHIR writes it: "1980-02-28").
        """
        return self.raw.fhirpath(expression, resource=resource)["values"]

    def fhirpath_each(self, expression: str, resources: Any) -> List[List[Any]]:
        """A FHIRPath expression's values over each of several resources, in one call.

        `resources` is a list of resources (or a Bundle). The answer has one
        list of values for each, in the order given: far quicker than a call
        for each resource.
        """
        return self.raw.fhirpath(expression, resources=_resources(resources))["results"]

    # ---- data given once ------------------------------------------------------------------------
    def load(self, data: DataLike, *, project: ProjectLike = None) -> "Data":
        """Data given once and kept by the toolkit: use the answer as later calls' `data`.

        Resources (a list, one, a Bundle) are sent once and held in memory; a
        directory or file of FHIR JSON is read once; a store or a server is
        opened once. Without this each call sends, or reads, its data again.
        """
        if isinstance(data, Data):
            return data
        return Data(self, as_data(data), as_project(project))

    def _load(self, source: Any, project: "Project") -> Dict[str, Any]:
        return self.raw.load(source, **project.arguments())

    def _unload(self, key: str) -> None:
        self.raw.unload(key)

    def validate(self, resource: Resource, profile: Optional[str] = None, *, project: ProjectLike = None) -> Outcome:
        """A resource held to its type, the profiles it claims and `profile`.

        `profile` is a canonical, or the id or name of a profile the project
        defines. The answer is an `Outcome`: `.ok`, `.errors`, `.messages()`,
        `.raise_for_errors()`.
        """
        return Outcome(self.raw.validate(resource=resource, profile=profile, **as_project(project).arguments()))

    def validate_each(self, resources: Any, profile: Optional[str] = None, *, project: ProjectLike = None) -> List[Outcome]:
        """Each of several resources validated, in one call: an `Outcome` for each, in the order given."""
        answer = self.raw.validate(resources=_resources(resources), profile=profile, **as_project(project).arguments())
        return [Outcome(o) for o in answer["outcomes"]]

    def decompile(self, resource: Resource, as_: Optional[str] = None, *, project: ProjectLike = None) -> str:
        """A resource written as source text.

        FSH for a profile, value set, code system or instance; the mapping
        language for a StructureMap; a view's text for a ViewDefinition; CQL for
        a Library that carries it. `as_` picks one: "fsh", "fml", "sof", "vcl"
        (a ValueSet's compose), "cql".
        """
        return self.raw.decompile(resource, as_=as_, **as_project(project).arguments())["text"]

    def transform(self, map: str, source: Resource, *, project: ProjectLike = None, model: Any = None) -> Any:
        """A resource converted by a map written in the FHIR Mapping Language.

        With `model` (a class of a model library) the result is an object of it.
        """
        return _as(model, self.raw.transform(map, source, **as_project(project).arguments()))

    def operation(self, operation: str, resource: Optional[Resource] = None, *, inputs: Optional[Dict[str, Any]] = None,
                  project: ProjectLike = None, data: DataLike = None, model: Any = None) -> Any:
        """Any FHIR operation the toolkit implements: "$expand", "$validate-code", "$lookup", …"""
        return _as(model, self.raw.operation(operation, resource=resource, inputs=inputs, data=as_data(data),
                                             **as_project(project).arguments()))

    # ---- a project ------------------------------------------------------------------------------
    def compile(self, project: ProjectLike, *, check: bool = True) -> Compiled:
        """What a project's files define, as FHIR resources.

        With `check` (the default) an error in any file raises FhirError, whose
        `diagnostics` say where; `check=False` answers the `Compiled` with its
        diagnostics instead.
        """
        compiled = Compiled(self.raw.compile(**as_project(project).arguments()))
        return compiled.raise_for_errors() if check else compiled

    def check(self, project: ProjectLike) -> List[Diagnostic]:
        """Every problem in a project's files (errors and warnings); never raises for them."""
        return self.compile(project, check=False).diagnostics

    def translate(self, text: str, *, name: Optional[str] = None, project: ProjectLike = None, check: bool = True) -> Optional[Dict[str, Any]]:
        """A CQL library's ELM as JSON.

        Includes are found among the project's .cql files, then among the
        libraries the toolkit carries (FHIRHelpers). With `check` a translation
        error raises FhirError; without, the answer is None when there are errors.
        """
        answer = self.raw.translate(text, name=name, **as_project(project).arguments())
        errors = [d for d in (Diagnostic.from_json(j) for j in answer["diagnostics"]) if d.is_error]
        if check and errors:
            raise FhirError("\n".join(str(d) for d in errors), diagnostics=errors)
        return answer["elm"]

    def run(self, path: str, *, project: ProjectLike, data: DataLike = None, entry: Optional[str] = None,
            over: Optional[str] = None, parameters: Optional[Mapping[str, str]] = None) -> Table:
        """One file of the project run over the data."""
        return Table(self.raw.run(path, entry=entry, over=over, parameters=_parameters(parameters), data=as_data(data),
                                  **as_project(project).arguments()))

    def query(self, language: str, text: str, *, project: ProjectLike = None, data: DataLike = None,
              entry: Optional[str] = None, over: Optional[str] = None, parameters: Optional[Mapping[str, str]] = None,
              strict: Optional[bool] = None) -> Table:
        """A text asked of the data: "fhirpath", "cql", "vcl", "search", "find", "view" or "sql"."""
        return Table(self.raw.query(language, text, entry=entry, over=over, parameters=_parameters(parameters), strict=strict,
                                    data=as_data(data), **as_project(project).arguments()))

    def explain(self, path: str, subject: str, *, project: ProjectLike, data: DataLike = None, entry: Optional[str] = None,
                over: Optional[str] = None, parameters: Optional[Mapping[str, str]] = None) -> Dict[str, Any]:
        """Why a file answered what it did for one subject, each step at its place in the source."""
        return self.raw.explain(path, subject, entry=entry, over=over, parameters=_parameters(parameters), data=as_data(data),
                                **as_project(project).arguments())

    # ---- by language ----------------------------------------------------------------------------
    def fsh(self, text: str, *, project: ProjectLike = None, canonical: Optional[str] = None, model: Any = None) -> List[Any]:
        """FHIR Shorthand compiled: the resources its entities define.

        An error (a rule that names no element, an example that breaks its
        profile) raises FhirError with the line it is at.
        """
        base = as_project(project)
        resources = self.compile(Project(base.with_file("input.fsh", text).files, canonical=canonical or base.canonical)).resources
        return _as(model, resources)

    def cql(self, text: str, data: DataLike, *, project: ProjectLike = None, entry: Optional[str] = None,
            parameters: Optional[Mapping[str, str]] = None) -> Table:
        """A CQL library run over the data: one row per patient, one column per define."""
        name = _library_file(text)
        return self.run(name, project=as_project(project).with_file(name, text), data=data, entry=entry, parameters=parameters)

    def view(self, text: str, data: DataLike, *, project: ProjectLike = None) -> Table:
        """A view's rows: SQL on FHIR source text (`SELECT id, birthDate FROM Patient`), or a ViewDefinition as JSON text."""
        return self.query("view", text, project=project, data=data)

    def sql(self, statement: str, *, project: ProjectLike = None, data: DataLike) -> Table:
        """A SQL statement over the project's views (each view file is a table of its name).

        Over a store the statement also reads what the store keeps itself: a
        table per resource type, `history`, and `trail` (who wrote which
        version, when and why).
        """
        return self.query("sql", statement, project=project, data=data)

    def search(self, query: str, data: DataLike, *, strict: Optional[bool] = None) -> Table:
        """A FHIR search (`Observation?code=4548-4&date=ge2025`) over the data."""
        return self.query("search", query, data=data, strict=strict)

    def expand(self, value_set: str, *, project: ProjectLike = None) -> List[Dict[str, Any]]:
        """A value set's codes, each {system, code, display}.

        `value_set` is a canonical url, or a VCL expression such as
        `(http://loinc.org)(4548-4;17856-6)`.
        """
        if re.match(r"^https?://\S+$", value_set):
            expansion = self.operation("$expand", inputs={"url": value_set}, project=project).get("expansion", {})
            return [{"system": c.get("system"), "code": c.get("code"), "display": c.get("display")} for c in expansion.get("contains", [])]
        return self.query("vcl", value_set, project=project).rows

    # ---- writing --------------------------------------------------------------------------------
    def stage(self, resources: Any = None, *, data: Union[str, "os.PathLike[str]"], fsh: Optional[str] = None,
              project: ProjectLike = None, keep: bool = True) -> Stage:
        """A write prepared and not yet made.

        `resources` (a list, one resource, a Bundle) or `fsh` (FSH Instances as
        text; `Instance: Type/id` with rules alone changes that stored resource)
        are validated in the project's context and compared with what `data`
        holds: a SQLite FHIR store (made when the file is not there) or a
        directory of FHIR JSON. The answer is a `Stage`: `.changes`, `.errors`,
        `.ok`, and `.commit(reason)`, which writes it. `keep=False` only checks.
        """
        place = os.fspath(data)
        arguments = as_project(project).arguments()
        answer = self.raw.stage(resources=_resources(resources), fsh=fsh, data=place, keep=None if keep else False, **arguments)

        def commit(reason: Optional[str] = None, agent: Optional[str] = None) -> Commit:
            return Commit(self.raw.commit(answer["stage"], place, reason=reason, agent=agent, **arguments))

        return Stage(answer, commit if answer.get("stage") else None)

    def write(self, resources: Any = None, *, data: Union[str, "os.PathLike[str]"], fsh: Optional[str] = None,
              reason: Optional[str] = None, agent: Optional[str] = None, project: ProjectLike = None) -> Commit:
        """Resources written to the data: staged, and committed when nothing is wrong.

        An error in any of them (a code its value set lacks, a rule of a
        profile broken) raises FhirError and nothing is written. The answer is
        a `Commit`: the versions written and the Provenance that records who,
        why and from what (empty when the data already holds them as given).
        """
        staged = self.stage(resources, data=data, fsh=fsh, project=project)
        if not staged.ok:
            if staged.id:
                self.raw.stage(drop=staged.id, data=os.fspath(data), **as_project(project).arguments())
            staged.raise_for_errors()
        return staged.commit(reason, agent=agent) if staged.id else Commit({})


def _as(model: Any, resource: Any) -> Any:
    return resource if model is None else typed(model, resource)


def _resources(resources: Any) -> Any:
    """What is to be written, as the function takes it: a list or one resource."""
    if resources is None or isinstance(resources, (dict, list)):
        return resources
    if isinstance(resources, (tuple, set, frozenset)) or hasattr(resources, "__next__"):
        return list(resources)
    return resources


def _parameters(parameters: Optional[Mapping[str, str]]) -> Optional[Dict[str, str]]:
    """CQL parameter values are CQL expressions as text: `{"Measurement Period": "Interval[@2025-01-01, @2025-12-31]"}`."""
    if parameters is None:
        return None
    for name, value in parameters.items():
        if not isinstance(value, str):
            raise TypeError("the value of CQL parameter %r is a CQL expression as text (got %r)" % (name, value))
    return dict(parameters)


def _library_file(text: str) -> str:
    """The file a library's text is given as: its declared name, so that includes of it resolve."""
    declared = re.search(r'^\s*library\s+("[^"]+"|[A-Za-z_][A-Za-z0-9_.]*)', text, re.MULTILINE)
    name = declared.group(1).strip('"') if declared else "Library"
    return re.sub(r"[^A-Za-z0-9_.-]", "_", name) + ".cql"
