"""agentfhir: a FHIR implementation for agents, from Python.

    from agentfhir import FhirContext

    with FhirContext() as fhir:
        fhir.fhirpath("name.family", patient)             # ['Lee']
        fhir.validate(patient).ok                         # True
        fhir.view("SELECT id, birthDate FROM Patient", data).to_pandas()

A `FhirContext` is FHIR at one version (4.0.1 unless asked: `FhirContext.r5()`): one process
of the engine, started in the background when the context is made and kept for every call. A PROJECT is the sources a call may refer to — profiles
in FSH, CQL libraries, maps, value sets in VCL, views, FHIR JSON definitions —
given as a dict of file name -> text, as a directory, or as a `Project`. DATA
is the FHIR a call reads: resources (a list, one resource, a Bundle), or the
path of a directory of FHIR JSON, a JSON file or a SQLite FHIR store, or a FHIR
server's base url. A resource is FHIR JSON (a dict), an object of a model
library that writes itself as JSON (`agentfhir.models`), JSON text, or a
`pathlib.Path` to a JSON file.

What the engine could not read of the data (a date its month lacks, a time
without a zone) it says as a `FhirWarning`, and a table keeps under `.notes`.

Data used by several calls is given once: `clinic = fhir.load(resources)`, then
`data=clinic`. One question of many resources is one call: `fhirpath_each`,
`validate_each`, or a view.
"""
import atexit
import threading
import json
import os
import re
import urllib.parse
from typing import Any, Dict, List, Mapping, Optional, Sequence, Union

from ._functions import Functions
from ._server import Server
from .errors import Diagnostic, FhirError, FhirSourceError, FhirUsageError, warn
from .models import typed
from .results import CodeCheck, Commit, Compiled, Concept, Match, Outcome, Stage, Table, _listed, _params

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
    """Data given to the engine once and kept there: what `FhirContext.load` answers.

    Give it as any call's `data`. The resources (or the directory's files) were
    read when it was loaded, so a call does not send or read them again, and a
    search's index over them is built once. `count` is how many resources were
    given (None for a place). `close()` lets the engine forget it; it is also
    a context manager. Should the engine's process start again, the data is
    loaded again from what was given, at the next call that names it.
    """

    def __init__(self, toolkit: "FhirContext", source: Any, project: "Project"):
        self._toolkit = toolkit
        self._source = source
        self._project = project
        # what each process holds this data as: process -> (key, the process's generation)
        self._keys: Dict["_Raw", Any] = {}
        self._lock = threading.Lock()
        self.count: Optional[int] = None
        self._argument(toolkit._raws[0])

    def _argument(self, raw: "_Raw") -> Dict[str, str]:
        """This data as a function's `data` in one process; loaded (again) there when that process
        does not hold it (it has not been asked yet, or it has started again since)."""
        with self._lock:
            if self._source is None:
                raise FhirUsageError("the data was closed: load it again")
            server = raw._server
            key, generation = self._keys.get(raw, (None, -1))
            if key is None or generation != server.generation or not server.running:
                answer = raw.load(self._source, **self._project.arguments())
                key = answer["loaded"]
                self.count = answer.get("count")
                self._keys[raw] = (key, server.generation)
            return {"loaded": key}

    def close(self) -> None:
        """Let the engine forget the data. Using it after this is an error."""
        with self._lock:
            keys, self._keys, self._source = self._keys, {}, None
        for raw, (key, generation) in keys.items():
            if raw._server.running and generation == raw._server.generation:
                raw.unload(key)

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
    """Data as the functions take it: a path as text, resources as they are; loaded data as itself,
    which the process a call goes to names by its own key (`_Raw._call`)."""
    if isinstance(data, Data):
        return data
    if data is None or isinstance(data, (str, dict, list)):
        return data
    if isinstance(data, os.PathLike):
        return os.fspath(data)
    if isinstance(data, (tuple, set, frozenset)) or hasattr(data, "__next__"):
        return list(data)
    return data            # one typed model: written as its JSON when the call is made


class _Raw(Functions):
    """The generated functions over one process: plain JSON in, plain JSON out."""

    def __init__(self, server: Server):
        self._server = server
        self.busy = 0         # calls in flight here (counted by the pool, under its lock)

    def _call(self, name: str, arguments: Dict[str, Any]) -> Any:
        # loaded data is named by what THIS process holds it as; typed models among the
        # arguments go as the JSON they write (Server encodes them)
        data = arguments.get("data")
        if isinstance(data, Data):
            arguments = dict(arguments, data=data._argument(self))
        return self._server.call(name, arguments)


