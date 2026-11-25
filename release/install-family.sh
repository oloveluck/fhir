#!/usr/bin/env bash
# install-family.sh — install this repository's packages and the family's others at the commits
# release/family.lock names, in one `raco pkg install` (so they resolve one another).
#
#   release/install-family.sh         (run at the repository's root, with Racket installed)
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)

sources=()
for package in fhir fhir-spec fhir-tx fhir-validation fhir-server fhir-lsp fhir-mcp fhir-api; do
  sources+=("$root/$package")
done
while read -r repository commit; do
  case "$repository" in ''|'#'*) continue ;; esac
  sources+=("https://github.com/oloveluck/$repository.git#$commit")
done < "$root/release/family.lock"

raco pkg install --no-docs --batch --auto "${sources[@]}"
