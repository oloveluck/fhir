// The toolkit's functions, one method each. GENERATED: do not edit.
//
// Written by clients/typescript/generate.mjs from clients/functions.json, the table the function
// server answers from (`raco fhir-api functions`). Each method sends its arguments as they are
// and answers the server's result as plain JSON values; `Toolkit` builds the friendlier
// interface on top.

export const PROTOCOL = 1;
export const FUNCTIONS = ["compile","run","query","explain","fhirpath","translate","decompile","validate","transform","operation","stage","commit","guide","version"] as const;

/** What `compile` takes. */
export interface CompileArguments {
  /**
   * the project: sources in any of the languages and FHIR JSON definitions, by file name
   * (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`, `ValueSet-x.json`); what
   * they define is in context for the call
   */
  files?: Record<string, string>;
  /**
   * the project as a directory on disk, in place of `files` (its workspace.yaml and
   * sushi-config.yaml are read)
   */
  directory?: string;
  /**
   * the base of the canonicals the project's files define when they state none (http://example.org
   * otherwise); with `files`
   */
  canonical?: string;
}

/** What `run` takes. */
export interface RunArguments {
  /**
   * the file to run, by its name in the project
   */
  path: string;
  /**
   * the one part to run: a CQL define, a mapping group
   */
  entry?: string;
  /**
   * what to run over: a resource type, or one resource as Type/id
   */
  over?: string;
  /**
   * CQL parameter values by name, each a CQL expression as text
   */
  parameters?: Record<string, unknown>;
  /**
   * the project: sources in any of the languages and FHIR JSON definitions, by file name
   * (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`, `ValueSet-x.json`); what
   * they define is in context for the call
   */
  files?: Record<string, string>;
  /**
   * the project as a directory on disk, in place of `files` (its workspace.yaml and
   * sushi-config.yaml are read)
   */
  directory?: string;
  /**
   * the base of the canonicals the project's files define when they state none (http://example.org
   * otherwise); with `files`
   */
  canonical?: string;
  /**
   * the FHIR data to read: resources given here (a list, one resource, a Bundle), or a string
   * naming a directory of FHIR JSON, a JSON file, a SQLite FHIR store or a FHIR server's base url
   */
  data?: string | Record<string, unknown> | Array<Record<string, unknown>>;
}

/** What `query` takes. */
export interface QueryArguments {
  /**
   * fhirpath | cql | vcl | search | find | view | sql
   */
  language: string;
  /**
   * the expression, search, view or statement
   */
  text: string;
  /**
   * the one part to run: a CQL define, a mapping group
   */
  entry?: string;
  /**
   * what to run over: a resource type, or one resource as Type/id
   */
  over?: string;
  /**
   * CQL parameter values by name, each a CQL expression as text
   */
  parameters?: Record<string, unknown>;
  /**
   * a search: refuse a parameter the data cannot apply, where it is otherwise left out and said
   */
  strict?: boolean;
  /**
   * the project: sources in any of the languages and FHIR JSON definitions, by file name
   * (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`, `ValueSet-x.json`); what
   * they define is in context for the call
   */
  files?: Record<string, string>;
  /**
   * the project as a directory on disk, in place of `files` (its workspace.yaml and
   * sushi-config.yaml are read)
   */
  directory?: string;
  /**
   * the base of the canonicals the project's files define when they state none (http://example.org
   * otherwise); with `files`
   */
  canonical?: string;
  /**
   * the FHIR data to read: resources given here (a list, one resource, a Bundle), or a string
   * naming a directory of FHIR JSON, a JSON file, a SQLite FHIR store or a FHIR server's base url
   */
  data?: string | Record<string, unknown> | Array<Record<string, unknown>>;
}

