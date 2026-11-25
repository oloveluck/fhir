// The FHIR toolkit from TypeScript and JavaScript.
//
//   import { Toolkit } from "fhir-toolkit";
//
//   const fhir = new Toolkit();
//   await fhir.fhirpath("name.family", patient);              // ["Lee"]
//   (await fhir.validate(patient)).ok;                        // true
//   (await fhir.view("SELECT id, birthDate FROM Patient", data)).rows;
//
// A Toolkit is one process of the toolkit, started at the first call and kept for the calls
// after it. A PROJECT is the sources a call may refer to — profiles in FSH, CQL libraries, maps,
// value sets in VCL, views, FHIR JSON definitions — given as an object of file name -> text, as
// a directory (a string), or as a `Project`. DATA is the FHIR a call reads: resources (an array,
// one resource, a Bundle), or a string naming a directory of FHIR JSON, a JSON file, a SQLite
// FHIR store or a FHIR server's base url.
import { diagnosticLine, FhirError, type Diagnostic } from "./errors.js";
import { Functions } from "./functions.js";
import { Commit, Compiled, Outcome, Stage, Table, type Resource } from "./results.js";
import { Server } from "./server.js";

export type Data = string | Resource | Resource[];
export type ProjectLike = Project | Record<string, string> | string | undefined;

/**
 * The sources a call may refer to: `files` (file name -> text; the name's ending says the
 * language: .fsh, .cql, .map, .vcl, .sof, .fhirpath, .json) or a `directory` on disk.
 * `canonical` is the base of the canonicals files define when they state none.
 */
export class Project {
  readonly files?: Record<string, string>;
  readonly directory?: string;
  readonly canonical?: string;

  constructor(given: { files?: Record<string, string>; directory?: string; canonical?: string } = {}) {
    if (given.files !== undefined && given.directory !== undefined) throw new Error("a project is files or a directory, not both");
    this.files = given.files === undefined ? undefined : { ...given.files };
    this.directory = given.directory;
    this.canonical = given.canonical;
  }

  /** This project and one more file (a project of files only). */
  withFile(name: string, text: string): Project {
    if (this.directory !== undefined) throw new Error(`a project that is a directory takes its files from the directory: write ${name} there`);
    return new Project({ files: { ...(this.files ?? {}), [name]: text }, canonical: this.canonical });
  }

  /** The project as the functions' `files`, `directory` and `canonical`. */
  arguments(): { files?: Record<string, string>; directory?: string; canonical?: string } {
    return { files: this.files, directory: this.directory, canonical: this.canonical };
  }
}

function asProject(project: ProjectLike): Project {
  if (project === undefined) return new Project();
  if (project instanceof Project) return project;
  if (typeof project === "string") return new Project({ directory: project });
  return new Project({ files: project });
}

// the file a CQL library is kept as: its name, as an include would look for it
function libraryFile(text: string): string {
  const named = /^\s*library\s+("([^"]+)"|[A-Za-z_][A-Za-z0-9_.]*)/m.exec(text);
  const name = named ? (named[2] ?? named[1]) : "Library";
  return `${name.split(".").pop()}.cql`;
}

class Raw extends Functions {
  constructor(private readonly server: Server) { super(); }
  // an argument left undefined is not sent
  protected call(name: string, args: object): Promise<any> {
    return this.server.call(name, Object.fromEntries(Object.entries(args).filter(([, v]) => v !== undefined)));
  }
}

export interface ToolkitOptions {
  /** "4.0.1" (the default) or "5.0.0". A process reads one version; make a second Toolkit for the other. */
  fhirVersion?: string;
  /** FHIR packages in context for every call, by name ("hl7.fhir.us.core-6.1.0") or as .tgz paths. */
  packages?: readonly string[];
  /** The command that starts the toolkit, when it should not be found the usual way (`findCommand`). */
  command?: readonly string[];
}

/**
 * One process of the FHIR toolkit. `raw` has every function exactly as the server defines it
 * (plain JSON values); the methods here are the convenient forms.
 */
export class Toolkit {
  readonly raw: Functions;
  private readonly server: Server;

  constructor(options: ToolkitOptions = {}) {
    this.server = new Server(options.fhirVersion ?? "4.0.1", options.packages ?? [], options.command);
    this.raw = new Raw(this.server);
  }

  /** Stop the process. A call after this starts it again. */
  close(): void { this.server.close(); }
  [Symbol.dispose](): void { this.close(); }

  // ---- what the toolkit is ----------------------------------------------------------------------
  /** The protocol, the FHIR version read, the packages in context, the functions. */
  version(): Promise<Record<string, any>> { return this.raw.version(); }

