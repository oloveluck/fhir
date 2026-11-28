"""The `agentfhir` command: its usage, its version, and `mcp` handing over to the engine's MCP server."""
import contextlib
import io
import os
import pathlib
import shutil
import subprocess
import sys
import unittest
from unittest import mock

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
if str(ROOT / "src") not in sys.path:
    sys.path.insert(0, str(ROOT / "src"))

import agentfhir  # noqa: E402
from agentfhir import cli  # noqa: E402


def run(*args):
    out, err = io.StringIO(), io.StringIO()
    with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
        status = cli.main(list(args))
    return status, out.getvalue(), err.getvalue()


class Command(unittest.TestCase):
    def test_usage_and_version(self):
        status, out, _ = run()
        self.assertEqual(status, 2)
        self.assertIn("agentfhir mcp", out)
        self.assertEqual(run("--help")[0], 0)
        self.assertEqual(run("version")[:2], (0, "agentfhir %s\n" % agentfhir.__version__))
        status, _, err = run("mpc")
        self.assertEqual(status, 2)
        self.assertIn("unknown command `mpc`", err)

    def test_mcp_with_nothing_to_start_says_so(self):
        with mock.patch.object(cli, "bundled_command", return_value=None), mock.patch.object(shutil, "which", return_value=None):
            status, _, err = run("mcp")
        self.assertEqual(status, 1)
        self.assertIn("no MCP server to start", err)

    def test_mcp_prefers_what_the_package_carries(self):
        with mock.patch.object(cli, "bundled_command", return_value=["/x/_bin/bin/fhir-mcp"]):
            self.assertEqual(cli.mcp_command(), ["/x/_bin/bin/fhir-mcp"])

    @unittest.skipUnless(shutil.which("fhir-mcp") or shutil.which("raco"), "no MCP server here")
    def test_mcp_runs_the_server_with_the_arguments_given(self):
        answer = subprocess.run([sys.executable, "-m", "agentfhir.cli", "mcp", "--help"], capture_output=True, text=True,
                                env=dict(os.environ, PYTHONPATH=str(ROOT / "src")), timeout=120)
        self.assertEqual(answer.returncode, 0, answer.stderr)
        self.assertIn("fhir-mcp", answer.stdout)

    def test_a_context_by_its_version(self):
        with mock.patch("agentfhir.context.Server") as server:
            server.return_value.fhir_version = "5.0.0"
            agentfhir.FhirContext.r5(start=False)
            agentfhir.FhirContext.r4(start=False)
        self.assertEqual([c.args[0] for c in server.call_args_list], ["5.0.0", "4.0.1"])


if __name__ == "__main__":
    unittest.main()