/** What `explain` takes. */
export interface ExplainArguments {
  /**
   * the file, by its name in the project
   */
  path: string;
  /**
   * a patient or resource id, Type/id, or the name of an entity
   */
  subject: string;
  /**
   * the one part to run: a CQL define, a mapping group
   */
  entry?: string;
  /**
   * what to run over: a resource type, or one resource as Type/id
   */
  over?: string;
  /**
   * CQL parameter values by name, each a CQL expression as text
   */
  parameters?: Record<string, unknown>;
  /**
   * the project: sources in any of the languages and FHIR JSON definitions, by file name
   * (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`, `ValueSet-x.json`); what
   * they define is in context for the call
   */
  files?: Record<string, string>;
  /**
   * the project as a directory on disk, in place of `files` (its workspace.yaml and
   * sushi-config.yaml are read)
   */
  directory?: string;
  /**
   * the base of the canonicals the project's files define when they state none (http://example.org
   * otherwise); with `files`
   */
  canonical?: string;
  /**
   * the FHIR data to read: resources given here (a list, one resource, a Bundle), or a string
   * naming a directory of FHIR JSON, a JSON file, a SQLite FHIR store or a FHIR server's base url
   */
  data?: string | Record<string, unknown> | Array<Record<string, unknown>>;
}

/** What `fhirpath` takes. */
export interface FhirpathArguments {
  /**
   * the FHIRPath expression
   */
  expression: string;
  /**
   * the resource it is evaluated over
   */
  resource: Record<string, unknown>;
}

/** What `translate` takes. */
export interface TranslateArguments {
  /**
   * the library's CQL
   */
  text: string;
  /**
   * a file name for its problems (library.cql otherwise)
   */
  name?: string;
  /**
   * the project: sources in any of the languages and FHIR JSON definitions, by file name
   * (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`, `ValueSet-x.json`); what
   * they define is in context for the call
   */
  files?: Record<string, string>;
  /**
   * the project as a directory on disk, in place of `files` (its workspace.yaml and
   * sushi-config.yaml are read)
   */
  directory?: string;
  /**
   * the base of the canonicals the project's files define when they state none (http://example.org
   * otherwise); with `files`
   */
  canonical?: string;
}

/** What `decompile` takes. */
export interface DecompileArguments {
  /**
   * the resource
   */
  resource: Record<string, unknown>;
  /**
   * fsh | fml | sof | vcl | cql; by the resource's type otherwise
   */
  as?: string;
  /**
   * the project: sources in any of the languages and FHIR JSON definitions, by file name
   * (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`, `ValueSet-x.json`); what
   * they define is in context for the call
   */
  files?: Record<string, string>;
  /**
   * the project as a directory on disk, in place of `files` (its workspace.yaml and
   * sushi-config.yaml are read)
   */
  directory?: string;
  /**
   * the base of the canonicals the project's files define when they state none (http://example.org
   * otherwise); with `files`
   */
  canonical?: string;
}

/** What `validate` takes. */
export interface ValidateArguments {
  /**
   * the resource to validate
   */
  resource: Record<string, unknown>;
  /**
   * a profile to hold it to as well: its canonical, or the id or name of one the project defines
   */
  profile?: string;
  /**
   * the project: sources in any of the languages and FHIR JSON definitions, by file name
   * (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`, `ValueSet-x.json`); what
   * they define is in context for the call
   */
  files?: Record<string, string>;
  /**
   * the project as a directory on disk, in place of `files` (its workspace.yaml and
   * sushi-config.yaml are read)
   */
  directory?: string;
  /**
   * the base of the canonicals the project's files define when they state none (http://example.org
   * otherwise); with `files`
   */
  canonical?: string;
}

/** What `transform` takes. */
export interface TransformArguments {
  /**
   * the map's text
   */
  map: string;
  /**
   * the resource to convert
   */
  source: Record<string, unknown>;
  /**
   * the project: sources in any of the languages and FHIR JSON definitions, by file name
   * (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`, `ValueSet-x.json`); what
   * they define is in context for the call
   */
  files?: Record<string, string>;
  /**
   * the project as a directory on disk, in place of `files` (its workspace.yaml and
   * sushi-config.yaml are read)
   */
  directory?: string;
  /**
   * the base of the canonicals the project's files define when they state none (http://example.org
   * otherwise); with `files`
   */
  canonical?: string;
}

