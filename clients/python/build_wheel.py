#!/usr/bin/env python3
"""Build a wheel that carries the toolkit's executable, so `pip install` is the whole setup.

    ./build-tools.sh dist fhir-api                       # at the repository's root: the executable
    python3 clients/python/build_wheel.py dist [--out wheels] [--packages core|all]

The standalone build (bin/, lib/, share/fhir-packages/) is copied into the package as
fhir_toolkit/_bin, a wheel is built and tagged for this platform, and the copy is removed
again. `--packages core` (the default) carries the FHIR R4 and R5 core packages only; `all`
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


def platform_tag():
    """The wheel's platform tag for the machine the executable was built on."""
    system = platform.system()
    machine = platform.machine().lower()
    if system == "Linux":
        libc, version = platform.libc_ver()
        if libc != "glibc":
            raise SystemExit("the executable is built against %s; only glibc Linux is tagged" % (libc or "an unknown libc"))
        major, minor = version.split(".")[:2]
        return "manylinux_%s_%s_%s" % (major, minor, machine)
    # macOS ("macosx-14.0-arm64") and Windows ("win-amd64") as sysconfig names them
    return sysconfig.get_platform().replace("-", "_").replace(".", "_")


def copy_build(dist, packages):
    if not (dist / "bin").is_dir():
        raise SystemExit("%s is not a standalone build (no bin/): run ./build-tools.sh %s fhir-api first" % (dist, dist))
    if BUNDLE.exists():
        shutil.rmtree(BUNDLE)
    shutil.copytree(dist / "bin", BUNDLE / "bin")
    if (dist / "lib").is_dir():
        shutil.copytree(dist / "lib", BUNDLE / "lib", symlinks=True)
    target = BUNDLE / "share" / "fhir-packages"
    target.mkdir(parents=True)
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
    copy_build(options.dist.resolve(), options.packages)
    try:
        for stale in (HERE / "build", HERE / "src" / "fhir_toolkit.egg-info"):
            shutil.rmtree(stale, ignore_errors=True)
        subprocess.run([sys.executable, "-m", "pip", "wheel", str(HERE), "--no-deps", "-w", str(out)], check=True)
        built = sorted(out.glob("fhir_toolkit-*-py3-none-any.whl"))[-1]
        subprocess.run([sys.executable, "-m", "wheel", "tags", "--platform-tag", platform_tag(), "--remove", str(built)], check=True)
    finally:
        shutil.rmtree(BUNDLE, ignore_errors=True)
        for stale in (HERE / "build", HERE / "src" / "fhir_toolkit.egg-info"):
            shutil.rmtree(stale, ignore_errors=True)
    wheel = sorted(out.glob("fhir_toolkit-*.whl"), key=lambda p: p.stat().st_mtime)[-1]
    print("%s  %.1f MB" % (wheel, wheel.stat().st_size / 1048576))


if __name__ == "__main__":
    main()
