"""The `agentfhir` command.

    agentfhir mcp [--workspace DIR] [--verbs query,describe] …   the MCP server over a workspace
    agentfhir mcp init [DIR]                                      a workspace an agent can open
    agentfhir version

`agentfhir mcp …` is the engine's MCP server (`fhir-mcp`) with the same arguments: the
executable this package carries when it carries one, else `fhir-mcp` on the PATH (a
standalone build), else `raco fhir-mcp` (Racket with the engine's packages installed). For
Claude Code: `claude mcp add fhir -- agentfhir mcp --workspace <dir>`.
"""
import os
import shutil
import subprocess
import sys
from typing import List, Optional, Sequence

from ._server import bundled_command

USAGE = __doc__.split("\n\n")[1]


def mcp_command() -> Optional[List[str]]:
    """The command that starts the MCP server, or None when there is none to start."""
    bundled = bundled_command("fhir-mcp")
    if bundled:
        return bundled
    if shutil.which("fhir-mcp"):
        return ["fhir-mcp"]
    if shutil.which("raco"):
        return ["raco", "fhir-mcp"]
    return None


def main(argv: Optional[Sequence[str]] = None) -> int:
    """Run the command line; the exit status."""
    args = list(sys.argv[1:] if argv is None else argv)
    if not args or args[0] in ("-h", "--help", "help"):
        print("usage:\n" + USAGE)
        return 0 if args else 2
    if args[0] in ("version", "--version"):
        from . import __version__
        print("agentfhir " + __version__)
        return 0
    if args[0] == "mcp":
        command = mcp_command()
        if command is None:
            print("agentfhir: no MCP server to start: this installation carries none, and neither `fhir-mcp` nor "
                  "`raco` is on the PATH (a standalone build's `fhir-mcp`, or Racket with the engine installed)",
                  file=sys.stderr)
            return 1
        if os.name == "nt":                      # no exec there: run it and pass its status on
            return subprocess.call(command + args[1:])
        os.execvp(command[0], command + args[1:])  # the server speaks over this process's own stdin and stdout
    print("agentfhir: unknown command `%s`\nusage:\n%s" % (args[0], USAGE), file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())
