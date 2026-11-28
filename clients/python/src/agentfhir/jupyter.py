"""Cell magics: the engine's languages as notebook cells.

    %load_ext agentfhir.jupyter

    %%fsh                    a cell of FHIR Shorthand: compiled and checked
    %%cql -d patients        a CQL library run over the data in `patients`
    %%sof -d patients        a view's rows, as a DataFrame
    %%fhir_sql -d patients   SQL over the views the notebook has defined
    %%fhirpath -d patient    one FHIRPath expression a line, over a resource
    %%vcl                    a value set's codes
    %%fml -d source          a map applied to a resource
    %fhir                    what the notebook has defined; `%fhir reset` forgets it

The NOTEBOOK'S PROJECT is what the cells have defined so far: each `%%fsh`,
`%%cql`, `%%fml` cell, and each `%%sof` or `%%vcl` cell that names what it
defines, is kept as a file of it, so a later cell sees the profile, library,
view or value set an earlier one wrote (a CQL cell retrieves by a value set a
VCL cell named; `%%fhir_sql` joins the views). A cell run again replaces its
file: a file is named by what the cell defines (`-n` names it otherwise).

`-d` takes the name of a variable (resources, or a path as text), `-o` the
name of a variable to keep the answer in. A problem in a cell is printed with
its line and column in the cell, and nothing is assigned.

From Python cells the same state is `agentfhir.jupyter.notebook`:
`notebook.context` (a `FhirContext`) and `notebook.project` (a `Project`), as in
`notebook.context.validate(resource, "AdultPatient", project=notebook.project)`.
"""
import re
import sys
from typing import Any, List, Optional

from IPython.core.magic import Magics, cell_magic, line_magic, magics_class
from IPython.core.magic_arguments import argument, magic_arguments, parse_argstring

from .errors import FhirError, FhirUsageError
from .results import Table
from .context import Project, FhirContext, _library_file


class Notebook:
    """What a notebook's cells share: one FhirContext, and the project they have built."""

    def __init__(self) -> None:
        self._context: Optional[FhirContext] = None
        self.fhir_version = "4.0.1"
        self.project = Project({})

    @property
    def context(self) -> FhirContext:
        if self._context is None:
            self._context = FhirContext(self.fhir_version)
        return self._context

    def define(self, name: str, text: str) -> None:
        """Keep a cell's text as the project's file `name` (replacing the file of that name)."""
        self.project = self.project.with_file(name, text)

    def forget(self, name: str) -> None:
        files = dict(self.project.files or {})
        files.pop(name, None)
        self.project = Project(files, canonical=self.project.canonical)

    def reset(self, fhir_version: Optional[str] = None) -> None:
        """Forget every file; with a version, read that version of FHIR from now on."""
        self.project = Project({})
        if fhir_version and fhir_version != self.fhir_version:
            if self._context is not None:
                self._context.close()
            self._context = None
            self.fhir_version = fhir_version


notebook = Notebook()

_FSH_ENTITY = re.compile(
    r"^(?:Profile|Extension|Logical|Resource|ValueSet|CodeSystem|Instance|Invariant|RuleSet|Mapping)\s*:\s*(\S+)", re.MULTILINE)
_VIEW_NAME = re.compile(r"^\s*CREATE\s+VIEW\s+([A-Za-z_][A-Za-z0-9_]*)", re.MULTILINE)
_MAP_NAME = re.compile(r"""^///\s*name\s*=\s*["']([^"']+)["']""", re.MULTILINE)


def _file_name(given: Optional[str], found: Optional["re.Match[str]"], fallback: str, ending: str) -> str:
    """The project file a cell is kept as: the name given, else what the cell defines first."""
    stem = given or (found.group(1) if found else fallback)
    stem = re.sub(r"[^A-Za-z0-9_.-]", "-", stem)
    return stem if stem.endswith(ending) else stem + ending


def _shown(table: Table) -> Any:
    """A table as a notebook shows one best: a DataFrame where pandas is installed."""
    try:
        return table.to_pandas()
    except ImportError:
        return table


