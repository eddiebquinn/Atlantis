# ci-verification Specification

## Purpose
The CI pipeline contract for atlantis: a merge-blocking pipeline that
scans, validates, and evaluates the flake (including every host's
`nixosConfiguration`) on every merge request and on every push to the
default branch — so that eval-time failure modes (module wiring,
option renames, host-only breaks, formatter/hygiene drift, leaked
secrets) are gated at MR-time rather than caught on hardware at
`nixos-rebuild switch` time.

## Requirements

### Requirement: Pipeline Exists and Gates Merge Requests

The repository SHALL carry a `.gitlab-ci.yml` at the repo root that defines a
CI pipeline running on merge request events and on pushes to the default
branch. The pipeline SHALL fail when any of its jobs fail, and a merge request
with a failed pipeline SHALL NOT be merged while the pipeline is failing.

#### Scenario: Push to a feature branch opens an MR
- **WHEN** a branch is pushed and a merge request targets the default branch
- **THEN** a pipeline is created containing scan, validate, and test stage jobs
- **AND** the merge request is blocked from merging while any job is failing

#### Scenario: Repo with no CI file
- **WHEN** the repository has no `.gitlab-ci.yml`
- **THEN** this requirement is not met, regardless of any host-side manual checks

### Requirement: Security Scan Jobs From Shared Templates

The pipeline SHALL include the shared scan template from the meditek CI
template project (`foundry/meditek`, `templates/security.yml`) so the
repository receives the same gitleaks (current tree and full history), trivy
config, and hadolint coverage as the rest of the homelab estate. The included
jobs SHALL route to the shared `check`-tagged runner as defined by the
template, and the repository's stages list SHALL include every stage the
included templates use (`scan`, `validate`, `test`).

#### Scenario: A secret is committed to a branch
- **WHEN** a commit containing a candidate secret lands on any branch that
  triggers a pipeline
- **THEN** the gitleaks job fails the pipeline before merge

#### Scenario: Templates gain a new scan job
- **WHEN** the meditek `security.yml` template adds a new scan-stage job
- **THEN** the atlantis pipeline picks it up on the template's `ref` without a
  change to atlantis

### Requirement: Per-Host Nix Eval Gate

The pipeline's test stage SHALL include one nix evaluation job per host
defined in the repository's `flake.nixosConfigurations` (source of truth:
`modules/flake/hosts.nix`). Each job SHALL evaluate that host's full system
build (`nixosConfigurations.<host>.config.system.build.toplevel` derivation
path) and fail on any evaluation error, including module wiring breaks,
missing options, and input version drift. Jobs SHALL run without building the
derivations (`--no-build` semantics).

#### Scenario: A module rename breaks one host's evaluation
- **WHEN** a commit renames or removes an option that `modules/hosts/blackhand.nix`
  still references
- **THEN** the `blackhand` eval job fails while other hosts' jobs may pass
- **AND** the pipeline is red, blocking merge

#### Scenario: Adding a host to the flake
- **WHEN** `modules/flake/hosts.nix` gains a new host entry
- **THEN** the CI config gains a matching eval job so the new host is covered
  from its first pipeline run

### Requirement: Repo-Wide Flake Check

The pipeline's test stage SHALL include a `nix flake check --no-build` job
covering the whole repository evaluation: flake structure, checks output, and
every flake output attribute. It SHALL NOT be scoped to individual hosts — it
complements the per-host eval jobs, which exist precisely because flake check
alone does not force evaluation of each host's toplevel.

#### Scenario: Untracked module file invisible to import-tree
- **WHEN** a new `.nix` file exists in the working tree but is not staged in
  git, and a push is made without it
- **THEN** the flake check job on the pushed commit evaluates the tree as
  committed (the file is absent) and may pass
- **AND** the gap is caught later by the author, not the pipeline — this is an
  accepted limitation, documented in design.md

### Requirement: Pre-Commit Hooks Enforce Formatting and Hygiene

The repository SHALL carry a `.pre-commit-config.yaml` whose hooks enforce nix
formatting and file hygiene. The nix formatter hook SHALL fail on any `.nix`
file that is not canonically formatted, and hygiene hooks SHALL catch
trailing whitespace, missing final newline, merge-conflict markers, and
invalid YAML. Hooks SHALL be enforceable in CI as well as locally.

#### Scenario: A misformatted module is committed locally
- **WHEN** a developer commits a `.nix` file with non-canonical formatting
  with hooks installed
- **THEN** the commit is rejected until the file is reformatted or the hook
  is skipped explicitly

#### Scenario: CI-enforced formatting
- **WHEN** a merge request contains formatting drift
- **THEN** a CI-side check fails the pipeline even for authors who have not
  installed the hooks locally

### Requirement: Host List Coverage Is Auditable

The pipeline's per-host job set SHALL be verifiable against the flake's host
list without running a pipeline. Reading the CI config SHALL make it possible
to enumerate exactly which hosts receive eval coverage; any host present in
`flake.nixosConfigurations` but absent from the CI test stage SHALL be
considered a coverage gap.

#### Scenario: Auditing coverage
- **WHEN** a reviewer reads `.gitlab-ci.yml`
- **THEN** they can list the hosts with eval coverage by reading the job
  matrix, without consulting anything beyond the CI config and the flake
