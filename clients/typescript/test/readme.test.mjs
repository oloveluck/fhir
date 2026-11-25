// The README's examples are run, and print what the README says they print.
//
// The ```js blocks are one program, in order (an example uses what the ones before it
// defined). Each is followed by a marker line, so that what it printed can be told apart and
// compared with the ```text block after it.
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { test } from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, "..");
const MARK = "=== the next example ===";

test("every example of the README prints what it says", () => {
  const blocks = [...readFileSync(join(root, "README.md"), "utf8").matchAll(/```(js|text)\n(.*?)```/gs)].map((m) => [m[1], m[2]]);
  const programs = blocks.map(([kind], i) => (kind === "js" ? i : -1)).filter((i) => i >= 0);
  assert.ok(programs.length >= 5);
  // imports are hoisted in a module: the package's name becomes this build, wherever it is said
  const library = pathToFileURL(join(root, "dist", "index.js")).href;
  const program = programs.map((i) => blocks[i][1].replaceAll('from "fhir-toolkit"', `from ${JSON.stringify(library)}`))
    .join(`\nconsole.log(${JSON.stringify(MARK)});\n`) + "\nfhir.close();\n";
  const tmp = mkdtempSync(join(tmpdir(), "fhir-toolkit-readme-"));
  try {
    writeFileSync(join(tmp, "readme.mjs"), program);
    const printed = execFileSync(process.execPath, [join(tmp, "readme.mjs")], { encoding: "utf8" }).split(MARK + "\n");
    assert.equal(printed.length, programs.length);
    programs.forEach((i, n) => {
      if (i + 1 < blocks.length && blocks[i + 1][0] === "text") assert.equal(printed[n], blocks[i + 1][1], "the example\n" + blocks[i][1]);
    });
  } finally {
    rmSync(tmp, { recursive: true, force: true });
  }
});
