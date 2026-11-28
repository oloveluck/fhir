"""The engine's process: found, started, and spoken to a line at a time."""
import json
import os
import re
import secrets
import shlex
import shutil
import subprocess
import threading
from typing import Any, Dict, List, Optional, Sequence

from ._functions import PROTOCOL
from .errors import FhirError, FhirProcessError, FhirTimeout, FhirEngineNotFound, failure, warn
from .models import model_json, plain

#: the environment variable that names the command to start, e.g. "raco fhir-api"
COMMAND_VARIABLE = "FHIR_API_COMMAND"


def bundled_command(tool: str = "fhir-api") -> Optional[List[str]]:
    """The executable `tool` a wheel carries, beside this module, when it does."""
    here = os.path.dirname(os.path.abspath(__file__))
    # bin/<tool> on Unix and macOS; on Windows the executable is at the top of the build
    for parts in (("bin", tool), (tool + ".exe",), ("bin", tool + ".exe")):
        candidate = os.path.join(here, "_bin", *parts)
        if os.path.isfile(candidate):
            return [candidate]
    return None


def find_command(command: Optional[Sequence[str]] = None) -> List[str]:
    """The command that starts the function server, looked for in this order:

    the one given; the FHIR_API_COMMAND environment variable; the executable
    bundled with this package; `fhir-api` on the PATH (a standalone build);
    `raco fhir-api` (Racket with the engine's packages installed).
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
    raise FhirEngineNotFound(
        "no FHIR engine to start: this installation carries no executable, and neither `fhir-api` nor `raco` "
        "is on the PATH. Install a wheel built for this platform, or set %s to the command that starts it "
        "(for a source checkout with Racket: \"raco fhir-api\")." % COMMAND_VARIABLE
    )


# A model object among a call's arguments is written by its own library (pydantic writes JSON in
# compiled code), and that text goes into the request as it is: a mark stands where it belongs
# while the rest is encoded, and is replaced after. The mark holds a number nobody else knows, so
# no text a caller gives can be taken for one.
_NONCE = secrets.token_hex(8)
_MARK = "\x00fhir:%s:%%d\x00" % _NONCE
_MARKED = re.compile('"\\\\u0000fhir:%s:(\\d+)\\\\u0000"' % _NONCE)


def encode(request: Any) -> bytes:
    """A request as the line the server reads: JSON, UTF-8, a line feed after it."""
    written: List[str] = []

    def default(value: Any) -> Any:
        text = model_json(value)
        if text is None:
            return plain(value)
        written.append(text)
        return _MARK % (len(written) - 1)

    text = json.dumps(request, default=default, separators=(",", ":"))
    if written:
        text = _MARKED.sub(lambda found: written[int(found.group(1))], text)
    return text.encode("utf-8") + b"\n"


class Server:
    """One process of the function server.

    It is started when this is made, without waiting for it: the process
    loads while the program goes on, so the first call waits less (or not at
    all). `start=False` leaves it until the first call. A process reads one
    version of FHIR; calls are answered one at a time (a lock makes it safe
    to share between threads).

    `timeout` is how many seconds a call may take (None: as long as it
    takes). A call that takes longer, or that is interrupted (Ctrl-C, a
    notebook's stop button), ends the process: its answer would otherwise
    still be on its way, to be read as the NEXT call's. The process starts
    again at the next call (data loaded into it is loaded again by itself).
    """

    def __init__(self, fhir_version: str = "4.0.1", packages: Sequence[str] = (), command: Optional[Sequence[str]] = None,
                 start: bool = True, timeout: Optional[float] = None):
        self.fhir_version = fhir_version
        self.packages = list(packages)
        self.timeout = timeout
        self._command = command
        self._process: Optional[subprocess.Popen] = None
        self._greeted = False
        self._lock = threading.Lock()
        self._id = 0
        #: how many processes this has started: what one process was told (data it loaded) is
        #: gone with it, and a holder of such a thing compares this number to know
        self.generation = 0
        if start:
            with self._lock:
                self._spawn()

    # ---- the process --------------------------------------------------------------------------
    def _spawn(self) -> None:
        """Start the process and return at once; `_greet` (the first call) checks what it is."""
        arguments = find_command(self._command) + ["serve", "--fhir-version", self.fhir_version]
        for package in self.packages:
            arguments += ["--package", str(package)]
        try:
            self._process = subprocess.Popen(arguments, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        except OSError as e:
            raise FhirEngineNotFound("could not start the FHIR engine (%s): %s" % (" ".join(arguments), e)) from e
        self._greeted = False
        self.generation += 1

    def _greet(self) -> None:
        # (not held to `timeout`: this is where a call waits for the process to have started)
        version = self._exchange("version", {}, timed=False)
        if version.get("protocol") != PROTOCOL:
            self.close()
            raise FhirProcessError(
                "the engine that was started speaks protocol %s and this package protocol %s: install matching versions"
                % (version.get("protocol"), PROTOCOL)
            )
        self._greeted = True

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
    def _exchange(self, name: str, arguments: Dict[str, Any], timed: bool = True) -> Any:
        process = self._process
        assert process is not None and process.stdin is not None and process.stdout is not None
        self._id += 1
        # an object of a model library among the arguments goes as the JSON it writes
        line_out = encode({"jsonrpc": "2.0", "id": self._id, "method": name, "params": arguments})
        timed_out = None
        watchdog = None
        if timed and self.timeout is not None:
            timed_out = threading.Event()

            def stop() -> None:
                timed_out.set()
                process.kill()
            watchdog = threading.Timer(self.timeout, stop)
            watchdog.daemon = True
            watchdog.start()
        try:
            try:
                process.stdin.write(line_out)
                process.stdin.flush()
                line = process.stdout.readline()
            except (BrokenPipeError, OSError, ValueError):
                line = b""
        except BaseException:
            # interrupted with the answer still on its way: it must not be the next call's
            self._abandon(process)
            raise
        finally:
            if watchdog is not None:
                watchdog.cancel()
        if not line:
            self.close()
            if timed_out is not None and timed_out.is_set():
                raise FhirTimeout("%s did not answer within %s s: the FHIR engine's process was stopped; it starts again at the "
                                "next call" % (name, self.timeout))
            status = process.poll()
            raise FhirProcessError("the FHIR engine's process ended%s while answering %s; it starts again at the next call"
                            % ("" if status is None else " (exit status %s)" % status, name))
        reply = json.loads(line)
        if reply.get("id") != self._id:
            self.close()
            raise FhirProcessError("the FHIR engine answered another call than %s (answer %r to call %r): its process was stopped; "
                            "it starts again at the next call" % (name, reply.get("id"), self._id))
        said = reply.get("warnings")
        if said:
            warn(said)
        error = reply.get("error")
        if error:
            raise failure(error.get("message", "the call failed"), error.get("code"), error.get("data") or {})
        return reply.get("result")

    def _abandon(self, process: "subprocess.Popen") -> None:
        """Stop a process in the middle of a call, without waiting on what it was doing."""
        self._process = None
        try:
            process.kill()
            process.wait(timeout=10)
        except Exception:
            pass
        for pipe in (process.stdin, process.stdout):
            try:
                if pipe and not pipe.closed:
                    pipe.close()
            except Exception:
                pass

    def call(self, name: str, arguments: Dict[str, Any]) -> Any:
        """One function called by name: its answer as JSON values, or FhirError."""
        with self._lock:
            if not self.running:
                self.close()  # a process that ended by itself: its pipes are closed before another starts
                self._spawn()
            if not self._greeted:
                self._greet()
            return self._exchange(name, arguments)
