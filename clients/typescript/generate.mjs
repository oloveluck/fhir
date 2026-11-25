#!/usr/bin/env node
// Write src/functions.ts from ../functions.json.
//
// clients/functions.json is the toolkit's table of functions (written by
// `raco fhir-api functions --json`). This script turns it into one method per function, with
// the arguments' names, types and descriptions, so the client cannot drift from the server:
// run it after the table changes. `--check` writes nothing and exits 1 when the file is stale.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const table = JSON.parse(readFileSync(join(here, "..", "functions.json"), "utf8"));
const target = join(here, "src", "functions.ts");

// typeOf : JSON Schema -> a TypeScript type
function typeOf(schema) {
  if (schema.anyOf) return schema.anyOf.map(typeOf).join(" | ");
  switch (schema.type) {
    case "string": return "string";
    case "boolean": return "boolean";
    case "array": return `Array<${typeOf(schema.items ?? {})}>`;
    case "object": return schema.additionalProperties ? `Record<string, ${typeOf(schema.additionalProperties)}>` : "Record<string, unknown>";
    default: return "unknown";
  }
}

// wrapped : text indent -> a comment's lines, at most 100 characters each
function wrapped(text, indent) {
  const lines = [];
  let line = "";
  for (const word of text.split(/\s+/)) {
    if (line && (indent + line + " " + word).length > 100) { lines.push(line); line = word; }
    else line = line ? line + " " + word : word;
  }
  if (line) lines.push(line);
  return lines.map((l) => `${indent}${l}`.replace(/\*\//g, "* /"));
}

const pascal = (name) => name[0].toUpperCase() + name.slice(1);

function argumentsOf(f) {
  const { properties, required } = f.parameters;
  const lines = [`/** What \`${f.name}\` takes. */`, `export interface ${pascal(f.name)}Arguments {`];
  for (const name of f.order) {
    lines.push("  /**", ...wrapped(properties[name].description, "   * "), "   */");
    lines.push(`  ${name}${required.includes(name) ? "" : "?"}: ${typeOf(properties[name])};`);
  }
  lines.push("}");
  return lines.join("\n");
}

function methodOf(f) {
  const optional = f.parameters.required.length === 0;
  return [
    "  /**",
    ...wrapped(f.summary, "   * "),
    "   *",
    ...wrapped(`Answers ${f.returns}.`, "   * "),
    "   */",
    `  ${f.name}(args: ${pascal(f.name)}Arguments${optional ? " = {}" : ""}): Promise<any> {`,
    `    return this.call(${JSON.stringify(f.name)}, args);`,
    "  }",
  ].join("\n");
}

const text = `// The toolkit's functions, one method each. GENERATED: do not edit.
//
// Written by clients/typescript/generate.mjs from clients/functions.json, the table the function
// server answers from (\`raco fhir-api functions\`). Each method sends its arguments as they are
// and answers the server's result as plain JSON values; \`Toolkit\` builds the friendlier
// interface on top.

export const PROTOCOL = ${table.protocol};
export const FUNCTIONS = ${JSON.stringify(table.functions.map((f) => f.name))} as const;

${table.functions.map(argumentsOf).join("\n\n")}

/** One method per function of the table. A subclass provides \`call\`. */
export abstract class Functions {
  protected abstract call(name: string, args: object): Promise<any>;

${table.functions.map(methodOf).join("\n\n")}
}
`;

if (process.argv.includes("--check")) {
  let current = "";
  try { current = readFileSync(target, "utf8"); } catch { /* not written yet */ }
  if (current !== text) {
    console.error("src/functions.ts is not what clients/functions.json gives: run `node generate.mjs`");
    process.exit(1);
  }
} else {
  writeFileSync(target, text);
  console.log(`wrote src/functions.ts (${table.functions.length} functions)`);
}
