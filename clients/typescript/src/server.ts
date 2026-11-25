// One process of the function server, spoken to over JSON lines (JSON-RPC 2.0).
import { spawn, type ChildProcessByStdio } from "node:child_process";
import { existsSync, statSync } from "node:fs";
import { delimiter, join } from "node:path";
import { createInterface } from "node:readline";
import type { Readable, Writable } from "node:stream";

import { FhirError, ToolkitNotFound, type Diagnostic } from "./errors.js";
import { PROTOCOL } from "./functions.js";

/** The environment variable that names the command to start. */
export const COMMAND_VARIABLE = "FHIR_API_COMMAND";

// onPath : name -> boolean   is there a program of that name on the PATH?
function onPath(name: string): boolean {
  const endings = process.platform === "win32" ? (process.env.PATHEXT ?? ".EXE;.CMD;.BAT").split(";") : [""];
  for (const directory of (process.env.PATH ?? "").split(delimiter)) {
    for (const ending of endings) {
      const candidate = join(directory, name + ending);
      if (directory && existsSync(candidate) && statSync(candidate).isFile()) return true;
    }
  }
  return false;
}

/**
 * The command that starts the function server, looked for in this order: the one given; the
 * FHIR_API_COMMAND environment variable (words separated by spaces); `fhir-api` on the PATH (a
 * standalone build); `raco fhir-api` (Racket with the toolkit's packages installed).
 */
export function findCommand(command?: readonly string[]): string[] {
  if (command && command.length > 0) return [...command];
  const named = process.env[COMMAND_VARIABLE];
  if (named && named.trim()) return named.trim().split(/\s+/);
  if (onPath("fhir-api")) return ["fhir-api"];
  if (onPath("raco")) return ["raco", "fhir-api"];
  throw new ToolkitNotFound(
    "no FHIR toolkit to start: neither `fhir-api` nor `raco` is on the PATH. Put a standalone build's bin directory " +
      `on the PATH, or set ${COMMAND_VARIABLE} to the command that starts it (for a source checkout with Racket: "raco fhir-api").`,
  );
}

// the server's process: its input and output are pipes, what it says is wrong goes where ours does
type Child = ChildProcessByStdio<Writable, Readable, null>;

// a call that has been sent and not answered, with the process it was sent to
interface Waiting {
  child: Child;
  name: string;
  resolve: (value: any) => void;
  reject: (error: Error) => void;
}

/**
 * One process of the function server, started at the first call. A process reads one version of
 * FHIR. Calls may be made at once: they are sent in order and each is answered by its id.
 *
 * While no call is waiting the process does not keep Node running, so a script ends when it is
 * done; `close()` stops the process at once.
 */
export class Server {
  readonly fhirVersion: string;
  readonly packages: string[];
  private readonly command?: readonly string[];
  private process?: Child;
  private starting?: Promise<void>;
  private waiting = new Map<number, Waiting>();
  private id = 0;

  constructor(fhirVersion = "4.0.1", packages: readonly string[] = [], command?: readonly string[]) {
    this.fhirVersion = fhirVersion;
    this.packages = [...packages];
    this.command = command;
  }

  get running(): boolean {
    return this.process !== undefined && this.process.exitCode === null && !this.process.killed;
  }

  // ---- the process ----------------------------------------------------------------------------
  private start(): Promise<void> {
    const words = [...findCommand(this.command), "serve", "--fhir-version", this.fhirVersion];
    for (const p of this.packages) words.push("--package", p);
    const child = spawn(words[0], words.slice(1), { stdio: ["pipe", "pipe", "inherit"] });
    this.process = child;
    // what this process had not answered when it went is refused; a call sent to another
    // process (the one started after a close) is that process's to answer
    const refuse = (error: (name: string) => Error) => {
      if (this.process === child) this.process = undefined;
      for (const [id, w] of this.waiting) {
        if (w.child !== child) continue;
        this.waiting.delete(id);
        w.reject(error(w.name));
      }
    };
    child.on("error", (e) => refuse(() => new ToolkitNotFound(`could not start the FHIR toolkit (${words.join(" ")}): ${e.message}`)));
    child.on("exit", (status) => {
      const why = status === null ? "" : ` (exit status ${status})`;
      refuse((name) => new FhirError(`the FHIR toolkit's process ended${why} while answering ${name}; it starts again at the next call`));
    });
    child.stdin.on("error", () => { /* the process went away: its exit says so */ });
    createInterface({ input: child.stdout }).on("line", (line) => this.answered(line));
    return this.exchange(child, "version", {}).then((version) => {
      if (version?.protocol !== PROTOCOL) {
        this.close();
        throw new FhirError(
          `the toolkit that was started speaks protocol ${version?.protocol} and this package protocol ${PROTOCOL}: install matching versions`,
        );
      }
    });
  }

  /** Stop the process (it starts again at the next call). */
  close(): void {
    const child = this.process;
    this.process = undefined;
    this.starting = undefined;
    if (!child) return;
    child.stdin.end();
    const stop = setTimeout(() => child.kill(), 10000);
    stop.unref();
    child.once("exit", () => clearTimeout(stop));
  }

  // while a call waits, the process keeps Node running; idle, it does not
  private hold(child: Child, held: boolean): void {
    const streams = [child.stdin, child.stdout] as unknown as Array<{ ref?: () => void; unref?: () => void }>;
    if (held) { child.ref(); for (const s of streams) s.ref?.(); }
    else { child.unref(); for (const s of streams) s.unref?.(); }
  }

  // ---- a call ---------------------------------------------------------------------------------
  private answered(line: string): void {
    let reply: any;
    try { reply = JSON.parse(line); } catch { return; }
    const w = this.waiting.get(reply.id);
    if (!w) return;
    this.waiting.delete(reply.id);
    if (![...this.waiting.values()].some((other) => other.child === w.child)) this.hold(w.child, false);
    if (reply.error) {
      const data = reply.error.data ?? {};
      w.reject(new FhirError(reply.error.message ?? "the call failed", {
        diagnostics: (data.diagnostics ?? []) as Diagnostic[],
        outcome: data.outcome,
        code: reply.error.code,
      }));
    } else w.resolve(reply.result);
  }

  private exchange(child: Child, name: string, args: object): Promise<any> {
    return new Promise((resolve, reject) => {
      const id = ++this.id;
      this.waiting.set(id, { child, name, resolve, reject });
      this.hold(child, true);
      child.stdin.write(JSON.stringify({ jsonrpc: "2.0", id, method: name, params: args }) + "\n");
    });
  }

  /** One function called by name: its answer as JSON values, or a FhirError. */
  async call(name: string, args: object): Promise<any> {
    if (!this.running) {
      this.starting = this.start();
    }
    try {
      await this.starting;
    } catch (e) {
      this.starting = undefined;
      throw e;
    }
    const child = this.process;
    if (!child) throw new FhirError(`the FHIR toolkit's process ended before ${name} could be asked; it starts again at the next call`);
    return this.exchange(child, name, args);
  }
}
