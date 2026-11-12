# Design: the FHIR store as the codebase, managed as CRMI says

Status: proposal (2026-11-12). Nothing here is built unless a line says "exists".

Read for this note: HL7's Canonical Resource Management Infrastructure guide (CRMI), version 2.0.0
(STU 2, FHIR R4) — the package `hl7.fhir.uv.crmi` 2.0.0 from packages.fhir.org (sha1
`a42d193ec26c3fda29ab0381e964d1fb6309a61b`; 17 OperationDefinitions, 90 StructureDefinitions, 4
CapabilityStatements) and its pages Artifact Lifecycle, Artifact Manifest, Artifact Conventions,
Artifact Repository Service, Packaging, Testing, Publishing, Distribution, Artifact Signing. Where
this note says "CRMI", the name, the parameters and the rule are CRMI's; where it says "ours", CRMI
is silent and the choice is this toolkit's.

## The idea

A workspace's SQLite store (`fhir.db`, resources as JSONB) is the codebase: data AND definitions
(CRMI's "artifacts": profiles, value sets, code systems, libraries, maps, measures, operation
definitions; views with them). The languages (FSH, CQL, FML, VCL, ViewDefinition JSON) are the
scratch form an agent reads and writes. Nothing enters the store unless it checks. From Unison: the
codebase is a database that is never broken, and text is a view of it. From CRMI: how an artifact is
identified, versioned, drafted, reviewed, released, packaged and published. The store is a CRMI
**artifact repository** — Shareable, Publishable and Authoring — that also holds the data.

Today (exists): data is staged, validated, committed with a Provenance and an AuditEvent; every
resource version is kept; SQL reads the store. Definitions stay in files — `stage` leaves
conformance resources out — and are registered from the files each time the workspace loads.

Built so far (2026-11-12): the implementation guide as a workspace language; CRMI 2.0.0 vendored
(fhir-spec), its own examples held to its profiles; definitions through stage and commit — the
collection staged as one (`stage path=sushi-config.yaml`), each artifact with its guide's facts,
held to its Shareable profile and to the status rules (3.1), a released version kept as its own
instance when the next begins, the working copy first and the active version next when a canonical
is resolved (fhir-mcp `mcp/artifacts.rkt`, `tests/artifacts-test.rkt`); the store alone — with no
`sushi-config.yaml` the workspace's guide is the stored ImplementationGuide (its canonical, FHIR
version, packages, `global` profiles), and the guide is handed back as its file (the compiler's
inverse: on the published IPS, mCODE and CRMI guides the text compiles to the guide again);
**edit** — `describe ref=<canonical|Type/id> as=source` and `write path=<file> ref=…`: a library as
its CQL, the guide as `sushi-config.yaml` (the file its commit kept when that states this version),
the rest as FSH without what the guide gives, and the text compiles to what is stored. Not yet:
each artifact's own source file kept (one Provenance per source file — comments, RuleSets, VCL and
FML texts; a stored StructureMap is not written back as FML); a definition staged alone into a
store-only workspace is not added to the stored guide's list; manifests; the operations.

## What lives where

| Place | Holds | Role |
|---|---|---|
| `fhir.db` | every artifact version, the data, the trail | the artifact repository |
| scratch files (`*.fsh`, `*.cql`, `*.map`, `*.vcl`, `*.view.json`) | what is being edited | working copy; may be deleted |
| `export/` (text, in git) | each current artifact as text, one file per resource | readable diffs, review, CI, rebuild (ours) |
| git | the export and the configuration — never `fhir.db` | mirror, not the source of truth |

`init` ignores `fhir.db`, `fhir.db-wal`, `fhir.db-shm` in git (today only the last two, so
`git add .` takes a binary that may lack the writes still in the WAL).

## CRMI's terms, used as they are

- **Identity.** An artifact's `url` is its version-independent identifier; a reference is
  `url` or `url|version` (3.2). Its logical id is the server's. Each business version is a different
  resource instance; resource versioning (`_history`) is separate, kept for audit — both exist here.
