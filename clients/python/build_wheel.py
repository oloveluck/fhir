#!/usr/bin/env python3
"""Build a wheel that carries the toolkit's executable, so `pip install` is the whole setup.

    ./build-tools.sh dist fhir-api                       # at the repository's root: the executable
    python3 clients/python/build_wheel.py dist [--out wheels] [--packages core|all]

The standalone build (bin/ — on Windows the executable itself —, lib/, share/fhir-packages/)
is copied into the package as fhir_toolkit/_bin, a wheel is built and tagged for this platform,
and the copy is removed again. `--packages core` (the default) carries the FHIR R4 and R5 core packages only; `all`
carries every package the build holds (US Core, IPS, mCODE and the rest: a larger file).
A package the wheel does not carry is given to `Toolkit(packages=[…])` as a .tgz path.
"""
import argparse
import pathlib
import platform
import shutil
import subprocess
import sys
import sysconfig

HERE = pathlib.Path(__file__).resolve().parent
BUNDLE = HERE / "src" / "fhir_toolkit" / "_bin"
CORE = ("hl7.fhir.r4.core.tgz", "hl7.fhir.r5.core.tgz")


def executable_machine(executable):
    """The processor a macOS executable is for (arm64, x86_64), None when it cannot be told."""
    if executable is None:
        return None
    try:
        archs = subprocess.run(["lipo", "-archs", str(executable)], check=True, capture_output=True, text=True).stdout.split()
    except (OSError, subprocess.CalledProcessError):
        return None
    return archs[0] if len(archs) == 1 else None


def platform_tag(executable=None):
    """The wheel's platform tag for the machine the executable was built on."""
    system = platform.system()
    machine = platform.machine().lower()
    if system == "Linux":
        libc, version = platform.libc_ver()
        if libc != "glibc":
            raise SystemExit("the executable is built against %s; only glibc Linux is tagged" % (libc or "an unknown libc"))
        major, minor = version.split(".")[:2]
        return "manylinux_%s_%s_%s" % (major, minor, machine)
    if system == "Darwin":
        # the system it was built on, and anything newer, for the processor the EXECUTABLE is for:
        # Python's own tag would name what the interpreter was built for (often every processor,
        # and an older system), and an Intel Racket builds an Intel executable on Apple silicon
        return "macosx_%s_0_%s" % (platform.mac_ver()[0].split(".")[0], executable_machine(executable) or machine)
    # Windows ("win-amd64") as sysconfig names it
    return sysconfig.get_platform().replace("-", "_").replace(".", "_")


def copy_build(dist, packages):
    executables = [dist / "bin"] if (dist / "bin").is_dir() else sorted(dist.glob("fhir-api*.exe"))
    if not executables:
        raise SystemExit("%s is not a standalone build (no bin/, no fhir-api.exe): run ./build-tools.sh %s fhir-api first" % (dist, dist))
    if BUNDLE.exists():
        shutil.rmtree(BUNDLE)
    BUNDLE.mkdir(parents=True)
    for entry in executables:
        if entry.is_dir():
            shutil.copytree(entry, BUNDLE / entry.name)
        else:
            shutil.copy2(entry, BUNDLE / entry.name)
    if (dist / "lib").is_dir():
        shutil.copytree(dist / "lib", BUNDLE / "lib", symlinks=True)
    target = BUNDLE / "share" / "fhir-packages"
    target.mkdir(parents=True, exist_ok=True)
    for package in sorted((dist / "share" / "fhir-packages").glob("*.tgz")):
        if packages == "all" or package.name in CORE:
            shutil.copy2(package, target / package.name)
    missing = [name for name in CORE if not (target / name).exists()]
    if missing:
        raise SystemExit("the build holds no %s (install fhir-spec before ./build-tools.sh)" % ", ".join(missing))


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("dist", type=pathlib.Path, help="the standalone build (./build-tools.sh <dist> fhir-api)")
    parser.add_argument("--out", type=pathlib.Path, default=HERE / "wheels", help="where the wheel is written")
    parser.add_argument("--packages", choices=("core", "all"), default="core", help="the FHIR packages the wheel carries")
    options = parser.parse_args()
    out = options.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    dist = options.dist.resolve()
    copy_build(dist, options.packages)
    try:
        for stale in (HERE / "build", HERE / "src" / "fhir_toolkit.egg-info"):
            shutil.rmtree(stale, ignore_errors=True)
        subprocess.run([sys.executable, "-m", "pip", "wheel", str(HERE), "--no-deps", "-w", str(out)], check=True)
        built = sorted(out.glob("fhir_toolkit-*-py3-none-any.whl"))[-1]
        executable = next((p for p in (dist / "bin" / "fhir-api", dist / "fhir-api.exe") if p.is_file()), None)
        subprocess.run([sys.executable, "-m", "wheel", "tags", "--platform-tag", platform_tag(executable), "--remove", str(built)], check=True)
    finally:
        shutil.rmtree(BUNDLE, ignore_errors=True)
        for stale in (HERE / "build", HERE / "src" / "fhir_toolkit.egg-info"):
            shutil.rmtree(stale, ignore_errors=True)
    wheel = sorted(out.glob("fhir_toolkit-*.whl"), key=lambda p: p.stat().st_mtime)[-1]
    print("%s  %.1f MB" % (wheel, wheel.stat().st_size / 1048576))


if __name__ == "__main__":
    main()
