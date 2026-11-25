"""The toolkit's functions, one method each. GENERATED: do not edit.

Written by clients/python/generate.py from clients/functions.json, the table
the function server answers from (`raco fhir-api functions`). Each method sends
its arguments as they are and returns the server's answer as plain JSON values;
`fhir_toolkit.Toolkit` builds the friendlier interface on top.
"""
from typing import Any, Dict, Optional

PROTOCOL = 1
FUNCTIONS = ['compile', 'run', 'query', 'explain', 'fhirpath', 'translate', 'decompile', 'validate', 'load', 'unload', 'transform', 'operation', 'stage', 'commit', 'guide', 'version']


class Functions:
    """One method per function of the table. A subclass provides `_call`."""

    def _call(self, name: str, arguments: Dict[str, Any]) -> Any:
        raise NotImplementedError

    def compile(self, *, files: Optional[Dict[str, str]] = None, directory: Optional[str] = None, canonical: Optional[str] = None) -> Any:
        """What a project's files define, as FHIR resources, with every problem in them
        (examples are validated against the profiles they claim).

        Args:
            files: the project: sources in any of the languages and FHIR JSON definitions, by
                file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`,
                `ValueSet-x.json`); what they define is in context for the call
            directory: the project as a directory on disk, in place of `files` (its
                workspace.yaml and sushi-config.yaml are read)
            canonical: the base of the canonicals the project's files define when they state
                none (http://example.org otherwise); with `files`

        Returns:
            {resources: [resource…], diagnostics: [Diagnostic…]}
        """
        arguments = {
            'files': files,
            'directory': directory,
            'canonical': canonical,
        }
        return self._call('compile', {k: v for k, v in arguments.items() if v is not None})

    def run(self, path: str, *, entry: Optional[str] = None, over: Optional[str] = None, parameters: Optional[Dict[str, Any]] = None, files: Optional[Dict[str, str]] = None, directory: Optional[str] = None, canonical: Optional[str] = None, data: Optional[Any] = None) -> Any:
        """One file of the project run over the data: a CQL library's defines for each patient,
        a view's rows, a map's results, a FHIRPath expression's values, a value set's codes, the
        resources an FSH file compiles to.

        Args:
            path: the file to run, by its name in the project
            entry: the one part to run: a CQL define, a mapping group
            over: what to run over: a resource type, or one resource as Type/id
            parameters: CQL parameter values by name, each a CQL expression as text
            files: the project: sources in any of the languages and FHIR JSON definitions, by
                file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`,
                `ValueSet-x.json`); what they define is in context for the call
            directory: the project as a directory on disk, in place of `files` (its
                workspace.yaml and sushi-config.yaml are read)
            canonical: the base of the canonicals the project's files define when they state
                none (http://example.org otherwise); with `files`
            data: the FHIR data to read: resources given here (a list, one resource, a Bundle),
                or a string naming a directory of FHIR JSON, a JSON file, a SQLite FHIR store or
                a FHIR server's base url

        Returns:
            a Table {kind, columns, rows, summary}
        """
        arguments = {
            'path': path,
            'entry': entry,
            'over': over,
            'parameters': parameters,
            'files': files,
            'directory': directory,
            'canonical': canonical,
            'data': data,
        }
        return self._call('run', {k: v for k, v in arguments.items() if v is not None})

    def query(self, language: str, text: str, *, entry: Optional[str] = None, over: Optional[str] = None, parameters: Optional[Dict[str, Any]] = None, strict: Optional[bool] = None, files: Optional[Dict[str, str]] = None, directory: Optional[str] = None, canonical: Optional[str] = None, data: Optional[Any] = None) -> Any:
        """A text asked of the data without a file: FHIRPath, CQL, VCL, a FHIR search
        (`Observation?code=…`), words to find, a view, or SQL over the project's views.

        Args:
            language: fhirpath | cql | vcl | search | find | view | sql
            text: the expression, search, view or statement
            entry: the one part to run: a CQL define, a mapping group
            over: what to run over: a resource type, or one resource as Type/id
            parameters: CQL parameter values by name, each a CQL expression as text
            strict: a search: refuse a parameter the data cannot apply, where it is otherwise
                left out and said
            files: the project: sources in any of the languages and FHIR JSON definitions, by
                file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`,
                `ValueSet-x.json`); what they define is in context for the call
            directory: the project as a directory on disk, in place of `files` (its
                workspace.yaml and sushi-config.yaml are read)
            canonical: the base of the canonicals the project's files define when they state
                none (http://example.org otherwise); with `files`
            data: the FHIR data to read: resources given here (a list, one resource, a Bundle),
                or a string naming a directory of FHIR JSON, a JSON file, a SQLite FHIR store or
                a FHIR server's base url

        Returns:
            a Table {kind, columns, rows, summary}
        """
        arguments = {
            'language': language,
            'text': text,
            'entry': entry,
            'over': over,
            'parameters': parameters,
            'strict': strict,
            'files': files,
            'directory': directory,
            'canonical': canonical,
            'data': data,
        }
        return self._call('query', {k: v for k, v in arguments.items() if v is not None})

    def explain(self, path: str, subject: str, *, entry: Optional[str] = None, over: Optional[str] = None, parameters: Optional[Dict[str, Any]] = None, files: Optional[Dict[str, str]] = None, directory: Optional[str] = None, canonical: Optional[str] = None, data: Optional[Any] = None) -> Any:
        """Why a file answered what it did for one subject (a patient, a resource, an entity),
        each step with its place in the source.

        Args:
            path: the file, by its name in the project
            subject: a patient or resource id, Type/id, or the name of an entity
            entry: the one part to run: a CQL define, a mapping group
            over: what to run over: a resource type, or one resource as Type/id
            parameters: CQL parameter values by name, each a CQL expression as text
            files: the project: sources in any of the languages and FHIR JSON definitions, by
                file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`,
                `ValueSet-x.json`); what they define is in context for the call
            directory: the project as a directory on disk, in place of `files` (its
                workspace.yaml and sushi-config.yaml are read)
            canonical: the base of the canonicals the project's files define when they state
                none (http://example.org otherwise); with `files`
            data: the FHIR data to read: resources given here (a list, one resource, a Bundle),
                or a string naming a directory of FHIR JSON, a JSON file, a SQLite FHIR store or
                a FHIR server's base url

        Returns:
            an object, by language
        """
        arguments = {
            'path': path,
            'subject': subject,
            'entry': entry,
            'over': over,
            'parameters': parameters,
            'files': files,
            'directory': directory,
            'canonical': canonical,
            'data': data,
        }
        return self._call('explain', {k: v for k, v in arguments.items() if v is not None})

    def fhirpath(self, expression: str, *, resource: Optional[Dict[str, Any]] = None, resources: Optional[Any] = None) -> Any:
        """A FHIRPath expression evaluated over one resource, or over each of several in one
        call.

        Args:
            expression: the FHIRPath expression
            resource: the resource it is evaluated over
            resources: in place of `resource`: several resources (a list, or a Bundle), each
                evaluated on its own

        Returns:
            {values: [json…]} for `resource`: FHIR JSON for an element, a JSON number, boolean
                or string for a System value; {results: [[json…]…]} for `resources`: the values
                for each, in the order given
        """
        arguments = {
            'expression': expression,
            'resource': resource,
            'resources': resources,
        }
        return self._call('fhirpath', {k: v for k, v in arguments.items() if v is not None})

    def translate(self, text: str, *, name: Optional[str] = None, files: Optional[Dict[str, str]] = None, directory: Optional[str] = None, canonical: Optional[str] = None) -> Any:
        """A CQL library translated to ELM, with every translation error and warning; includes
        are found in the project, then among the libraries the toolkit carries.

        Args:
            text: the library's CQL
            name: a file name for its problems (library.cql otherwise)
            files: the project: sources in any of the languages and FHIR JSON definitions, by
                file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`,
                `ValueSet-x.json`); what they define is in context for the call
            directory: the project as a directory on disk, in place of `files` (its
                workspace.yaml and sushi-config.yaml are read)
            canonical: the base of the canonicals the project's files define when they state
                none (http://example.org otherwise); with `files`

        Returns:
            {elm: the library's ELM as JSON (null when it has errors), diagnostics:
                [Diagnostic…]}
        """
        arguments = {
            'text': text,
            'name': name,
            'files': files,
            'directory': directory,
            'canonical': canonical,
        }
        return self._call('translate', {k: v for k, v in arguments.items() if v is not None})

    def decompile(self, resource: Dict[str, Any], *, as_: Optional[str] = None, files: Optional[Dict[str, str]] = None, directory: Optional[str] = None, canonical: Optional[str] = None) -> Any:
        """A FHIR resource written as source text: FSH (a profile, value set, code system,
        instance), the mapping language (a StructureMap), a view's text (a ViewDefinition), VCL
        (a ValueSet's compose), CQL (a Library that carries it).

        Args:
            resource: the resource
            as_: fsh | fml | sof | vcl | cql; by the resource's type otherwise
            files: the project: sources in any of the languages and FHIR JSON definitions, by
                file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`,
                `ValueSet-x.json`); what they define is in context for the call
            directory: the project as a directory on disk, in place of `files` (its
                workspace.yaml and sushi-config.yaml are read)
            canonical: the base of the canonicals the project's files define when they state
                none (http://example.org otherwise); with `files`

        Returns:
            {language, text}
        """
        arguments = {
            'resource': resource,
            'as': as_,
            'files': files,
            'directory': directory,
            'canonical': canonical,
        }
        return self._call('decompile', {k: v for k, v in arguments.items() if v is not None})

    def validate(self, *, resource: Optional[Dict[str, Any]] = None, resources: Optional[Any] = None, profile: Optional[str] = None, files: Optional[Dict[str, str]] = None, directory: Optional[str] = None, canonical: Optional[str] = None) -> Any:
        """A resource held to its type, the profiles it claims and one more when named; profiles
        the project defines are in context.

        Args:
            resource: the resource to validate
            resources: in place of `resource`: several resources (a list, or a Bundle), each
                validated on its own
            profile: a profile to hold it to as well: its canonical, or the id or name of one
                the project defines
            files: the project: sources in any of the languages and FHIR JSON definitions, by
                file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`,
                `ValueSet-x.json`); what they define is in context for the call
            directory: the project as a directory on disk, in place of `files` (its
                workspace.yaml and sushi-config.yaml are read)
            canonical: the base of the canonicals the project's files define when they state
                none (http://example.org otherwise); with `files`

        Returns:
            an OperationOutcome for `resource`; {outcomes: [OperationOutcome…]} for `resources`,
                in the order given
        """
        arguments = {
            'resource': resource,
            'resources': resources,
            'profile': profile,
            'files': files,
            'directory': directory,
            'canonical': canonical,
        }
        return self._call('validate', {k: v for k, v in arguments.items() if v is not None})

    def load(self, data: Any, *, files: Optional[Dict[str, str]] = None, directory: Optional[str] = None, canonical: Optional[str] = None) -> Any:
        """Data opened once and kept for the calls after it, so that a call need not give it
        again: resources (held in memory), or a place (a directory or file of FHIR JSON is read
        now; a store or a server is opened).

        Args:
            data: the resources, or a string naming where they are
            files: the project: sources in any of the languages and FHIR JSON definitions, by
                file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`,
                `ValueSet-x.json`); what they define is in context for the call
            directory: the project as a directory on disk, in place of `files` (its
                workspace.yaml and sushi-config.yaml are read)
            canonical: the base of the canonicals the project's files define when they state
                none (http://example.org otherwise); with `files`

        Returns:
            {loaded: the key — give {loaded: key} as a later call's `data` —, count: how many
                resources were given (null for a place)}
        """
        arguments = {
            'data': data,
            'files': files,
            'directory': directory,
            'canonical': canonical,
        }
        return self._call('load', {k: v for k, v in arguments.items() if v is not None})

    def unload(self, loaded: str) -> Any:
        """Data kept by load, let go.

        Args:
            loaded: the key load answered

        Returns:
            {unloaded: was something kept under the key}
        """
        arguments = {
            'loaded': loaded,
        }
        return self._call('unload', {k: v for k, v in arguments.items() if v is not None})

    def transform(self, map: str, source: Dict[str, Any], *, files: Optional[Dict[str, str]] = None, directory: Optional[str] = None, canonical: Optional[str] = None) -> Any:
        """A resource converted by a map written in the mapping language; structures the project
        defines (logical models, profiles) are in context.

        Args:
            map: the map's text
            source: the resource to convert
            files: the project: sources in any of the languages and FHIR JSON definitions, by
                file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`,
                `ValueSet-x.json`); what they define is in context for the call
            directory: the project as a directory on disk, in place of `files` (its
                workspace.yaml and sushi-config.yaml are read)
            canonical: the base of the canonicals the project's files define when they state
                none (http://example.org otherwise); with `files`

        Returns:
            the resulting resource
        """
        arguments = {
            'map': map,
            'source': source,
            'files': files,
            'directory': directory,
            'canonical': canonical,
        }
        return self._call('transform', {k: v for k, v in arguments.items() if v is not None})

    def operation(self, operation: str, *, resource: Optional[Dict[str, Any]] = None, inputs: Optional[Dict[str, Any]] = None, files: Optional[Dict[str, str]] = None, directory: Optional[str] = None, canonical: Optional[str] = None, data: Optional[Any] = None) -> Any:
        """Any FHIR operation the toolkit implements, by reference: $expand, $validate-code,
        $lookup, $translate, $snapshot, $evaluate-measure, $sql-run and the others.

        Args:
            operation: $code, Type/$code, or the OperationDefinition's canonical
            resource: the resource the operation applies to
            inputs: the operation's input parameters by name (a list for several values)
            files: the project: sources in any of the languages and FHIR JSON definitions, by
                file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`,
                `ValueSet-x.json`); what they define is in context for the call
            directory: the project as a directory on disk, in place of `files` (its
                workspace.yaml and sushi-config.yaml are read)
            canonical: the base of the canonicals the project's files define when they state
                none (http://example.org otherwise); with `files`
            data: the FHIR data to read: resources given here (a list, one resource, a Bundle),
                or a string naming a directory of FHIR JSON, a JSON file, a SQLite FHIR store or
                a FHIR server's base url

        Returns:
            the resource the operation returns (its `return`, or a Parameters of its outputs)
        """
        arguments = {
            'operation': operation,
            'resource': resource,
            'inputs': inputs,
            'files': files,
            'directory': directory,
            'canonical': canonical,
            'data': data,
        }
        return self._call('operation', {k: v for k, v in arguments.items() if v is not None})

    def stage(self, data: str, *, resources: Optional[Any] = None, fsh: Optional[str] = None, drop: Optional[str] = None, keep: Optional[bool] = None, files: Optional[Dict[str, str]] = None, directory: Optional[str] = None, canonical: Optional[str] = None) -> Any:
        """A write prepared and not yet made: resources, given as JSON or as FSH Instances,
        validated in the project's context (the profiles they claim, the project's own among
        them) and compared with what the data holds: created, changed (each path old → new) or
        unchanged, with every error. Nothing is written until commit.

        Args:
            data: where the data is kept: a SQLite FHIR store (the file is made when it is not
                there), or a directory of FHIR JSON
            resources: the resources to write (a list, one resource, or a Bundle); one with an
                id the data holds is an update
            fsh: in place of `resources`: FSH Instances as text; `Instance: Type/id` with rules
                alone changes that stored resource
            drop: discard a stage instead: its id, latest, refused (those with errors) or all
            keep: false: check only — the same answer, no stage kept
            files: the project: sources in any of the languages and FHIR JSON definitions, by
                file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`,
                `ValueSet-x.json`); what they define is in context for the call
            directory: the project as a directory on disk, in place of `files` (its
                workspace.yaml and sushi-config.yaml are read)
            canonical: the base of the canonicals the project's files define when they state
                none (http://example.org otherwise); with `files`

        Returns:
            {stage, changes: [{resource, action, changed, errors, warnings}…], errors}: `stage`
                the id commit takes (none when nothing differs or with keep false), `action`
                create | update | unchanged, `errors` their count
        """
        arguments = {
            'data': data,
            'resources': resources,
            'fsh': fsh,
            'drop': drop,
            'keep': keep,
            'files': files,
            'directory': directory,
            'canonical': canonical,
        }
        return self._call('stage', {k: v for k, v in arguments.items() if v is not None})

    def commit(self, stage: str, data: str, *, reason: Optional[str] = None, agent: Optional[str] = None, files: Optional[Dict[str, str]] = None, directory: Optional[str] = None, canonical: Optional[str] = None) -> Any:
        """A stage written to the data, with its trail: the resources in one step (a SQLite
        store: one transaction), then a Provenance (the versions written, who, why, the source
        text with its hash) and an AuditEvent. A stage with errors is refused.

        Args:
            stage: the stage's id, as stage answered it, or latest
            data: where the data is kept: a SQLite FHIR store (the file is made when it is not
                there), or a directory of FHIR JSON
            reason: why: recorded in the Provenance
            agent: who is writing, for the Provenance and the AuditEvent: a name, or a reference
                (Practitioner/x); fhir-api when none is given
            files: the project: sources in any of the languages and FHIR JSON definitions, by
                file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`,
                `ValueSet-x.json`); what they define is in context for the call
            directory: the project as a directory on disk, in place of `files` (its
                workspace.yaml and sushi-config.yaml are read)
            canonical: the base of the canonicals the project's files define when they state
                none (http://example.org otherwise); with `files`

        Returns:
            {stage, written: [{resource, version, status, ok}…], provenance, reason, agent}:
                `version` as Type/id/_history/n, `provenance` the Provenance written
        """
        arguments = {
            'stage': stage,
            'data': data,
            'reason': reason,
            'agent': agent,
            'files': files,
            'directory': directory,
            'canonical': canonical,
        }
        return self._call('commit', {k: v for k, v in arguments.items() if v is not None})

    def guide(self, *, topic: Optional[str] = None) -> Any:
        """A guide to one of the languages or to FHIR itself, written for an agent; without a
        topic, the topics.

        Args:
            topic: fhir, fsh, cql, fhirpath, fml, vcl, sql-on-fhir, …

        Returns:
            {topics: [string…]} or {topic, text}
        """
        arguments = {
            'topic': topic,
        }
        return self._call('guide', {k: v for k, v in arguments.items() if v is not None})

    def version(self) -> Any:
        """What this process is: the protocol's version, the FHIR version it reads, the packages
        in context, its functions.

        Returns:
            {protocol, fhirVersion, packages, functions}
        """
        return self._call('version', {})
