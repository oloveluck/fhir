#!/usr/bin/env bash
# lock-family.sh — write release/family.lock: the commit of each of the family's other
# repositories that a release of this one is built from.
#
#   release/lock-family.sh            (each repository's main, as GitHub has it now)
#
# This repository's packages are built together with six others (the languages). The docs
# workflow installs those from their main branches, which is right for a build that should fail
# when the tip breaks; a release — the wheel clients/python ships — has to say what it is made
# of. Run this before tagging a release, read the diff, commit it with the tag.
# release/install-family.sh installs what the file names.
set -euo pipefail
cd "$(dirname "$0")"

repositories=(fhirpath vcl cql fml fsh sql-on-fhir)
{
  echo "# The commits of the family's other repositories a release is built from."
  echo "# Written by release/lock-family.sh; read by release/install-family.sh."
  for r in "${repositories[@]}"; do
    sha=$(git ls-remote "https://github.com/oloveluck/$r.git" refs/heads/main | cut -f1)
    if ! [[ $sha =~ ^[0-9a-f]{40}$ ]]; then echo "no main branch found for $r" >&2; exit 1; fi
    echo "$r $sha"
  done
} > family.lock.new
mv family.lock.new family.lock
cat family.lock
