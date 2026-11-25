#!/usr/bin/env bash
# build-sqlite.sh — a SQLite of the toolkit's own, put where Racket looks before the system's.
#
#   release/build-sqlite.sh                      fetch the source release/sqlite.lock names, build, install
#   release/build-sqlite.sh --source <dir>       build the sqlite3.c in <dir> instead (nothing fetched)
#
# Why: a FHIR store keeps resources as JSONB, which SQLite has had since 3.45. Racket's db library
# uses the SQLite it finds — on Linux the system's, and Ubuntu 22.04's is 3.37 — so a standalone
# build would work or not by the machine it lands on. With a libsqlite3 in Racket's own library
# directory (the user's: `find-user-lib-dir`), Racket loads that one, and `raco distribute` copies
# it into the standalone build beside the executables: the wheel carries its SQLite.
#
# The source is SQLite's amalgamation (one C file, public domain) from sqlite.org, held to the
# SHA-256 in release/sqlite.lock. It needs a C compiler (cc; gcc on Windows), curl and Python.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
python=$(command -v python3 || command -v python)

source_dir=""
if [ "${1:-}" = "--source" ]; then source_dir=${2:?--source takes a directory}; fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

expected=""
if [ -z "$source_dir" ]; then
  read -r version year sha256 < <(grep -v '^#' "$root/release/sqlite.lock" | tr -d '\r' | head -n 1)
  url="https://www.sqlite.org/$year/sqlite-amalgamation-$version.zip"
  echo "fetching $url"
  curl -fsSL --retry 3 -o "$work/sqlite.zip" "$url"
  found=$("$python" -c 'import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],"rb").read()).hexdigest())' "$work/sqlite.zip")
  if [ "$sha256" = "-" ]; then
    echo "release/sqlite.lock pins no hash. What was fetched has SHA-256 $found: write it there."
  elif [ "$sha256" != "$found" ]; then
    echo "the file fetched has SHA-256 $found; release/sqlite.lock says $sha256" >&2
    exit 1
  fi
  "$python" -c 'import sys,zipfile; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])' "$work/sqlite.zip" "$work"
  source_dir="$work/sqlite-amalgamation-$version"
  # 3540100 is 3.54.1: one digit, then two digits a part
  expected="$((10#${version:0:1})).$((10#${version:1:2})).$((10#${version:3:2}))"
fi
[ -f "$source_dir/sqlite3.c" ] || { echo "no sqlite3.c in $source_dir" >&2; exit 1; }

# what a distribution's SQLite usually has beside the defaults (JSON is in every build since 3.38)
options="-O2 -DSQLITE_THREADSAFE=1 -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_MATH_FUNCTIONS -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_DBSTAT_VTAB"
# the file name is the one Racket's db library asks for on each system
case "$(uname -s)" in
  Linux)  library="libsqlite3.so.0"
          cc $options -fPIC -shared "$source_dir/sqlite3.c" -o "$work/$library" -lpthread -ldl -lm ;;
  Darwin) library="libsqlite3.0.dylib"
          cc $options -dynamiclib "$source_dir/sqlite3.c" -o "$work/$library" -install_name "$library" ;;
  MINGW*|MSYS*|CYGWIN*)
          library="sqlite3.dll"
          gcc $options -shared -static-libgcc "$source_dir/sqlite3.c" -o "$work/$library" ;;
  *) echo "no build of SQLite for $(uname -s)" >&2; exit 1 ;;
esac

target=$(racket -l racket/base -l setup/dirs -e '(display (path->string (find-user-lib-dir)))')
if command -v cygpath >/dev/null 2>&1; then target=$(cygpath -u "$target"); fi
mkdir -p "$target"
cp "$work/$library" "$target/$library"

loaded=$(racket -l racket/base -l db -e '(display (query-value (sqlite3-connect #:database (quote memory)) "SELECT sqlite_version()"))')
echo "installed $target/$library; Racket now loads SQLite $loaded"
if [ -n "$expected" ] && [ "$loaded" != "$expected" ]; then
  echo "expected SQLite $expected: Racket is loading another library" >&2
  exit 1
fi
