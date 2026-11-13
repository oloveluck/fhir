#!/usr/bin/env bash
# tools-smoke-test.sh — the standalone tools, run as someone without Racket runs them.
#
#   ./tools-smoke-test.sh [dist-dir]     (default: dist, as ./build-tools.sh writes it)
#
# Each of the twelve executables is asked for one real piece of work, with a PATH that holds only
# the tools themselves (so no racket and no raco), from a scratch folder outside the source checkout. A line per check: ok, or
# FAIL with what the tool said. Exit 1 when any failed.
set -uo pipefail

dist=$(cd "${1:-dist}" && pwd)
bin="$dist/bin"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"
failed=0

# run : name expected-regexp command…   the command's output (both streams) must match
run() {
  local name=$1 want=$2; shift 2
  local out
  out=$(env -i PATH="$bin" HOME="$work/home" "$@" 2>&1)
  if grep -Eq -- "$want" <<< "$out"; then echo "ok    $name"
  else echo "FAIL  $name"; echo "      wanted: $want"; sed 's/^/      | /' <<< "$out" | head -12; failed=$((failed + 1)); fi
}
mkdir -p home data

# the tools run with a PATH that holds nothing but themselves: no racket, no raco, whatever the
# machine has installed
if env -i PATH="$bin" /bin/sh -c 'command -v racket || command -v raco' > /dev/null; then
  echo "FAIL  $bin itself holds racket or raco: the tools would not be shown to run without it"; exit 1
fi

cat > data/ann.json <<'EOF'
{"resourceType":"Patient","id":"ann","gender":"female","birthDate":"1980-02-01","name":[{"family":"Lee","given":["Ann"]}]}
EOF
cat > bad.json <<'EOF'
{"resourceType":"Patient","id":"bea","gender":"femme"}
EOF
mkdir -p proj
cat > proj/bp.fsh <<'EOF'
Profile: BloodPressure
Parent: Observation
Id: blood-pressure
* subject 1..1
* efective[x] 1..1
EOF
cat > t.map <<'EOF'
/// url = "http://example.org/StructureMap/m"
/// name = "M"
uses "http://hl7.org/fhir/StructureDefinition/Patient" alias Patient as source
uses "http://hl7.org/fhir/StructureDefinition/Patient" alias Patient as target
group g(source s : Patient, target t : Patient) { s.gender as g -> t.gender = g; }
EOF
cat > t.cql <<'EOF'
library T version '1.0'
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'
context Patient
define "Female": Patient.gender = 'female'
EOF
cat > patients.view.json <<'EOF'
{"resourceType":"ViewDefinition","name":"patients","status":"active","resource":"Patient",
 "select":[{"column":[{"name":"id","path":"id"},{"name":"family","path":"name.family.first()"}]}]}
EOF

run "fhirpath: a path over a resource"       '^Ann$'                      fhirpath 'name.given' data/ann.json
run "cql: a define over a patient"           'Female.*(true|#t)'          cql t.cql --data data/ann.json
run "vcl: an expression to its ValueSet"     '"system": ?"http://loinc.org"' vcl '(http://loinc.org)(4548-4)'
run "fml: a map transforms a resource"       '"gender": ?"female"'        fml t.map --transform data/ann.json
run "fml: check a map"                       'no findings|0 findings'     fml check t.map
run "fsh: check a project"                   'efective. is not an element of Observation' fsh check proj
run "sql-on-fhir: a view over a folder"      'ann,Lee'                    sql-on-fhir run patients.view.json data --format csv
run "fhir: a guide"                          '^# FHIR for agents'         fhir guide fhir
run "fhir: a language's guide"               'Clinical Quality Language'  fhir guide cql
run "fhir-validate: a valid resource"        'All OK'                     fhir-validate data/ann.json
run "fhir-validate: an invalid one"          'femme'                      fhir-validate bad.json
run "fhir-validate: a guide in context"      'All OK|warning|error'       fhir-validate data/ann.json --package hl7.fhir.us.core
run "fhir-tx: expand a value set"            'female'                     fhir-tx expand http://hl7.org/fhir/ValueSet/administrative-gender
run "fhir-server: load, validated"           'loaded 1 resources'         fhir-server load a.db data --validate
run "fhir-server: read the store with SQL"   'ann'                        fhir-server sql a.db "SELECT id FROM Patient"
run "fhir-server: a guide's gaps"            'no unmet requirement'       fhir-server serve-ig hl7.fhir.us.core --gaps
run "fhir-lsp: the languages"                'fsh'                        fhir-lsp languages
run "fhir-lsp: check an FSH file"            'efective. is not an element of Observation' fhir-lsp check proj/bp.fsh
run "fhir-lsp: check a map"                  '^$|no problems|ok'          fhir-lsp check t.map
run "fhir-mcp: a workspace"                  'workspace.yaml'             fhir-mcp init ws
run "fhir-mcp: the tools"                    'stage'                      fhir-mcp tools
run "fhir-mcp: a call"                       'fhirVersion|problems|files' fhir-mcp call check --workspace ws

if [ "$failed" -eq 0 ]; then echo "all ok: the tools in $bin run without Racket"
else echo "$failed check(s) failed"; exit 1; fi
