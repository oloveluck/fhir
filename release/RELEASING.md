# Releasing

What a release of the Python package is made of, and the steps. Nothing here has published
anything yet: the wheels have been built and tested by the `wheels` workflow, and the last
step (PyPI) is yours.

## What is in a wheel

- the toolkit's program, `fhir-api`, built with `./build-tools.sh <dir> fhir-api` from this
  repository and the six language repositories at the commits `release/family.lock` names;
- a SQLite of its own (`release/build-sqlite.sh`, the version and hash in
  `release/sqlite.lock`): the store needs SQLite 3.45 or newer, and neither Ubuntu 22.04's nor
  the one Racket's macOS distribution carries is;
- the FHIR R4 and R5 core packages;
- the Python client (`clients/python`).

One wheel per platform: Linux (built on Ubuntu 22.04, so it installs there and on anything
newer), macOS on Apple silicon, macOS on Intel. Windows is built as a trial that does not fail
the run.

## Steps

1. **Pin the family.** `release/lock-family.sh` writes `release/family.lock` from each language
   repository's `main`. Read the diff and commit it.
2. **Set the version** in `clients/python/pyproject.toml` and
   `clients/python/src/fhir_toolkit/__init__.py`.
3. **Build and test.** Push to `main`: the `wheels` workflow runs whenever the release
   machinery changes (this folder, `build-tools.sh`, the wheel's builder), and can be started
   by hand (Actions, `wheels`, "Run workflow"). Each wheel is installed into a clean environment
   and the client's tests are run against it with nothing else on the `PATH`. The wheels are
   the run's artifacts.
4. **Tag.** `git tag v0.1.0 && git push origin v0.1.0` builds the same wheels for the tag.
5. **Publish** (once, to set up):
   - on pypi.org, add a *trusted publisher* for the project `fhir-toolkit`: owner `oloveluck`,
     repository `fhir`, workflow `wheels.yml`, environment `pypi`;
   - in this repository's settings, add an environment named `pypi`, and a repository
     *variable* `PUBLISH_TO_PYPI` with the value `true`.

   From then on a `v*` tag publishes its wheels after they pass. Until then the `publish` job
   is skipped. By hand instead: download the run's artifacts and `twine upload *.whl`.

## To check a wheel yourself

```sh
release/build-sqlite.sh                                  # once: a SQLite where Racket finds it
./build-tools.sh dist fhir-api
python3 clients/python/build_wheel.py dist --out wheels
python3 clients/python/test_wheel.py wheels --with pandas
```

## Not done

- A wheel for Windows: see the latest `wheels` run for how far the trial job gets.
- An sdist. A wheel is the product: building from source needs Racket and seven repositories.