  /** A guide to a language or to FHIR as text; without a topic, the topics. */
  async guide(): Promise<string[]>;
  async guide(topic: string): Promise<string>;
  async guide(topic?: string): Promise<string | string[]> {
    const answer = await this.raw.guide({ topic });
    return topic === undefined ? answer.topics : answer.text;
  }

  // ---- one resource -----------------------------------------------------------------------------
  /**
   * A FHIRPath expression's values over one resource. An element comes back as its FHIR JSON, a
   * System value as a number, a boolean or a string (a date as FHIR writes it: "1980-02-28").
   */
  async fhirpath(expression: string, resource: Resource): Promise<any[]> {
    return (await this.raw.fhirpath({ expression, resource })).values;
  }

  /**
   * A resource held to its type, the profiles it claims and `profile`: a canonical, or the id
   * or name of a profile the project defines.
   */
  async validate(resource: Resource, profile?: string, options: { project?: ProjectLike } = {}): Promise<Outcome> {
    return new Outcome(await this.raw.validate({ resource, profile, ...asProject(options.project).arguments() }));
  }

  /**
   * A resource written as source text: FSH for a profile, value set, code system or instance;
   * the mapping language for a StructureMap; a view's text for a ViewDefinition; CQL for a
   * Library that carries it. `as` picks one: "fsh", "fml", "sof", "vcl", "cql".
   */
  async decompile(resource: Resource, options: { as?: string; project?: ProjectLike } = {}): Promise<string> {
    return (await this.raw.decompile({ resource, as: options.as, ...asProject(options.project).arguments() })).text;
  }

  /** A resource converted by a map written in the FHIR Mapping Language. */
  transform(map: string, source: Resource, options: { project?: ProjectLike } = {}): Promise<Resource> {
    return this.raw.transform({ map, source, ...asProject(options.project).arguments() });
  }

  /** Any FHIR operation the toolkit implements: "$expand", "$validate-code", "$lookup", … */
  operation(operation: string, options: { resource?: Resource; inputs?: Record<string, unknown>; project?: ProjectLike; data?: Data } = {}): Promise<Resource> {
    return this.raw.operation({ operation, resource: options.resource, inputs: options.inputs, data: options.data,
                                ...asProject(options.project).arguments() });
  }

  // ---- a project --------------------------------------------------------------------------------
  /**
   * What a project's files define, as FHIR resources. With `check` (the default) an error in
   * any file throws a FhirError whose `diagnostics` have each error's file, line and column.
   */
  async compile(project: ProjectLike, options: { check?: boolean } = {}): Promise<Compiled> {
    const compiled = new Compiled(await this.raw.compile(asProject(project).arguments()));
    return options.check === false ? compiled : compiled.raiseForErrors();
  }

  /** Every problem in a project's files (errors and warnings); nothing is thrown for them. */
  async check(project: ProjectLike): Promise<Diagnostic[]> {
    return (await this.compile(project, { check: false })).diagnostics;
  }

  /** A CQL library translated to ELM. With `check` (the default) a translation error throws. */
  async translate(text: string, options: { name?: string; project?: ProjectLike; check?: boolean } = {}): Promise<Record<string, any> | null> {
    const answer = await this.raw.translate({ text, name: options.name, ...asProject(options.project).arguments() });
    const errors: Diagnostic[] = (answer.diagnostics ?? []).filter((d: Diagnostic) => d.severity === "error");
    if (options.check !== false && errors.length > 0) throw new FhirError(errors.map(diagnosticLine).join("\n"), { diagnostics: errors });
    return answer.elm ?? null;
  }

  /** One file of the project run over the data. */
  async run(path: string, options: { project: ProjectLike; data?: Data; entry?: string; over?: string; parameters?: Record<string, string> }): Promise<Table> {
    return new Table(await this.raw.run({ path, entry: options.entry, over: options.over, parameters: options.parameters,
                                          data: options.data, ...asProject(options.project).arguments() }));
  }

  /** A text asked of the data: "fhirpath", "cql", "vcl", "search", "find", "view" or "sql". */
  async query(language: string, text: string, options: { project?: ProjectLike; data?: Data; entry?: string; over?: string;
                                                         parameters?: Record<string, string>; strict?: boolean } = {}): Promise<Table> {
    return new Table(await this.raw.query({ language, text, entry: options.entry, over: options.over, parameters: options.parameters,
                                            strict: options.strict, data: options.data, ...asProject(options.project).arguments() }));
  }

  /** Why a file answered what it did for one subject, each step at its place in the source. */
  explain(path: string, subject: string, options: { project: ProjectLike; data?: Data; entry?: string; over?: string;
                                                    parameters?: Record<string, string> }): Promise<Record<string, any>> {
    return this.raw.explain({ path, subject, entry: options.entry, over: options.over, parameters: options.parameters,
                              data: options.data, ...asProject(options.project).arguments() });
  }