@magics_class
class FhirMagics(Magics):
    """The magics; one instance per notebook."""

    # ---- what every magic shares ------------------------------------------------------------------
    def _named(self, name: Optional[str], what: str) -> Any:
        """The value of the variable a `-d` names."""
        if name is None:
            return None
        if name not in self.shell.user_ns:
            raise FhirUsageError("no variable `%s` in the notebook (%s)" % (name, what))
        return self.shell.user_ns[name]

    def _keep(self, name: Optional[str], value: Any) -> None:
        if name:
            self.shell.user_ns[name] = value

    def _answer(self, thunk) -> Any:
        """A magic's answer, or its problems printed (to stderr) and None."""
        try:
            return thunk()
        except FhirError as error:
            # each problem at its place in the cell (`A1c.cql:6:3: error: …`), else what was said
            for line in [str(d) for d in error.diagnostics] or [str(error)]:
                print(line, file=sys.stderr)
            return None

    # ---- the languages ------------------------------------------------------------------------------
    @magic_arguments()
    @argument("-n", "--name", help="the project file the cell is kept as (default: the first entity's name)")
    @argument("-o", "--out", help="a variable for the resources the cell defines")
    @cell_magic
    def fsh(self, line: str, cell: str) -> None:
        """FHIR Shorthand: the cell's entities compiled, its examples validated, kept in the project."""
        options = parse_argstring(self.fsh, line)
        name = _file_name(options.name, _FSH_ENTITY.search(cell), "cell", ".fsh")

        def run() -> None:
            before = notebook.project
            notebook.define(name, cell)
            try:
                table = notebook.context.run(name, project=notebook.project)
            except FhirError:
                notebook.project = before          # a cell that does not parse defines nothing
                raise
            problems = table.summary.get("problems", [])
            for p in problems:
                print("%s:%s:%s: %s: %s" % (p.get("source", name), p.get("line", "?"), p.get("column", "?"),
                                            p.get("severity"), p.get("message")), file=sys.stderr)
            if any(p.get("severity") == "error" for p in problems):
                notebook.project = before          # nor does one with errors: fix the cell and run it again
                return
            resources = [row["resource"] for row in table.rows]
            self._keep(options.out, resources)
            for row in table.rows:
                print("%s/%s%s" % (row["resourceType"], row["id"], "  " + row["url"] if row.get("url") else ""))

        self._answer(run)

    @magic_arguments()
    @argument("-d", "--data", help="the variable holding the data: resources, or a path as text")
    @argument("-o", "--out", help="a variable for the answer")
    @argument("-e", "--entry", help="one define alone")
    @cell_magic
    def cql(self, line: str, cell: str) -> Any:
        """A CQL library run over the data (a row a patient, a column a define); kept in the project."""
        options = parse_argstring(self.cql, line)

        def run() -> Any:
            data = self._named(options.data, "%%cql -d names the data")
            name = _library_file(cell)
            # IPython hands an option's quotes on with it: `-e "Above 9"` names the define Above 9
            entry = options.entry.strip("\"'") if options.entry else None
            answer = _shown(notebook.context.cql(cell, data, project=notebook.project, entry=entry))
            notebook.define(name, cell)
            self._keep(options.out, answer)
            return answer

        return self._answer(run)

    @magic_arguments()
    @argument("-d", "--data", help="the variable holding the data: resources, or a path as text")
    @argument("-o", "--out", help="a variable for the rows")
    @cell_magic
    def sof(self, line: str, cell: str) -> Any:
        """A SQL on FHIR view's rows. `CREATE VIEW name … AS SELECT …` also keeps it as a table for %%fhir_sql."""
        options = parse_argstring(self.sof, line)

        def run() -> Any:
            data = self._named(options.data, "%%sof -d names the data")
            answer = _shown(notebook.context.view(cell, data, project=notebook.project))
            named = _VIEW_NAME.search(cell)
            if named:
                notebook.define(named.group(1) + ".sof", cell)
            self._keep(options.out, answer)
            return answer

        return self._answer(run)

    @magic_arguments()
    @argument("-d", "--data", help="the variable holding the data: resources, or a path as text")
    @argument("-o", "--out", help="a variable for the rows")
    @cell_magic
    def fhir_sql(self, line: str, cell: str) -> Any:
        """One SQL statement over the notebook's views (and, over a store, its own tables)."""
        options = parse_argstring(self.fhir_sql, line)

        def run() -> Any:
            data = self._named(options.data, "%%fhir_sql -d names the data")
            answer = _shown(notebook.context.sql(cell, project=notebook.project, data=data))
            self._keep(options.out, answer)
            return answer

        return self._answer(run)

    @magic_arguments()
    @argument("-d", "--data", required=True, help="the variable holding one resource")
    @argument("-o", "--out", help="a variable for the values")
    @cell_magic
    def fhirpath(self, line: str, cell: str) -> Any:
        """FHIRPath over one resource: an expression a line. One line answers its values; several, a dict."""
        options = parse_argstring(self.fhirpath, line)

        def run() -> Any:
            resource = self._named(options.data, "%%fhirpath -d names a resource")
            expressions = [text.strip() for text in cell.splitlines() if text.strip() and not text.strip().startswith("//")]
            if not expressions:
                raise FhirUsageError("the cell holds no expression")
            values = {e: notebook.context.fhirpath(e, resource) for e in expressions}
            answer = values[expressions[0]] if len(expressions) == 1 else values
            self._keep(options.out, answer)
            return answer

        return self._answer(run)

    @magic_arguments()
    @argument("-n", "--name", help="keep the value set in the project under this name (its canonical ends in it)")
    @argument("-o", "--out", help="a variable for the codes")
    @cell_magic
    def vcl(self, line: str, cell: str) -> Any:
        """A value set written in VCL: its codes. With -n it is kept, for CQL and bindings to name."""
        options = parse_argstring(self.vcl, line)

        def run() -> Any:
            text = " ".join(part.strip() for part in cell.splitlines() if part.strip())
            answer = _shown(notebook.context.query("vcl", text, project=notebook.project))
            if options.name:
                notebook.define(_file_name(options.name, None, "cell", ".vcl"), text)
            self._keep(options.out, answer)
            return answer

        return self._answer(run)

    @magic_arguments()
    @argument("-d", "--data", required=True, help="the variable holding the resource to convert")
    @argument("-o", "--out", help="a variable for the result")
    @cell_magic
    def fml(self, line: str, cell: str) -> Any:
        """A map in the FHIR Mapping Language applied to one resource; kept in the project."""
        options = parse_argstring(self.fml, line)

        def run() -> Any:
            source = self._named(options.data, "%%fml -d names the resource to convert")
            answer = notebook.context.transform(cell, source, project=notebook.project)
            notebook.define(_file_name(None, _MAP_NAME.search(cell), "cell", ".map"), cell)
            self._keep(options.out, answer)
            return answer

        return self._answer(run)

    @line_magic
    def fhir(self, line: str) -> Optional[List[str]]:
        """`%fhir`: the files the notebook has defined. `%fhir reset [version]`: forget them
        (and read FHIR 4.0.1 or 5.0.0 from now on). `%fhir forget <file>`: forget one."""
        words = line.split()
        if not words:
            return sorted(notebook.project.files or {})
        if words[0] == "reset" and len(words) <= 2:
            notebook.reset(words[1] if len(words) == 2 else None)
            return None
        if words[0] == "forget" and len(words) == 2:
            notebook.forget(words[1])
            return None
        print("%fhir, %fhir reset [4.0.1|5.0.0], %fhir forget <file>", file=sys.stderr)
        return None


def load_ipython_extension(ipython) -> None:
    """`%load_ext agentfhir.jupyter`"""
    ipython.register_magics(FhirMagics)
