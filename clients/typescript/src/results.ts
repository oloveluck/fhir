// What the toolkit's functions answer, as values with a few methods.
import { diagnosticLine, FhirError, type Diagnostic } from "./errors.js";

export type Resource = Record<string, any>;
export type Row = Record<string, any>;

/** Rows with named columns: what `run` and `query` answer. */
export class Table implements Iterable<Row> {
  readonly kind: string;
  /** the keys of each row, in order */
  readonly columns: string[];
  readonly rows: Row[];
  readonly summary: Record<string, any>;

  constructor(js: Record<string, any>) {
    this.kind = js.kind ?? "table";
    this.columns = js.columns ?? [];
    this.rows = js.rows ?? [];
    this.summary = js.summary ?? {};
  }

  get length(): number { return this.rows.length; }
  [Symbol.iterator](): Iterator<Row> { return this.rows[Symbol.iterator](); }

  /** One column's values, in row order. */
  column(name: string): any[] {
    if (!this.columns.includes(name)) throw new FhirError(`no column ${name} (the columns: ${this.columns.join(", ")})`);
    return this.rows.map((r) => r[name]);
  }

  /** The rows as arrays, in column order (a header first when asked): what a CSV writer takes. */
  toArrays(header = false): any[][] {
    const body = this.rows.map((r) => this.columns.map((c) => r[c]));
    return header ? [this.columns, ...body] : body;
  }
}

/** What a project's files define, with every problem in them. */
export class Compiled implements Iterable<Resource> {
  readonly resources: Resource[];
  readonly diagnostics: Diagnostic[];

  constructor(js: Record<string, any>) {
    this.resources = js.resources ?? [];
    this.diagnostics = js.diagnostics ?? [];
  }

  get errors(): Diagnostic[] { return this.diagnostics.filter((d) => d.severity === "error"); }
  get warnings(): Diagnostic[] { return this.diagnostics.filter((d) => d.severity === "warning"); }
  get ok(): boolean { return this.errors.length === 0; }
  [Symbol.iterator](): Iterator<Resource> { return this.resources[Symbol.iterator](); }

  ofType(resourceType: string): Resource[] { return this.resources.filter((r) => r.resourceType === resourceType); }

  /** The one resource of that type (and id, when given). */
  resource(resourceType: string, id?: string): Resource {
    const found = this.ofType(resourceType).filter((r) => id === undefined || r.id === id);
    if (found.length !== 1) throw new FhirError(`${found.length} resources are ${resourceType}${id ? "/" + id : ""}`);
    return found[0];
  }

  raiseForErrors(): this {
    if (!this.ok) throw new FhirError(this.errors.map(diagnosticLine).join("\n"), { diagnostics: this.errors, result: this });
    return this;
  }
}

/** A validation's answer: the FHIR OperationOutcome, read. */
export class Outcome {
  readonly resource: Resource;
  readonly issues: Array<Record<string, any>>;

  constructor(resource: Resource) {
    this.resource = resource;
    this.issues = resource.issue ?? [];
  }

  get errors(): Array<Record<string, any>> { return this.issues.filter((i) => i.severity === "error" || i.severity === "fatal"); }
  get warnings(): Array<Record<string, any>> { return this.issues.filter((i) => i.severity === "warning"); }
  /** Valid: no issue is an error (warnings do not count). */
  get ok(): boolean { return this.errors.length === 0; }

  /** Each error and warning as a line: `Patient.gender: error: …`. */
  messages(): string[] {
    return [...this.errors, ...this.warnings].map((i) => {
      const where = (i.expression ?? i.location ?? [""])[0];
      return `${where}${where ? ": " : ""}${i.severity}: ${i.diagnostics ?? i.code}`;
    });
  }

  raiseForErrors(): this {
    if (!this.ok) throw new FhirError(this.messages().join("\n"), { outcome: this.resource });
    return this;
  }
}

/** What a commit wrote: each resource's new version, and the Provenance that records it. */
export class Commit {
  readonly raw: Record<string, any>;
  readonly written: Array<Record<string, any>>;
  readonly provenance?: string;
  readonly reason?: string;
  readonly agent?: string;

  constructor(js: Record<string, any>) {
    this.raw = js;
    this.written = js.written ?? [];
    this.provenance = js.provenance ?? undefined;
    this.reason = js.reason ?? undefined;
    this.agent = js.agent ?? undefined;
  }

  /** The versions written, each as `Type/id/_history/n`. */
  get versions(): string[] { return this.written.map((w) => w.version).filter((v) => typeof v === "string"); }
  get length(): number { return this.written.length; }
}

/**
 * A write prepared and not yet made: what would be created or changed, and every problem.
 *
 * `changes` is one entry per resource: `resource` (Type/id), `action` (create, update,
 * unchanged), `changed` (an update's paths, each `path: old → new`), `errors` and `warnings`.
 * `id` names the stage for a commit (undefined when nothing differs, or after a check only).
 */
export class Stage {
  readonly raw: Record<string, any>;
  readonly id?: string;
  readonly changes: Array<Record<string, any>>;
  private readonly committer?: (reason?: string, agent?: string) => Promise<Commit>;

  constructor(js: Record<string, any>, committer?: (reason?: string, agent?: string) => Promise<Commit>) {
    this.raw = js;
    this.id = js.stage ?? undefined;
    this.changes = js.changes ?? [];
    this.committer = committer;
  }

  private lines(key: string): string[] {
    return this.changes.flatMap((c) => ((c[key] ?? []) as string[]).map((line) => `${c.resource}: ${line}`));
  }

  /** Each error as a line: `Observation/a2: Observation.status: …`. */
  get errors(): string[] { return this.lines("errors"); }
  get warnings(): string[] { return this.lines("warnings"); }
  /** Nothing stands in the way of a commit (warnings do not). */
  get ok(): boolean { return this.errors.length === 0; }

  /** The resources (Type/id) with that action: create, update or unchanged. */
  of(action: string): string[] { return this.changes.filter((c) => c.action === action).map((c) => c.resource); }

  raiseForErrors(): this {
    if (!this.ok) throw new FhirError(this.errors.join("\n"));
    return this;
  }

  /** Write this stage to the data it was staged for, with its trail. */
  commit(reason?: string, options: { agent?: string } = {}): Promise<Commit> {
    if (!this.committer || this.id === undefined) {
      const why = this.ok ? "the stage was a check only, or nothing differs from the data" : "the stage has errors";
      return Promise.reject(new FhirError(`nothing to commit: ${why}`));
    }
    return this.committer(reason, options.agent);
  }
}
