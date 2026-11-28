"""The README's examples are run, and print what the README says they print.

Each ```python block is executed, in order and in one namespace; a ```text block right after
it is that block's output. An ```ipython block is a notebook cell: it is run by an IPython
shell over the same namespace, and what the cell prints, shows as its result or says is wrong
is the ```text block after it.

An example that needs a library this environment lacks (pandas, fhir.resources, IPython) is
not run, and the test is then reported as skipped, naming what was left out: the examples
before and after it are still held to their output.
"""
import contextlib
import io
import pathlib
import re
import sys
import unittest

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
import os  # noqa: E402

if not os.environ.get("AGENTFHIR_TEST_INSTALLED"):
    sys.path.insert(0, str(ROOT / "src"))

BLOCK = re.compile(r"```(python|ipython|text)\n(.*?)```", re.DOTALL)
OPTIONAL = ("pandas", "fhir", "pydantic", "IPython")
OUT_PROMPT = re.compile(r"^Out\[\d+\]: ?\n?", re.MULTILINE)


def missing_library(error):
    """The optional library an ImportError is about, or None."""
    name = (getattr(error, "name", None) or "").split(".")[0]
    return name if name in OPTIONAL else None


class TheReadme(unittest.TestCase):
    def run_python(self, text, namespace):
        printed = io.StringIO()
        with contextlib.redirect_stdout(printed):
            exec(text, namespace)
        return printed.getvalue()

    def run_cell(self, text, namespace):
        from IPython.core.interactiveshell import InteractiveShell
        shell = InteractiveShell.instance()
        shell.user_ns.update({k: v for k, v in namespace.items() if not k.startswith("__")})
        printed = io.StringIO()
        with contextlib.redirect_stdout(printed), contextlib.redirect_stderr(printed):
            result = shell.run_cell(text)
        if result.error_in_exec is not None:
            raise result.error_in_exec
        # a cell's result is shown under an `Out[n]:` prompt, which the README leaves out
        return OUT_PROMPT.sub("", printed.getvalue())

    def test_every_example_prints_what_it_says(self):
        blocks = BLOCK.findall((ROOT / "README.md").read_text(encoding="utf-8"))
        programs = [i for i, (kind, _) in enumerate(blocks) if kind in ("python", "ipython")]
        self.assertGreaterEqual(len(programs), 12)
        namespace = {}
        left_out = []
        try:
            for i in programs:
                kind, text = blocks[i]
                try:
                    printed = self.run_cell(text, namespace) if kind == "ipython" else self.run_python(text, namespace)
                except ImportError as error:
                    if missing_library(error) is None:
                        raise
                    left_out.append(missing_library(error))
                    continue
                if i + 1 < len(blocks) and blocks[i + 1][0] == "text":
                    self.assertEqual(printed, blocks[i + 1][1], "the example\n" + text)
        finally:
            if "fhir" in namespace:
                namespace["fhir"].close()
            if "IPython" not in left_out and "agentfhir.jupyter" in sys.modules:
                sys.modules["agentfhir.jupyter"].notebook.context.close()
        if left_out:
            self.skipTest("examples not run for want of: " + ", ".join(sorted(set(left_out))))


if __name__ == "__main__":
    unittest.main()