/** What `operation` takes. */
export interface OperationArguments {
  /**
   * $code, Type/$code, or the OperationDefinition's canonical
   */
  operation: string;
  /**
   * the resource the operation applies to
   */
  resource?: Record<string, unknown>;
  /**
   * the operation's input parameters by name (a list for several values)
   */
  inputs?: Record<string, unknown>;
  /**
   * the project: sources in any of the languages and FHIR JSON definitions, by file name
   * (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`, `ValueSet-x.json`); what
   * they define is in context for the call
   */
  files?: Record<string, string>;
  /**
   * the project as a directory on disk, in place of `files` (its workspace.yaml and
   * sushi-config.yaml are read)
   */
  directory?: string;
  /**
   * the base of the canonicals the project's files define when they state none (http://example.org
   * otherwise); with `files`
   */
  canonical?: string;
  /**
   * the FHIR data to read: resources given here (a list, one resource, a Bundle), or a string
   * naming a directory of FHIR JSON, a JSON file, a SQLite FHIR store or a FHIR server's base url
   */
  data?: string | Record<string, unknown> | Array<Record<string, unknown>>;
}

/** What `stage` takes. */
export interface StageArguments {
  /**
   * where the data is kept: a SQLite FHIR store (the file is made when it is not there), or a
   * directory of FHIR JSON
   */
  data: string;
  /**
   * the resources to write (a list, one resource, or a Bundle); one with an id the data holds is an
   * update
   */
  resources?: Record<string, unknown> | Array<Record<string, unknown>>;
  /**
   * in place of `resources`: FSH Instances as text; `Instance: Type/id` with rules alone changes
   * that stored resource
   */
  fsh?: string;
  /**
   * discard a stage instead: its id, latest, refused (those with errors) or all
   */
  drop?: string;
  /**
   * false: check only — the same answer, no stage kept
   */
  keep?: boolean;
  /**
   * the project: sources in any of the languages and FHIR JSON definitions, by file name
   * (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`, `ValueSet-x.json`); what
   * they define is in context for the call
   */
  files?: Record<string, string>;
  /**
   * the project as a directory on disk, in place of `files` (its workspace.yaml and
   * sushi-config.yaml are read)
   */
  directory?: string;
  /**
   * the base of the canonicals the project's files define when they state none (http://example.org
   * otherwise); with `files`
   */
  canonical?: string;
}

/** What `commit` takes. */
export interface CommitArguments {
  /**
   * the stage's id, as stage answered it, or latest
   */
  stage: string;
  /**
   * where the data is kept: a SQLite FHIR store (the file is made when it is not there), or a
   * directory of FHIR JSON
   */
  data: string;
  /**
   * why: recorded in the Provenance
   */
  reason?: string;
  /**
   * who is writing, for the Provenance and the AuditEvent: a name, or a reference (Practitioner/x);
   * fhir-api when none is given
   */
  agent?: string;
  /**
   * the project: sources in any of the languages and FHIR JSON definitions, by file name
   * (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`, `ValueSet-x.json`); what
   * they define is in context for the call
   */
  files?: Record<string, string>;
  /**
   * the project as a directory on disk, in place of `files` (its workspace.yaml and
   * sushi-config.yaml are read)
   */
  directory?: string;
  /**
   * the base of the canonicals the project's files define when they state none (http://example.org
   * otherwise); with `files`
   */
  canonical?: string;
}

/** What `guide` takes. */
export interface GuideArguments {
  /**
   * fhir, fsh, cql, fhirpath, fml, vcl, sql-on-fhir, …
   */
  topic?: string;
}

/** What `version` takes. */
export interface VersionArguments {
}

/** One method per function of the table. A subclass provides `call`. */
export abstract class Functions {
  protected abstract call(name: string, args: object): Promise<any>;

  /**
   * What a project's files define, as FHIR resources, with every problem in them (examples are
   * validated against the profiles they claim).
   *
   * Answers {resources: [resource…], diagnostics: [Diagnostic…]}.
   */
  compile(args: CompileArguments = {}): Promise<any> {
    return this.call("compile", args);
  }

  /**
   * One file of the project run over the data: a CQL library's defines for each patient, a view's
   * rows, a map's results, a FHIRPath expression's values, a value set's codes, the resources an
   * FSH file compiles to.
   *
   * Answers a Table {kind, columns, rows, summary}.
   */
  run(args: RunArguments): Promise<any> {
    return this.call("run", args);
  }

