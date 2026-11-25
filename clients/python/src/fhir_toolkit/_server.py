"""The toolkit's process: found, started, and spoken to a line at a time."""
import json
import os
import shlex
import shutil
import subprocess
import threading
from typing import Any, Dict, List, Optional, Sequence

from ._functions import PROTOCOL
from .errors import Diagnostic, FhirError, ToolkitNotFound

#: the environment variable that names the command to start, e.g. "raco fhir-api"
COMMAND_VARIABLE = "FHIR_API_COMMAND"


def bundled_command() -> Optional[List[str]]:
    """The executable a wheel carries, beside this module, when it does."""
    here = os.path.dirname(os.path.abspath(__file__))
    # bin/fhir-api on Unix and macOS; on Windows the executable is at the top of the build
    for parts in (("bin", "fhir-api"), ("fhir-api.exe",), ("bin", "fhir-api.exe")):
        candidate = os.path.join(here, "_bin", *parts)
        if os.path.isfile(candidate):
            return [candidate]
    return None


def find_command(command: Optional[Sequence[str]] = None) -> List[str]:
    """The command that starts the function server, looked for in this order:

    the one given; the FHIR_API_COMMAND environment variable; the executable
    bundled with this package; `fhir-api` on the PATH (a standalone build);
    `raco fhir-api` (Racket with the toolkit's packages installed).
    """
    if command:
        return list(command)
    named = os.environ.get(COMMAND_VARIABLE)
    if named:
        return shlex.split(named)
    bundled = bundled_command()
    if bundled:
        return bundled
    if shutil.which("fhir-api"):
        return ["fhir-api"]
    if shutil.which("raco"):
        return ["raco", "fhir-api"]
    raise ToolkitNotFound(
        "no FHIR toolkit to start: this installation carries no executable, and neither `fhir-api` nor `raco` "
        "is on the PATH. Install a wheel built for this platform, or set %s to the command that starts it "
        "(for a source checkout with Racket: \"raco fhir-api\")." % COMMAND_VARIABLE
    )


class Server:
    """One process of the function server, started at the first call.

    A process reads one version of FHIR; calls are answered one at a time
    (a lock makes it safe to share between threads).
    """

    def __init__(self, fhir_version: str = "4.0.1", packages: Sequence[str] = (), command: Optional[Sequence[str]] = None):
        self.fhir_version = fhir_version
        self.packages = list(packages)
        self._command = command
        self._process: Optional[subprocess.Popen] = None
        self._lock = threading.Lock()
        self._id = 0

    # ---- the process --------------------------------------------------------------------------
    def _start(self) -> subprocess.Popen:
        arguments = find_command(self._command) + ["serve", "--fhir-version", self.fhir_version]
        for package in self.packages:
            arguments += ["--package", str(package)]
        try:
            process = subprocess.Popen(arguments, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True, encoding="utf-8")
        except OSError as e:
            raise ToolkitNotFound("could not start the FHIR toolkit (%s): %s" % (" ".join(arguments), e)) from e
        self._process = process
        version = self._exchange("version", {})
        if version.get("protocol") != PROTOCOL:
            self.close()
            raise FhirError(
                "the toolkit that was started speaks protocol %s and this package protocol %s: install matching versions"
                % (version.get("protocol"), PROTOCOL)
            )
        return process

    @property
    def running(self) -> bool:
        return self._process is not None and self._process.poll() is None

    def close(self) -> None:
        """Stop the process (it starts again at the next call)."""
        process, self._process = self._process, None
        if process is None:
            return
        try:
            if process.stdin and not process.stdin.closed:
                process.stdin.close()
            process.wait(timeout=10)
        except Exception:
            process.kill()
            process.wait()
        finally:
            if process.stdout and not process.stdout.closed:
                process.stdout.close()

    # ---- a call ---------------------------------------------------------------------------------
    def _exchange(self, name: str, arguments: Dict[str, Any]) -> Any:
        process = self._process
        assert process is not None and process.stdin is not None and process.stdout is not None
        self._id += 1
        request = {"jsonrpc": "2.0", "id": self._id, "method": name, "params": arguments}
        try:
            process.stdin.write(json.dumps(request) + "\n")
            process.stdin.flush()
            line = process.stdout.readline()
        except (BrokenPipeError, OSError, ValueError):
            line = ""
        if not line:
            self.close()
            status = process.poll()
            raise FhirError("the FHIR toolkit's process ended%s while answering %s; it starts again at the next call"
                            % ("" if status is None else " (exit status %s)" % status, name))
        reply = json.loads(line)
        error = reply.get("error")
        if error:
            data = error.get("data") or {}
            raise FhirError(
                error.get("message", "the call failed"),
                diagnostics=[Diagnostic.from_json(d) for d in data.get("diagnostics", [])],
                outcome=data.get("outcome"),
                code=error.get("code"),
            )
        return reply.get("result")

    def call(self, name: str, arguments: Dict[str, Any]) -> Any:
        """One function called by name: its answer as JSON values, or FhirError."""
        with self._lock:
            if not self.running:
                self.close()  # a process that ended by itself: its pipes are closed before another starts
                self._start()
            return self._exchange(name, arguments)