class _Pool(Functions):
    """The generated functions over the FhirContext's processes: each call goes to the one with the
    fewest calls in flight (the first, of those with as few), so calls from several threads run at
    the same time, one in each process. `held()` names a process for calls that must meet the
    same one (a stage and its commit)."""

    def __init__(self, raws: List[_Raw]):
        self._raws = raws
        self._lock = threading.Lock()

    def _take(self) -> _Raw:
        with self._lock:
            raw = min(self._raws, key=lambda r: r.busy)      # (min keeps the first of equals)
            raw.busy += 1
            return raw

    def _give(self, raw: _Raw) -> None:
        with self._lock:
            raw.busy -= 1

    def _call(self, name: str, arguments: Dict[str, Any]) -> Any:
        raw = self._take()
        try:
            return raw._call(name, arguments)
        finally:
            self._give(raw)

    def held(self) -> _Raw:
        """The process least busy now, to which every call of a sequence then goes."""
        raw = self._take()
        self._give(raw)
        return raw


class FhirContext:
    """FHIR at one version: the engine's process, its packages, and every call.

    Args:
        fhir_version: "4.0.1" (the default) or "5.0.0". A process reads one
            version; make a second FhirContext for the other.
        packages: FHIR packages in context for every call, by name
            ("hl7.fhir.us.core-6.1.0") or as .tgz paths.
        command: the command that starts the engine, when it should not be
            found the usual way (see `agentfhir.find_command`).
        start: True (the default) starts the process now, in the background:
            making a FhirContext does not wait for it, and the first call waits
            only for what is left of its start (well under a second in all).
            False leaves it until the first call.
        workers: how many processes answer calls (1, the default). With more,
            calls made at the same time — from several threads, or awaited
            together through `AsyncFhirContext` — are each answered by a process
            of their own, and `fhirpath_each` and `validate_each` cut a long
            list into that many parts answered at once: about that many times
            quicker on a machine with the cores, for that many times the
            memory (some 150 MB a process). Data you `load` is loaded into
            each process the first time a call there uses it.
        timeout: how many seconds a call may take; None (the default) lets
            it take as long as it takes. A call that runs out of time — or
            is interrupted, by Ctrl-C or a notebook's stop button — raises,
            and the process is started afresh for the next call.

    `raw` has every function of the engine exactly as the server defines it
    (plain JSON values); the methods here are the convenient forms.
    """

    def __init__(self, fhir_version: str = "4.0.1", *, packages: Sequence[str] = (), command: Optional[Sequence[str]] = None,
                 start: bool = True, timeout: Optional[float] = None, workers: int = 1):
        if not isinstance(workers, int) or workers < 1:
            raise ValueError("workers is how many processes answer a list of resources: 1 or more (got %r)" % (workers,))
        self._servers = [Server(fhir_version, packages, command, start=start, timeout=timeout) for _ in range(workers)]
        self._server = self._servers[0]
        self._raws = [_Raw(server) for server in self._servers]
        # every call goes to the process least busy: with one worker, always the one
        self.raw = _Pool(self._raws)
        atexit.register(self.close)

    @classmethod
    def r4(cls, **options: Any) -> "FhirContext":
        """FHIR R4 (4.0.1), as `FhirContext()` is; `options` as for the constructor."""
        return cls("4.0.1", **options)

    @classmethod
    def r5(cls, **options: Any) -> "FhirContext":
        """FHIR R5 (5.0.0); `options` as for the constructor."""
        return cls("5.0.0", **options)

    def __repr__(self) -> str:
        return "FhirContext(FHIR %s, %s%s)" % (self._server.fhir_version, "running" if self._server.running else "not started",
                                               ", %d workers" % len(self._servers) if len(self._servers) > 1 else "")

    def close(self) -> None:
        """Stop the process (and its workers). A call after this starts it again."""
        for server in self._servers:
            server.close()

    def _each(self, call: Any, resources: Any, key: str) -> List[Any]:
        """`call(raw, resources)[key]`, a list with an item for each resource: asked of this
        process, or — a long list, and workers to share it — of each worker for its part, at
        the same time, the answers put back in the order given."""
        resources = _resources(resources)
        if len(self._raws) == 1 or not isinstance(resources, list) or len(resources) < SHARED_FROM:
            return call(self.raw, resources)[key]
        parts = _parts(resources, len(self._raws))
        answers: List[Any] = [None] * len(parts)
        failures: List[BaseException] = []

        def work(i: int) -> None:
            try:
                answers[i] = call(self._raws[i], parts[i])[key]
            except BaseException as e:      # (an interrupt too: it is raised again below, once the others are in)
                failures.append(e)

        others = [threading.Thread(target=work, args=(i,), daemon=True) for i in range(1, len(parts))]
        for thread in others:
            thread.start()
        work(0)
        for thread in others:
            thread.join()
        if failures:
            raise failures[0]
        return [answer for part in answers for answer in part]

    def __enter__(self) -> "FhirContext":
        return self

    def __exit__(self, *exc) -> None:
        self.close()

    # ---- what the engine is --------------------------------------------------------------------
    def version(self) -> Dict[str, Any]:
        """The protocol, the FHIR version read, the packages in context, the functions."""
        return self.raw.version()

    def guide(self, topic: Optional[str] = None) -> Union[str, List[str]]:
        """A guide to a language or to FHIR as text; without a topic, the topics."""
        answer = self.raw.guide(topic=topic)
        return answer["topics"] if topic is None else answer["text"]

    # ---- one resource ---------------------------------------------------------------------------
    def fhirpath(self, expression: str, resource: Resource, *, model: Any = None) -> List[Any]:
        """A FHIRPath expression's values over one resource.

        An element comes back as its FHIR JSON, a System value as a number,
        a boolean or a string (a date as FHIR writes it: "1980-02-28"). With
        `model` (a class of a model library) each value is an object of it:
        `fhir.fhirpath("name", patient, model=HumanName)`.
        """
        return _as(model, self.raw.fhirpath(expression, resource=_resource(resource))["values"])

    def fhirpath_each(self, expression: str, resources: Any, *, model: Any = None) -> List[List[Any]]:
        """A FHIRPath expression's values over each of several resources, in one call.

        `resources` is a list of resources (or a Bundle). The answer has one
        list of values for each, in the order given: far quicker than a call
        for each resource. With `model`, each value is an object of it.
        """
        results = self._each(lambda raw, part: raw.fhirpath(expression, resources=part), resources, "results")
        return results if model is None else [typed(model, values) for values in results]

    # ---- data given once ------------------------------------------------------------------------
    def load(self, data: DataLike, *, project: ProjectLike = None) -> "Data":
        """Data given once and kept by the engine: use the answer as later calls' `data`.

        Resources (a list, one, a Bundle) are sent once and held in memory; a
        directory or file of FHIR JSON is read once; a store or a server is
        opened once. Without this each call sends, or reads, its data again.
        """
        if isinstance(data, Data):
            return data
        return Data(self, as_data(data), as_project(project))

    def validate(self, resource: Resource, profile: Optional[str] = None, *, project: ProjectLike = None) -> Outcome:
        """A resource held to its type, the profiles it claims and `profile`.

        `profile` is a canonical, or the id or name of a profile the project
        defines. The answer is an `Outcome`: `.ok`, `.errors`, `.messages()`,
        `.raise_for_errors()`.
        """
        return Outcome(self.raw.validate(resource=_resource(resource), profile=profile, **as_project(project).arguments()))

    def validate_each(self, resources: Any, profile: Optional[str] = None, *, project: ProjectLike = None) -> List[Outcome]:
        """Each of several resources validated, in one call: an `Outcome` for each, in the order given."""
        arguments = as_project(project).arguments()
        outcomes = self._each(lambda raw, part: raw.validate(resources=part, profile=profile, **arguments), resources, "outcomes")
        return [Outcome(o) for o in outcomes]

    def decompile(self, resource: Resource, as_: Optional[str] = None, *, project: ProjectLike = None) -> str:
        """A resource written as source text.

        FSH for a profile, value set, code system or instance; the mapping
        language for a StructureMap; a view's text for a ViewDefinition; CQL for
        a Library that carries it. `as_` picks one: "fsh", "fml", "sof", "vcl"
        (a ValueSet's compose), "cql".
        """
        return self.raw.decompile(_resource(resource), as_=as_, **as_project(project).arguments())["text"]

    def transform(self, map: str, source: Resource, *, project: ProjectLike = None, model: Any = None) -> Any:
        """A resource converted by a map written in the FHIR Mapping Language.

        With `model` (a class of a model library) the result is an object of it.
        """
        return _as(model, self.raw.transform(map, _resource(source), **as_project(project).arguments()))

    def operation(self, operation: str, resource: Optional[Resource] = None, *, inputs: Optional[Dict[str, Any]] = None,
                  project: ProjectLike = None, data: DataLike = None, model: Any = None) -> Any:
        """Any FHIR operation the engine implements: "$expand", "$validate-code", "$lookup", …"""
        return _as(model, self.raw.operation(operation, resource=_resource(resource), inputs=inputs, data=as_data(data),
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

    def elm(self, text: str, *, name: Optional[str] = None, project: ProjectLike = None, check: bool = True) -> Optional[Dict[str, Any]]:
        """A CQL library translated to ELM, as JSON: the form other CQL engines run.

        Includes are found among the project's .cql files, then among the
        libraries the engine carries (FHIRHelpers). With `check` a translation
        error raises FhirError; without, the answer is None when there are errors.
        """
        answer = self.raw.translate(text, name=name, **as_project(project).arguments())
        errors = [d for d in (Diagnostic.from_json(j) for j in answer["diagnostics"]) if d.is_error]
        if check and errors:
            raise FhirSourceError("\n".join(str(d) for d in errors), diagnostics=errors)
        return answer["elm"]

    def run(self, path: str, *, project: ProjectLike, data: DataLike = None, entry: Optional[str] = None,
            over: Optional[str] = None, parameters: Optional[Mapping[str, str]] = None) -> Table:
        """One file of the project run over the data."""
        return _table(self.raw.run(path, entry=entry, over=over, parameters=_parameters(parameters), data=as_data(data),
                                   **as_project(project).arguments()))

    def query(self, language: str, text: str, *, project: ProjectLike = None, data: DataLike = None,
              entry: Optional[str] = None, over: Optional[str] = None, parameters: Optional[Mapping[str, str]] = None,
              strict: Optional[bool] = None) -> Table:
        """A text asked of the data: "fhirpath", "cql", "vcl", "search", "find", "view" or "sql"."""
        return _table(self.raw.query(language, text, entry=entry, over=over, parameters=_parameters(parameters), strict=strict,
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

    def validate_code(self, value_set: str, code: Union[str, Dict[str, Any]], system: Optional[str] = None, *,
                      display: Optional[str] = None, version: Optional[str] = None, project: ProjectLike = None) -> CodeCheck:
        """Whether a value set holds a code (FHIR's ValueSet/$validate-code).

        `value_set` is a canonical url (with `|version` if need be), or a VCL
        expression. `code` is a code (with its `system`), a Coding, or a
        CodeableConcept (held when any of its codings is). With `display`, the
        display is checked too. The answer is a `CodeCheck`, true when the code
        is held: `if fhir.validate_code(vs, "female", gender_system): ...`.
        A value set nothing in context defines raises FhirError.
        """
        inputs: Dict[str, Any] = {"url": _value_set_url(value_set)}
        if isinstance(code, dict):
            inputs["codeableConcept" if "coding" in code else "coding"] = code
        else:
            inputs.update({"code": code, "system": system, "systemVersion": version, "display": display})
        inputs = {k: v for k, v in inputs.items() if v is not None}
        return CodeCheck(self.operation("ValueSet/$validate-code", inputs=inputs, project=project))

    def lookup(self, system: str, code: str, *, version: Optional[str] = None, project: ProjectLike = None) -> Concept:
        """A code looked up in its code system (FHIR's $lookup): its display, definition,
        designations and properties, as a `Concept`. A code system that is not in context, or
        a code it lacks, raises FhirError."""
        inputs = {k: v for k, v in (("system", system), ("code", code), ("version", version)) if v is not None}
        return Concept(system, code, self.operation("$lookup", inputs=inputs, project=project))

    def subsumes(self, system: str, code_a: str, code_b: str, *, version: Optional[str] = None,
                 project: ProjectLike = None) -> str:
        """How code A relates to code B in their code system's hierarchy (FHIR's $subsumes):
        "equivalent", "subsumes" (A is broader), "subsumed-by" (A is narrower) or "not-subsumed"."""
        inputs = {k: v for k, v in (("system", system), ("codeA", code_a), ("codeB", code_b), ("version", version)) if v is not None}
        answer = self.operation("$subsumes", inputs=inputs, project=project)
        return _params(answer.get("parameter", [])).get("outcome")

    def translate(self, code: Union[str, Dict[str, Any]], system: Optional[str] = None, *, concept_map: Optional[str] = None,
                  target: Optional[str] = None, project: ProjectLike = None) -> List[Match]:
        """The codes a code maps to (FHIR's ConceptMap/$translate), each a `Match`.

        `concept_map` is the ConceptMap's canonical; `target` the code system to
        map into (FHIR's `targetSystem`). `code` is a code with its `system`, or
        a Coding. No match is an empty list.
        """
        inputs: Dict[str, Any] = {"url": concept_map, "targetSystem": target}
        if isinstance(code, dict):
            inputs["sourceCodeableConcept" if "coding" in code else "sourceCoding"] = code
        else:
            inputs.update({"sourceCode": code, "system": system})
        answer = self.operation("$translate", inputs={k: v for k, v in inputs.items() if v is not None}, project=project)
        found = _params(answer.get("parameter", []))
        return [Match(m) for m in _listed(found.get("match"))]

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
        raw = self.raw.held()       # a stage is kept by the process that made it: its commit goes there too
        answer = raw.stage(resources=_resources(resources), fsh=fsh, data=place, keep=None if keep else False, **arguments)

        def commit(reason: Optional[str] = None, agent: Optional[str] = None) -> Commit:
            return Commit(raw.commit(answer["stage"], place, reason=reason, agent=agent, **arguments))

        def drop() -> None:
            raw.stage(drop=answer["stage"], data=place, **arguments)

        return Stage(answer, commit if answer.get("stage") else None, drop if answer.get("stage") else None)

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
            staged.drop()
            staged.raise_for_errors()
        return staged.commit(reason, agent=agent) if staged.id else Commit({})


#: a list of resources is shared between workers from this many on (a short list is quicker asked whole)
SHARED_FROM = 64


def _parts(items: List[Any], n: int) -> List[List[Any]]:
    """A list cut into at most n runs of nearly one length, in order, none empty."""
    n = max(1, min(n, len(items)))
    size, more = divmod(len(items), n)
    parts, at = [], 0
    for i in range(n):
        end = at + size + (1 if i < more else 0)
        parts.append(items[at:end])
        at = end
    return parts


def _as(model: Any, resource: Any) -> Any:
    return resource if model is None else typed(model, resource)


def _table(answer: Dict[str, Any]) -> Table:
    """A function's answer as a Table; what it notes besides its rows is warned of, at the caller's line."""
    table = Table(answer)
    warn(table.notes)
    return table


def _resource(resource: Any) -> Any:
    """One resource as the functions take it.

    FHIR JSON (a dict) and an object of a model library go as they are; JSON
    text is read, and so is the JSON file a `pathlib.Path` names.
    """
    if isinstance(resource, os.PathLike):
        with open(resource, encoding="utf-8") as f:
            return json.load(f)
    if isinstance(resource, (str, bytes)):
        text = resource.decode("utf-8") if isinstance(resource, bytes) else resource
        if text.lstrip().startswith("{"):
            try:
                return json.loads(text)
            except ValueError as e:
                raise FhirUsageError("the resource is not JSON: %s" % e) from e
        raise FhirUsageError("a resource is FHIR JSON (a dict), an object of a model library, JSON text, or a pathlib.Path to a "
                        "JSON file — not the text %r" % (text if len(text) <= 40 else text[:39] + "…"))
    return resource


def _resources(resources: Any) -> Any:
    """Several resources as the functions take them: a list (each as `_resource` takes one), or one resource (a Bundle)."""
    if resources is None or isinstance(resources, dict):
        return resources
    if isinstance(resources, (list, tuple, set, frozenset)) or hasattr(resources, "__next__"):
        return [_resource(r) if isinstance(r, (str, bytes, os.PathLike)) else r for r in resources]
    return _resource(resources)


def _parameters(parameters: Optional[Mapping[str, str]]) -> Optional[Dict[str, str]]:
    """CQL parameter values are CQL expressions as text: `{"Measurement Period": "Interval[@2025-01-01, @2025-12-31]"}`."""
    if parameters is None:
        return None
    for name, value in parameters.items():
        if not isinstance(value, str):
            raise TypeError("the value of CQL parameter %r is a CQL expression as text (got %r)" % (name, value))
    return dict(parameters)


def _value_set_url(value_set: str) -> str:
    """A value set as `$validate-code` takes it: a url as it is; a VCL expression as the implicit
    value set VCL defines (`http://fhir.org/VCL?v1=` and the expression, percent-encoded)."""
    if re.match(r"^https?://\S+$", value_set):
        return value_set
    return "http://fhir.org/VCL?v1=" + urllib.parse.quote(value_set, safe="")


def _library_file(text: str) -> str:
    """The file a library's text is given as: its declared name, so that includes of it resolve."""
    declared = re.search(r'^\s*library\s+("[^"]+"|[A-Za-z_][A-Za-z0-9_.]*)', text, re.MULTILINE)
    name = declared.group(1).strip('"') if declared else "Library"
    return re.sub(r"[^A-Za-z0-9_.-]", "_", name) + ".cql"
