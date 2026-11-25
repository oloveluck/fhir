#!/usr/bin/env python3
"""Install a built wheel where nothing else is, and run the client's tests against it.

    python3 clients/python/test_wheel.py <wheel or directory of wheels> [--with pandas]…

A new environment is made in a temporary directory, the wheel (and what --with names) is
installed into it, and the tests are run from an empty directory with an environment that
holds that environment's programs alone: no Racket, no `fhir-api`, no source tree on the
path. So what passes is what `pip install` gives. Exits with the tests' status.
"""
import argparse
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile
import venv

HERE = pathlib.Path(__file__).resolve().parent
WINDOWS = os.name == "nt"
# what a program on Windows cannot start without (the system's own libraries and a temporary directory)
KEPT_ON_WINDOWS = ("SYSTEMROOT", "SYSTEMDRIVE", "WINDIR", "COMSPEC", "PATHEXT", "TEMP", "TMP")


def the_wheel(given):
    if given.is_file():
        return given
    wheels = sorted(given.glob("fhir_toolkit-*.whl"))
    if len(wheels) != 1:
        raise SystemExit("%s holds %d wheels of fhir_toolkit: name the one to test" % (given, len(wheels)))
    return wheels[0]


def bare_environment(programs, home):
    environment = {"PATH": str(programs), "HOME": str(home), "FHIR_TOOLKIT_TEST_INSTALLED": "1"}
    if WINDOWS:
        environment["USERPROFILE"] = str(home)
        for name in KEPT_ON_WINDOWS:
            if os.environ.get(name):
                environment[name] = os.environ[name]
    return environment


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("wheel", type=pathlib.Path)
    parser.add_argument("--with", dest="extras", action="append", default=[], help="another package to install beside it")
    options = parser.parse_args()
    wheel = the_wheel(options.wheel.resolve())
    work = pathlib.Path(tempfile.mkdtemp(prefix="fhir-toolkit-wheel-"))
    try:
        venv.create(work / "env", with_pip=True)
        programs = work / "env" / ("Scripts" if WINDOWS else "bin")
        python = programs / ("python.exe" if WINDOWS else "python")
        subprocess.run([str(python), "-m", "pip", "install", "--quiet", str(wheel)] + options.extras, check=True)
        empty = work / "empty"
        empty.mkdir()
        print("testing %s (%.1f MB) with %s" % (wheel.name, wheel.stat().st_size / 1048576, python), flush=True)
        done = subprocess.run([str(python), "-m", "unittest", "discover", "-s", str(HERE / "tests")],
                              cwd=empty, env=bare_environment(programs, empty))
        return done.returncode
    finally:
        shutil.rmtree(work, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
