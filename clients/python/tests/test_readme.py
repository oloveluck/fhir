"""The README's examples are run, and print what the README says they print.

Each ```python block is executed, in order and in one namespace; a ```text block right after
it is that block's output.
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

if not os.environ.get("FHIR_TOOLKIT_TEST_INSTALLED"):
    sys.path.insert(0, str(ROOT / "src"))

BLOCK = re.compile(r"```(python|text)\n(.*?)```", re.DOTALL)


class TheReadme(unittest.TestCase):
    def test_every_example_prints_what_it_says(self):
        blocks = BLOCK.findall((ROOT / "README.md").read_text(encoding="utf-8"))
        programs = [i for i, (kind, _) in enumerate(blocks) if kind == "python"]
        self.assertGreaterEqual(len(programs), 6)
        try:
            import pandas  # noqa: F401
        except ImportError:
            self.skipTest("the README's DataFrame example needs pandas")
        namespace = {}
        try:
            for i in programs:
                printed = io.StringIO()
                with contextlib.redirect_stdout(printed):
                    exec(blocks[i][1], namespace)
                if i + 1 < len(blocks) and blocks[i + 1][0] == "text":
                    self.assertEqual(printed.getvalue(), blocks[i + 1][1], "the example\n" + blocks[i][1])
        finally:
            if "fhir" in namespace:
                namespace["fhir"].close()


if __name__ == "__main__":
    unittest.main()
