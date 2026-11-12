# Design: the FHIR store as the codebase

Status: proposal (2026-11-12). Nothing here is built unless a section says "exists".

## The idea

A workspace's SQLite store (`fhir.db`, resources as JSONB) is the codebase: data AND definitions
(profiles, value sets, code systems, libraries, maps, views, operation definitions). The languages
(FSH, CQL, FML, VCL, ViewDefinition JSON) are the scratch form an agent reads and writes. Nothing
enters the store unless it checks. Borrowed from Unison: the codebase is a database that is never
broken; text is a view of it. Kept from FHIR: identity is the canonical url and version, history is
resource versions, a change is a transaction with a Provenance.

Today (exists): data is staged, validated, committed with a Provenance and an AuditEvent; every
version is kept; SQL reads the store. Definitions stay in files — `stage` leaves conformance
resources out — and are registered from the files each time the workspace loads.

## What lives where

| Place | Holds | Role |
|---|---|---|
| `fhir.db` | every resource, every version, the trail | the codebase and its version control |
| scratch files (`*.fsh`, `*.cql`, `*.map`, `*.vcl`, `*.view.json`) | what is being edited | working copy; may be deleted |
| `export/` (text, in git) | each current definition as text, one file per resource | readable diffs, review, CI, rebuild |
| git | the export, workspace.yaml — never `fhir.db` | mirror, not the source of truth |

`init` ignores `fhir.db`, `fhir.db-wal`, `fhir.db-shm` in git (today it ignores only the last two,
so `git add .` takes a binary that may lack the writes still in the WAL).

## The loop

1. **edit** — one definition out of the store as text in its language (FSH decompiler, VCL
   decompiler, StructureMap reader: exist; CQL: the text kept in `Library.content`, exists). The
   source text of the last commit when it still compiles to the stored resource (comments, RuleSets
   and aliases kept — the Provenance already contains it); regenerated text otherwise.
2. **stage** — compile, check, and answer the impact (below). `keep: false` checks only (exists for
   data).
3. **commit** — one transaction: the definitions, the data, a Provenance (agent, reason, source,
   the rule versions the data was held to), an AuditEvent; then the export is rewritten for what
   changed.
4. **resolve** — the store first, then the scratch files, then the packages. A workspace of
   `fhir.db` alone works.

## Impact: what a change touches

An index of canonical references between stored resources (`from`, `to`, `how`: Parent, binding,
include, valueset, uses, profile-of-data) kept with the other indexes, so "what depends on X" is a
query. A staged definition answers:

- dependents re-checked (libraries re-translated, maps re-checked, views re-typed), each problem at
  its line in that dependent's text;
- stored data that no longer conforms: how many, which, by which rule;
- saved results now out of date (a result's fingerprint: the versions of every definition it used
  and the store's latest write — the second half exists).

The author then versions the rule (old data stays valid under the old version) or migrates the data
(a correction or an FML map, staged and committed like any change).

## FHIR as the version control

| Git | FHIR, here | State |
|---|---|---|
| object | a resource version (`Type/id/_history/n`) | exists |
| commit | a transaction + its Provenance (targets, agent, reason, source) | exists for data |
| log, blame | `_history`; Provenance per version; changed paths per version — to the element | exists |
| diff | changed paths `old → new`; JSON Patch | exists |
| revert | a new version restoring the old, with a reason | exists (warned when unintended) |
| pull request | a stage: validated, diffed, refusable; approval = a second Provenance agent (author / verifier) | stage exists; roles to build |
| tag, release | `canonical|version`, frozen once anything is held to it; a package (`--pack`) of a set of versions | pack exists; freezing to build |
| branch | a draft version beside the active one (versions coexist; dependents pin `|version`); or a forked store file | to build |
| merge | per resource, three-way from the common version in history; lineage in `Provenance.entity` (revision, derivation) | to build |
| push, pull | pull = the remote's `_history?_since`; push = a transaction of conditional updates (`If-Match`: a conflict is one resource, not a file) | to build |
| signed commit | `Provenance.signature` | to build |
| — | AuditEvent of reads; validation as the commit's gate; SQL over the whole history | exists |

What git keeps: the toolkit's own Racket code, review tooling and CI over the text export.

## Decisions

1. **Kept source or regenerated text** — both, as in "edit" above. One rendering (regenerated) is
   what an agent sees when the store was written another way (a server, a sync).
2. **Operation handlers** are Racket and cannot be stored. An operation whose body is a CQL
   expression or an FML map (OperationDefinition + Library/StructureMap) is wholly in the store;
   Racket handlers remain for what the languages cannot say.
3. **A version is frozen once used** — a commit that held data to `profile|1.0`, or a result
   computed with `library|1.0`, makes 1.0 immutable; a change is 1.1. A content hash detects
   "changed without a new version"; it is not the identity.
4. **Requirements before running** — a library's data requirements (types, codes, value sets),
   derived from its CQL, compared with the data source's CapabilityStatement, so a source that
   cannot answer is said before the run, not as an empty answer.
5. **The language is the permission** — CQL, FHIRPath, VCL and views cannot write; FML only
   transforms; `commit`, a remote `apply` and handlers have effects. An agent's allowed verbs are
   its capabilities.

## Order

1. Definitions through stage and commit; resolve from the store; `edit`; git ignores `fhir.db`.
2. The text export on commit, and rebuilding a store from it.
3. The reference index, the impact answer, results out of date.
4. Frozen versions; author/verifier roles on a commit.
5. Sync: pull by history, push by conditional transaction; per-resource merge with lineage.
6. Operations written in CQL or FML; requirements against capabilities.

## Open questions

- Merge of two edits to one resource: by JSON path is mechanical; whether a merged profile still
  means what either author meant is for the check and a person.
- Branch-wide what-if (a query over the store plus a stage) — cheap for data, needs the resolver to
  see the stage's definitions first.
- How much of the trail a sync carries (all Provenance, or from a point).