  // ---- by language ------------------------------------------------------------------------------
  /**
   * FHIR Shorthand compiled: the resources its entities define. An error (a rule that names no
   * element, an example that breaks its profile) throws a FhirError with the line it is at.
   */
  async fsh(text: string, options: { project?: ProjectLike; canonical?: string } = {}): Promise<Resource[]> {
    const base = asProject(options.project);
    const project = new Project({ files: base.withFile("input.fsh", text).files, canonical: options.canonical ?? base.canonical });
    return (await this.compile(project)).resources;
  }

  /** A CQL library run over the data: one row per patient, one column per define. */
  cql(text: string, data: Data, options: { project?: ProjectLike; entry?: string; parameters?: Record<string, string> } = {}): Promise<Table> {
    const name = libraryFile(text);
    return this.run(name, { project: asProject(options.project).withFile(name, text), data, entry: options.entry, parameters: options.parameters });
  }

  /** A view's rows: SQL on FHIR source text (`SELECT id, birthDate FROM Patient`), or a ViewDefinition as JSON text. */
  view(text: string, data: Data, options: { project?: ProjectLike } = {}): Promise<Table> {
    return this.query("view", text, { project: options.project, data });
  }

  /**
   * A SQL statement over the project's views (each view file is a table of its name). Over a
   * store the statement also reads what the store keeps itself: a table per resource type,
   * `history`, and `trail` (who wrote which version, when and why).
   */
  sql(statement: string, options: { project?: ProjectLike; data: Data }): Promise<Table> {
    return this.query("sql", statement, options);
  }

  /** A FHIR search (`Observation?code=4548-4&date=ge2025`) over the data. */
  search(query: string, data: Data, options: { strict?: boolean } = {}): Promise<Table> {
    return this.query("search", query, { data, strict: options.strict });
  }

  /**
   * A value set's codes, each {system, code, display}. `valueSet` is a canonical url, or a VCL
   * expression such as `(http://loinc.org)(4548-4;17856-6)`.
   */
  async expand(valueSet: string, options: { project?: ProjectLike } = {}): Promise<Array<{ system?: string; code?: string; display?: string }>> {
    if (/^https?:\/\/\S+$/.test(valueSet)) {
      const expansion = (await this.operation("$expand", { inputs: { url: valueSet }, project: options.project })).expansion ?? {};
      return (expansion.contains ?? []).map((c: Record<string, any>) => ({ system: c.system, code: c.code, display: c.display }));
    }
    return (await this.query("vcl", valueSet, { project: options.project })).rows;
  }

  // ---- writing ----------------------------------------------------------------------------------
  /**
   * A write prepared and not yet made. `resources` (an array, one resource, a Bundle) or `fsh`
   * (FSH Instances as text; `Instance: Type/id` with rules alone changes that stored resource)
   * are validated in the project's context and compared with what `data` holds: a SQLite FHIR
   * store (made when the file is not there) or a directory of FHIR JSON. The answer is a
   * `Stage`: `.changes`, `.errors`, `.ok`, and `.commit(reason)`, which writes it.
   * `keep: false` only checks.
   */
  async stage(options: { data: string; resources?: Resource | Resource[]; fsh?: string; project?: ProjectLike; keep?: boolean }): Promise<Stage> {
    const project = asProject(options.project).arguments();
    const answer = await this.raw.stage({ data: options.data, resources: options.resources, fsh: options.fsh,
                                          keep: options.keep === false ? false : undefined, ...project });
    const commit = async (reason?: string, agent?: string) =>
      new Commit(await this.raw.commit({ stage: answer.stage, data: options.data, reason, agent, ...project }));
    return new Stage(answer, answer.stage ? commit : undefined);
  }

  /**
   * Resources written to the data: staged, and committed when nothing is wrong. An error in any
   * of them throws a FhirError and nothing is written. The answer is a `Commit`: the versions
   * written and the Provenance that records who, why and from what (empty when the data already
   * holds them as given).
   */
  async write(options: { data: string; resources?: Resource | Resource[]; fsh?: string; reason?: string; agent?: string;
                         project?: ProjectLike }): Promise<Commit> {
    const staged = await this.stage(options);
    if (!staged.ok) {
      if (staged.id) await this.raw.stage({ data: options.data, drop: staged.id, ...asProject(options.project).arguments() });
      staged.raiseForErrors();
    }
    return staged.id ? staged.commit(options.reason, { agent: options.agent }) : new Commit({});
  }
}