  /**
   * A text asked of the data without a file: FHIRPath, CQL, VCL, a FHIR search
   * (`Observation?code=…`), words to find, a view, or SQL over the project's views.
   *
   * Answers a Table {kind, columns, rows, summary}.
   */
  query(args: QueryArguments): Promise<any> {
    return this.call("query", args);
  }

  /**
   * Why a file answered what it did for one subject (a patient, a resource, an entity), each step
   * with its place in the source.
   *
   * Answers an object, by language.
   */
  explain(args: ExplainArguments): Promise<any> {
    return this.call("explain", args);
  }

  /**
   * A FHIRPath expression evaluated over one resource.
   *
   * Answers {values: [json…]}: FHIR JSON for an element, a JSON number, boolean or string for a
   * System value.
   */
  fhirpath(args: FhirpathArguments): Promise<any> {
    return this.call("fhirpath", args);
  }

  /**
   * A CQL library translated to ELM, with every translation error and warning; includes are found
   * in the project, then among the libraries the toolkit carries.
   *
   * Answers {elm: the library's ELM as JSON (null when it has errors), diagnostics: [Diagnostic…]}.
   */
  translate(args: TranslateArguments): Promise<any> {
    return this.call("translate", args);
  }

  /**
   * A FHIR resource written as source text: FSH (a profile, value set, code system, instance), the
   * mapping language (a StructureMap), a view's text (a ViewDefinition), VCL (a ValueSet's
   * compose), CQL (a Library that carries it).
   *
   * Answers {language, text}.
   */
  decompile(args: DecompileArguments): Promise<any> {
    return this.call("decompile", args);
  }

  /**
   * A resource held to its type, the profiles it claims and one more when named; profiles the
   * project defines are in context.
   *
   * Answers an OperationOutcome.
   */
  validate(args: ValidateArguments): Promise<any> {
    return this.call("validate", args);
  }

  /**
   * A resource converted by a map written in the mapping language; structures the project defines
   * (logical models, profiles) are in context.
   *
   * Answers the resulting resource.
   */
  transform(args: TransformArguments): Promise<any> {
    return this.call("transform", args);
  }

  /**
   * Any FHIR operation the toolkit implements, by reference: $expand, $validate-code, $lookup,
   * $translate, $snapshot, $evaluate-measure, $sql-run and the others.
   *
   * Answers the resource the operation returns (its `return`, or a Parameters of its outputs).
   */
  operation(args: OperationArguments): Promise<any> {
    return this.call("operation", args);
  }

  /**
   * A write prepared and not yet made: resources, given as JSON or as FSH Instances, validated in
   * the project's context (the profiles they claim, the project's own among them) and compared with
   * what the data holds: created, changed (each path old → new) or unchanged, with every error.
   * Nothing is written until commit.
   *
   * Answers {stage, changes: [{resource, action, changed, errors, warnings}…], errors}: `stage` the
   * id commit takes (none when nothing differs or with keep false), `action` create | update |
   * unchanged, `errors` their count.
   */
  stage(args: StageArguments): Promise<any> {
    return this.call("stage", args);
  }

  /**
   * A stage written to the data, with its trail: the resources in one step (a SQLite store: one
   * transaction), then a Provenance (the versions written, who, why, the source text with its hash)
   * and an AuditEvent. A stage with errors is refused.
   *
   * Answers {stage, written: [{resource, version, status, ok}…], provenance, reason, agent}:
   * `version` as Type/id/_history/n, `provenance` the Provenance written.
   */
  commit(args: CommitArguments): Promise<any> {
    return this.call("commit", args);
  }

  /**
   * A guide to one of the languages or to FHIR itself, written for an agent; without a topic, the
   * topics.
   *
   * Answers {topics: [string…]} or {topic, text}.
   */
  guide(args: GuideArguments = {}): Promise<any> {
    return this.call("guide", args);
  }

  /**
   * What this process is: the protocol's version, the FHIR version it reads, the packages in
   * context, its functions.
   *
   * Answers {protocol, fhirVersion, packages, functions}.
   */
  version(args: VersionArguments = {}): Promise<any> {
    return this.call("version", args);
  }
}
