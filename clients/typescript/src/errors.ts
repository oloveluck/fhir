// What the toolkit says when something is wrong.

/** One problem, at its place in a source text (`source` a file of the project by its name there). */
export interface Diagnostic {
  severity: string;
  message: string;
  lang?: string;
  phase?: string;
  source?: string;
  /** counted from 1 */
  line?: number;
  column?: number;
}

/** A diagnostic as a line: `profiles.fsh:3:3: error: …`. */
export function diagnosticLine(d: Diagnostic): string {
  let where = d.source ?? "";
  if (d.line != null) where += `:${d.line}` + (d.column != null ? `:${d.column}` : "");
  return `${where}${where ? ": " : ""}${d.severity}: ${d.message}`;
}

/**
 * A call the toolkit could not answer, or an answer with errors in it.
 *
 * `diagnostics`: the problems that have a place in a source text, if any. `outcome`: the FHIR
 * OperationOutcome, when an operation refused. `code`: the protocol's error code, when the
 * server refused the call. `result`: what was produced all the same, when there is something.
 */
export class FhirError extends Error {
  diagnostics: Diagnostic[];
  outcome?: Record<string, unknown>;
  code?: number;
  result?: unknown;

  constructor(message: string, more: { diagnostics?: Diagnostic[]; outcome?: Record<string, unknown>; code?: number; result?: unknown } = {}) {
    super(message);
    this.name = "FhirError";
    this.diagnostics = more.diagnostics ?? [];
    this.outcome = more.outcome;
    this.code = more.code;
    this.result = more.result;
  }
}

/** No toolkit to start: none named, none on the PATH. */
export class ToolkitNotFound extends FhirError {
  constructor(message: string) {
    super(message);
    this.name = "ToolkitNotFound";
  }
}