- **Status.** `draft`, `active`, `retired`, and `experimental`. An active artifact SHALL NOT go
  back to draft; a retired one SHALL NOT go back to active or draft: a new version is required
  (3.1). Deprecated-but-active is `workflowStatusDescription` (value sets).
- **Version.** Required. `<major>.<minor>.<patch>[-<label>]`; labels are unordered
  (`-draft`, `-cibuild`, `-ballot`) (3.3). Major: breaks use. Minor: adds. Patch: corrects.
- **Version policy** (`artifact-versionPolicy`; algorithm in `artifact-versionAlgorithm`):
  `strict` — any change is a new version (not `id`, `meta`, `status`, `lastReviewDate`);
  `metadata` — metadata may change with a new `date`; `loose`; `package` — the artifact carries its
  package's version (3.4, 3.5). Default here: `package` inside a workspace, `strict` once released.
- **Capability categories**, each a profile per resource type: **Shareable** (url, version, title,
  status, experimental, description), **Publishable** (date, contact, useContext, approvalDate,
  lastReviewDate, effectivePeriod, author/editor/reviewer/endorser, relatedArtifact — as extensions
  where R4 lacks the element), **Computable** (the definition: CQL text, a value set's compose),
  **Executable** (the compiled form: ELM, a value set's expansion). The languages map onto the last
  two: the text an agent writes is the computable content, what the compiler emits the executable.
- **Collection and manifest.** A collection of artifacts is a **manifest library**
  (`CRMIManifestLibrary`: a Library of type `asset-collection`, no content): `composed-of` entries
  name its components, `depends-on` its dependencies (calculated, by `$data-requirements`), and
  `cqf-expansionParameters` points at contained **manifest parameters**
  (`CRMIManifestParameters`): `default-canonical-version`, `default-valueset-version`,
  `default-system-version` (`url|version` each; `check-`/`force-` variants), `activeOnly`,
  `includeDraft`. An ImplementationGuide carries the same extension (`CRMIImplementationGuide`).
- **Owned components** (`artifact-isOwned` on a `composed-of` entry): the component has no
  lifecycle of its own; its status and version SHALL be its parent's, and it is drafted, released,
  retired and removed with it. An artifact has at most one owner.
- **Package source** (`package-source` on `meta`: packageId and canonical base; `cqf-scope` to
  override): the package an artifact is authored in, which decides its manifest.

## The repository actions

CRMI names sixteen conceptual actions and says how each is done. The workspace verbs are ours; they
perform CRMI's interaction or operation, so a store-backed server exposes the same thing over HTTP.

| CRMI action | Done as (CRMI) | Workspace | State |
|---|---|---|---|
| Retrieve, Search | read; search by `url`, `version`, `identifier`, `name`, `title`, `status`, `description` (`:contains`, `:exact`), `_lastUpdated`; Publishable adds `date`, `effective`, `context…`, `topic`, and `composed-of`, `depends-on`, `derived-from`, `predecessor`, `successor` | `describe`, `query` | read and search exist; the artifact parameters to check |
| Submit, Revise | create / update of unreleased content; SHALL conform to the Shareable profile | `stage` + `commit` of a draft | to build (data: exists) |
| Withdraw | delete of an unreleased artifact and its children; answers their contents | `stage drop` of a draft's resources | to build |
| Draft | `$draft` (`version`): a draft version of an artifact and all its owned children; drops `effectivePeriod`, `approvalDate` and active-only extensions | `apply $draft` | to build |
| Clone | `$clone` (`url`, `version`): a copy under a new url, children too | `apply $clone` | to build |
| Diff | `$artifact-diff` (`source`, `target`, `compareComputable`, `compareExecutable`): FHIRPath Patch, dependencies resolved recursively | `describe … diff` | changed paths exist; Patch form to build |
| Review | `$review` (`reviewDate`, `artifactAssessment…`): sets `date`, `lastReviewDate`; may only add an ArtifactAssessment (R4: Basic, or `cqf-artifactComment`) | `apply $review` | to build |
| Approve | `$approve` (`approvalDate`, `artifactAssessment…`): sets `date`, `approvalDate`, same record | `apply $approve` | to build |
| Release | `$release` (`version`, `versionBehavior` default / check / force, `requireVersionSpecificReferences`, `requireActiveReferences`, `experimentalBehavior` error / warn / none, `releaseDate`, `releaseLabel`): sets dates, pins every direct and transitive reference into the manifest, releases owned children; one transaction | `apply $release` | to build |
| Publish | create/PUT of released content conforming to Publishable; or `$publish` of a `CRMIPublishableBundle` (transaction, ImplementationGuide first, every entry POST with `ifNoneExist` on url and version); or the NPM registry | `commit` to a remote | pack exists; `$publish` to build |
| Retire | update of an active artifact changing only `status` to retired and `date` | `apply` | to build |
| Remove | delete of released content and children; answers their contents | — (refused by default; ours) | to build |
| Package | `$package` (`url`, `version`, `manifest`, `include`/`exclude`, `packageOnly`, `capability`, `artifactVersion`…): a Bundle, the artifact (or an outcome manifest) first, then dependencies and test cases | `apply $package` | to build |
| Requirements | `$data-requirements` → a module-definition Library: `dataRequirement`s and `depends-on`; `$infer-manifest-parameters` turns it into manifest parameters | `apply`, and before every run | to build |
| (resolution) | `$resolve` (`canonical`, `manifest` or `manifestParameters`, `sourceReference`, `duplicateBehavior`) | every resolver | to build |

Rules that come with them: an operation that touches several artifacts SHOULD be one transaction
answering a transaction-response Bundle; children SHALL be updated with their parent.

## Resolving a reference (CRMI, "Determining Latest Version")

For an unversioned canonical, in order: (1) the manifest given to the operation — its
`default-…-version` entry matching the url; (2) the `package-source` of the resource the reference
is in — that package's ImplementationGuide and its manifest parameters; (3) the package dependency
tree from the canonical's base; (4) the artifact's version algorithm for "latest"; (5) the IG
guidance's most-recent rule. A manifest is chosen by the operation's `manifest` parameter, by an
`X-Manifest` request header (servers MAY), or from the artifact's package source.

Here: every verb that evaluates (`check`, `run`, `query`, `explain`, `stage`) takes `manifest`;
without one it is the workspace's ImplementationGuide. The server honours `X-Manifest`.

## A workspace is a content IG

`workspace.yaml` becomes a stored ImplementationGuide (Shareable, `CRMIImplementationGuide`):
`packageId`, the canonical base, `fhirVersion`, `dependsOn` (the packages), `global` (the profile
every resource of a type is held to — today's `profiles:`), `definition.resource`, and
`cqf-expansionParameters`. Its artifacts carry its `package-source` and, under the `package` policy,
its version. CRMI's conventions hold (url `<base>/<Type>/<id>`, PascalCase `name` equal to the
canonical's tail for libraries, references inside the package version-consistent).

## The IG is a language, written as sushi-config.yaml

The ImplementationGuide composes everything else, so it is a workspace language like the others —
and its syntax already exists: `sushi-config.yaml`, which SUSHI turns into the ImplementationGuide
of an FSH project. No new syntax; an existing IG repository is a workspace as it is.

- **Compiles to** the ImplementationGuide (id, url, version, name, title, status, publisher,
  packageId, license, fhirVersion, `dependsOn` from `dependencies`, `global`, `definition.resource`
  from what the workspace's other languages define, `definition.parameter` from `parameters`), and,
  with the pins below, its manifest parameters.
- **Checked like the others**, each problem at its line: a dependency no package at hand provides,
  a `global` profile nothing defines, an id, canonical or version missing.
- **Round trips**: the stored ImplementationGuide is handed back as this YAML to edit.
- **With a `#lang` line** it is a Racket module that composes the project (to build).
- **What the workspace reads from it**: the canonical base, the FHIR version, the packages
  (`dependencies`) and the profiles every resource of a type is held to (`global`) — for every
  language, not FSH alone. `workspace.yaml` keeps what is not the IG's: where the data is, the
  audit level, CQL parameters, remote writes, models. A fact stated in both is the IG's, and the
  difference is a warning.
- **Pins** (to build): version pins as CRMI's manifest parameters — `default-canonical-version`,
  `default-valueset-version`, `default-system-version` — under `parameters`-like keys, emitted as
  `cqf-expansionParameters` on the ImplementationGuide.

## The loop for one agent

1. **edit** (ours) — one artifact out of the store as text: its kept source when that still
   compiles to the stored resource (the Provenance has it; a Library has its CQL as content), the
   decompiled text otherwise (FSH, VCL, FML readers exist).
2. **stage** — compile; hold the resource to its Shareable profile; answer the impact (below). This
   is CRMI's Submit or Revise, on a draft only: an active artifact is refused with "draft a new
   version" (3.1).
3. **commit** — one transaction: the artifacts, a Provenance (agent, reason, source), an
   AuditEvent; the export rewritten.
4. **review / approve** — `$review`, `$approve`: the record CRMI prescribes, by another agent or a
   person.
5. **release** — `$release`: versions pinned, dates set, status active.
6. **publish** — `$publish` to another repository, or the package to a registry.

## Parallel development

- **A line of work is a draft of the collection.** `$draft` on the workspace's manifest (or
  ImplementationGuide) with a version carrying a label of its own — `1.1.0-draft`, or
  `1.1.0-lipids` when several lines are open (labels are unordered, so they name, not rank) —
  creates draft instances of it and of every owned component, in one transaction. The draft
  manifest is the branch: evaluating with `manifest=<it>` sees its versions, everyone else sees the
  active ones. Copies are small JSON documents in one SQLite file.
- **An artifact with its own lifecycle** (a component that is not owned: a shared value set, a
  common library) is drafted alone and pinned by the manifests that want it.
- **Lineage** (ours, in CRMI's vocabulary): a draft names what it was drafted from as a
  `relatedArtifact` of type `predecessor`, a clone as `derived-from` — the types the Publishable
  repository searches by.
- **Seeing a line's change**: `$artifact-diff` between the active collection and the draft.
- **Joining two lines** (ours; CRMI has no merge): both drafts name the same predecessor, so each
  one's `$artifact-diff` from it is a FHIRPath Patch; patches touching different artifacts or
  different paths apply to a new draft; two touching one path are the conflict, shown as both
  values. The joined draft is checked like any other before it can be released.
- **Release is the gate**: `$release` with `requireActiveReferences` and
  `requireVersionSpecificReferences` true and `experimentalBehavior` error — no draft, retired or
  experimental dependency, every reference pinned. The version follows the impact: nothing that
  depended on the artifact changes meaning — minor or patch; otherwise major.
- **Between teams**: packages. A team's ImplementationGuide `dependsOn` another's at a version;
  nothing changes downstream until it moves the pin, and moving it answers the impact.
  `$get-package` and the registry serve releases; drafts travel by `$package` and `$publish`.

## Evidence (what makes a draft releasable)

- **Test cases** (CRMI Testing): a Library of type `test-case` naming the artifact and the
  operation under test (`cqf-testArtifact`), with `cqf-inputParameters`, `cqf-inputData`,
  `cqf-outputParameters`, `cqf-messages`, `cqf-outputData`. A CQL define's expected values, a
  view's expected rows, a map's expected result and a profile's valid and invalid examples are all
  this shape; `$package` carries them with the artifact.
- **Dependencies traced as CRMI lists them** (Distribution, "Dependency Tracing"), kept as an index
  so "what depends on X" is a query: any resource's `meta.profile`; a StructureDefinition's
  `baseDefinition`, differential `type.code`, `type.profile`, `type.targetProfile`,
  `binding.valueSet`, extension urls; a StructureMap's `structure.url`, `import`; a ValueSet's
  `compose.include/exclude` `valueSet` and `system`; a ConceptMap's sources and targets; a
  Library's `relatedArtifact.resource`, `dataRequirement.profile`, `codeFilter.valueSet`; a
  Measure's `library` and criteria. Base-specification resources are not listed.
- **Impact on what is stored** (ours): staging a draft answers the dependents re-checked in its
  manifest, the stored data that would no longer conform (how many, which, by which rule), and the
  saved results computed with an earlier version.
- **Requirements against capabilities** (ours, on CRMI's output): the module-definition Library
  from `$data-requirements` is compared with the data source's CapabilityStatement before a run, so
  a source that cannot answer is said, not answered as empty.

## FHIR as the version control

| Git | Here | State |
|---|---|---|
| object | a resource version (`Type/id/_history/n`); an artifact version (`url|version`) | exists |
| commit | a transaction + its Provenance (targets, agent, reason, source) | exists for data |
| log, blame | `_history`; Provenance per version; changed paths, to the element | exists |
| diff | `$artifact-diff` (FHIRPath Patch) | changed paths exist |
| branch | `$draft` of the collection; its manifest | to build |
| merge | patches from a common predecessor (ours) | to build |
| pull request | a draft with its `$review` and `$approve` records | to build |
| tag, release | `$release`; `releaseLabel`; the package | pack exists |
| push, pull | `$publish` of a publishable bundle; `$package`, `$get-package`, search by `_lastUpdated` | to build |
| signed commit | a Provenance with a JWS signature over the canonicalized resource (CRMI Artifact Signing) | to build |
| — | AuditEvent of reads; validation as the gate; SQL over all of it | exists |

Git keeps the toolkit's own Racket code, and review and CI over the text export.

## Decisions

1. **Kept source or regenerated text** — both, as in "edit". The Library keeps its CQL (Computable)
   and its ELM (Executable) as two contents, as CRMI's library profiles describe.
2. **Operation handlers** are Racket and cannot be stored. An operation whose body is a CQL
   expression or an FML map (OperationDefinition + Library or StructureMap) is wholly in the
   repository; Racket handlers remain for what the languages cannot say.
3. **Active is immutable** under the `strict` policy; a content hash detects a change made without a
   new version (and is what a signature covers). It is not the identity.
4. **The language is the permission** (ours) — CQL, FHIRPath, VCL and views cannot write; FML only
   transforms; Submit/Revise, `$release`, `$publish`, Retire, Remove and handlers have effects. An
   agent's allowed actions are a subset of CRMI's sixteen.
5. **Remove is refused by default**: data and results may have been held to the artifact; Retire
   keeps it resolvable.

## Order

0. The IG language: `sushi-config.yaml` as the seventh workspace language, the workspace's IG facts
   read from it; git ignores `fhir.db`.
1. Vendor `hl7.fhir.uv.crmi` 2.0.0 (CC0) in fhir-spec with its dependencies
   (`hl7.fhir.uv.extensions.r4` 5.3.0, `hl7.terminology.r4` 7.2.0); its OperationDefinitions drive
   input checking as every IG's do here. Artifacts through stage and commit, held to their
   Shareable profiles; the status rules (3.1); resolve from the store; `edit`.
2. The workspace as an ImplementationGuide; manifest library and parameters; `$resolve` with the
   resolution order; `manifest` on the evaluating verbs; `X-Manifest`.
3. The dependency index by CRMI's paths; `$data-requirements`; `$infer-manifest-parameters`; the
   impact answer; results out of date.
4. `$draft`, `$clone`, `$artifact-diff`, `$review`, `$approve`, `$release`; test-case Libraries run
   as the release's evidence.
5. `$package`, `$publish`, `$get-package`; the text export; the three artifact-repository
   CapabilityStatements served and held to (the gap report exists for any IG's statement).
6. Joining two drafts; signing; operations written in CQL or FML; requirements against capabilities.

## Open questions

- `$draft`'s `version` is documented as `MAJOR.MINOR.PATCH.REVISION`, the versioning rule as
  `<major>.<minor>.<patch>[-<label>]`; which form a parallel line's version takes needs a reading of
  the reference implementation, or a question to the work group.
- CRMI's capability statements name five resource types (ActivityDefinition, Library, Measure,
  PlanDefinition, Questionnaire) and say others "SHALL follow the same pattern"; its operations
  name twenty-five. ViewDefinition is in neither list — treated by the same pattern here.
- The R4 review record: Basic, or `cqf-artifactComment` on the artifact (which changes the artifact
  under a strict policy). Basic keeps the artifact untouched.
- Joining two drafts by path is mechanical; whether the joined profile means what either author
  meant is for the checks, the test cases and a reviewer.
