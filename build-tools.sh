#!/usr/bin/env bash
# build-tools.sh — the family's command-line tools as standalone executables that run without Racket.
#
#   ./build-tools.sh [out-dir]          (default: dist)
#
# Run it once on a machine with Racket and the family's packages installed (README: "Install from
# source"); copy out-dir anywhere — it needs no Racket. Each tool whose package is installed is
# built from the module its `raco` command runs, with `raco exe`, and the tools are gathered with
# `raco distribute` into out-dir/bin (the executables) and out-dir/lib (the runtime they share).
#
# A tool loads some modules by name at run time — the FHIR version towers, the languages' editor
# support, optional features — so those are embedded explicitly (++lib, the third column below).
# The HL7 packages from fhir-spec go to out-dir/share/fhir-packages, where the tools look for them
# beside the executable (fhir/spec-package; FHIR_PACKAGE_PATH names more directories).
#
# Not in the executables: the conformance runners (--tck, tck) and the generators (regen, check,
# fetch), which read the source checkout, and anything that loads a .rkt file of yours (a
# `#lang sql-on-fhir` view, a `#lang fhir/capability` app) — those are for Racket.
set -euo pipefail

out=${1:-dist}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

towers="fhir/r4/schemas fhir/r5/schemas"
languages="fsh/support cql/support fml/support vcl/support fhirpath/support"
# what fhir-mcp's workspace loads by name: each language's workspace support
workspaces="fsh/workspace fsh/ig-workspace cql/workspace fml/workspace vcl/workspace fhirpath/workspace sql-on-fhir/workspace"
# what the CQL engine loads by name: the ModelInfo reader, for models given as ModelInfo documents
cqlmodels="cql/model/modelinfo-xml"
operations="fhir/sd/operations fhir/conformance/operations fhir/terminology/operations fml/operations cql/measure sql-on-fhir/operations fhir/mcp/crmi"
store="fhir/store/fhir-sqlite fhir/store/ig-server fhir/store/load fhir/store/fhir-engine fhir/store/measure fhir/http/server"

# tool | the module its raco command runs | the modules it loads by name
tools=(
  "fhirpath|fhirpath/cli|$towers"
  "cql|cql/cli|$cqlmodels"
  "vcl|vcl/cli|"
  "fml|fml/cli|$towers fhir/conformance/validate"
  "fsh|fsh/cli|$towers fml/project $store"
  "sql-on-fhir|sql-on-fhir/cli|"
  "fhir|fhir/cli|fhir/r6/types $towers fhir/sd/sd-index fhir/sd/snapshot"
  "fhir-validate|fhir/validate-cli|$towers"
  "fhir-tx|fhir/tx-cli|$towers fhir/capability/operations fhir/terminology/operations fhir/http/server"
  "fhir-server|fhir/server-cli|$towers fhir/r6/schemas $store"
  "fhir-lsp|fhir/lsp-cli|$towers $languages fml/project"
  "fhir-mcp|fhir/mcp-cli|$towers $workspaces $cqlmodels fml/project fml/print $operations"
)

# installed? : module-path -> status   the module's source file exists in an installed collection
installed() {
  racket -l racket/base -e "(exit (if (file-exists? (resolved-module-path-name (module-path-index-resolve (module-path-index-join '$1 #f)))) 0 1))" 2>/dev/null
}

built=()
for entry in "${tools[@]}"; do
  IFS='|' read -r name module libs <<< "$entry"
  if ! installed "$module"; then echo "skip $name ($module is not installed)"; continue; fi
  embed=()
  for lib in $libs; do installed "$lib" && embed+=(++lib "$lib"); done
  printf '#lang racket/base\n(require (submod %s main))\n' "$module" > "$work/$name.rkt"
  echo "build $name"
  raco exe "${embed[@]}" -o "$work/$name" "$work/$name.rkt"
  built+=("$work/$name")
done

rm -rf "$out"
raco distribute "$out" "${built[@]}"

core=$(racket -l racket/base -e '(display (collection-file-path "hl7.fhir.r5.core.tgz" "fhir-spec" #:fail (lambda (_) "")))')
if [ -n "$core" ] && [ -f "$core" ]; then
  mkdir -p "$out/share/fhir-packages"
  cp "$(dirname "$core")"/*.tgz "$out/share/fhir-packages/"
  echo "packages: $(ls "$out/share/fhir-packages" | wc -l) from fhir-spec into $out/share/fhir-packages"
else
  echo "packages: fhir-spec is not installed; set FHIR_PACKAGE_PATH to a directory of FHIR packages (.tgz) when running the tools"
fi
echo "done: $out/bin has ${#built[@]} tools"
