## Context

Atlantis is a flake-parts + import-tree (dendritic-pattern) NixOS flake serving
three hosts, assembled in `modules/flake/hosts.nix` (`flake.nixosConfigurations`:
`8ug8ear`, `spider`, `blackhand`). It has never had CI. The homelab's shared CI
substrate is `foundry/meditek` (project 62): `templates/security.yml` provides
gitleaks current+history, trivy config scan, and hadolint (stage `scan`, tag
`check`); `templates/validate.yml` provides YAML/shell/Python syntax gates
(stage `validate`, tag `check`). `machines/ansible-playbooks` already includes
both via `include: project:` with `ref: master` — that repo's shape is the
proven pattern to copy. Runners: shared `check`-tagged runner
(`devstack-1-instance-runner-check`, concurrency 5) exists and serves these
templates today. The runner's registry mirror (`10.67.40.25:5000`) proxies
`nixos/nix` (tags through 2.35.2), `ghcr.io/gitleaks/gitleaks`,
`aquasec/trivy`, `hadolint/hadolint`.

## Goals / Non-Goals

**Goals:**
- Merge-blocking pipeline on every MR: scan → validate → test, with per-host
  nix eval in test.
- Zero changes to any NixOS module, flake input, or host config.
- Reuse meditek templates verbatim so atlantis inherits estate-wide scan
  improvements for free.
- Pre-commit mirrors in CI so hook-less contributors are still gated.

**Non-Goals:**
- Building full host closures in CI (`nix build` of toplevels) — too slow
  (40+ min/host), stays on the hosts per the 8ug8ear-first deployment order.
- Deploy/apply automation (no `nixos-rebuild` from CI, no runner SSH to hosts).
- Home-manager rendered-config byte-diff gating (the MR !36→!37 compositor
  failure mode) — separate follow-up change if wanted.
- VM smoke tests (QEMU boot tests of each host closure).

## Decisions

### D1: Include meditek security.yml only; hand-roll validate-stage jobs

**Decision**: include `templates/security.yml` (the "meditek scan sacred
template"), but do NOT include `templates/validate.yml`. Instead, the test
stage carries the nix jobs, and formatting enforcement rides pre-commit +
a CI-side pre-commit run.

**Why**: security.yml's jobs (gitleaks, trivy config, hadolint) are
content-agnostic — they scan whatever files exist and skip cleanly when
Dockerfiles/compose files are absent (hadolint's script exits 0 with "No
Dockerfiles found"). validate.yml's jobs are equally generic and would be
fine to include too, but its `pip install` + `apt-get` in `before_script`
adds cold-start weight for checks that a pre-commit-in-CI job already
covers, and atlantis has no shell/Python to speak of. One shared template
included verbatim keeps the "templates gain a job → atlantis inherits it"
property where it matters most (secret + IaC scanning) without paying for
validate jobs that duplicate pre-commit coverage.

**Alternative rejected**: include both templates (ansible-playbooks shape).
Cost: slower pipelines, redundant YAML checks vs pre-commit. Revisit if
atlantis grows shell scripts.

### D2: Per-host eval via `nix eval .#nixosConfigurations.<host>...drvPath`, not per-host `flake check`

**Decision**: the test stage has (a) one repo-wide `nix flake check --no-build`
job and (b) three per-host jobs evaluating
`nixosConfigurations.<host>.config.system.build.toplevel.drvPath`.

**Why**: `nix flake check` evaluates `checks` and derivations' `drvPath`s but
does NOT force each `nixosConfiguration`'s toplevel unless they're wired into
`checks` — flake-parts' `flake.checks` doesn't automatically include host
toplevels. So a broken host module (e.g. a renamed option only
`modules/hosts/blackhand.nix` references) can pass `flake check` while the
host itself is unevaluable. The explicit per-host `nix eval ...toplevel.drvPath`
job forces exactly that evaluation. Together: repo-wide structure (flake
check) + per-host system evaluation (eval jobs) = the full eval gate.

**Alternative rejected**: wiring each host's toplevel into `flake.checks` in
nix so a bare `flake check` covers hosts. Cleaner CI, but it edits the flake —
violates the "zero module/flake changes" goal of this change. Good follow-up
change; noted in tasks.

### D3: Nix jobs image and mirror

**Decision**: nix jobs run `image: nixos/nix:2.35.2` (latest tag available on
the LAN mirror), `tags: [check]`, with
`experimental-features = nix-command flakes` written to `/etc/nix/nix.conf` in
`before_script`, plus `GIT_DEPTH: "0"` not required (flake eval only needs the
checked-out tree).

**Why**: the official `nixos/nix` image is a minimal docker image with the nix
daemon-less single-user layout; enabling flakes via nix.conf in before_script
is the standard pattern. Pinning the tag keeps the mirror-proxied image
stable and gives Renovate-style visibility for bumps. The `check` runner has
concurrency 5 — three per-host jobs + flake-check + scan jobs fit without
queueing.

**Alternative rejected**: a dedicated `nix`-tagged runner. Adds infra (Eddie
must register it) for zero benefit at 4 jobs; the check runner's docker
executor can run the nixos/nix image fine. Revisit if nix jobs queue behind
trivy/hadolint pulls.

### D4: Pre-commit config: alejandra + hygiene hooks

**Decision**: `.pre-commit-config.yaml` with `alejandra` (nix formatter),
`check-merge-conflicts`, `end-of-file-fixer`, `trailing-whitespace`,
`check-yaml`, `check-added-large-files`. CI-side enforcement via a
`pre-commit` job running the same config in a nixos/nix image
(`nix-shell -p pre-commit --run 'pre-commit run --all-files'`) so the pipeline
fails on drift even for hook-less contributors.

**Why**: alejandra is the opinionated standard formatter; running the same
hook set in both places means one source of truth (the config file) with two
enforcement points. `nix-shell -p pre-commit` inside the nixos/nix image
avoids adding a second CI image.

**Alternative rejected**: `nixfmt`. Fewer judgements, more formatting churn
on first run (the one-time `alejandra --heuristic` reformat of the tree).
Churn is a one-time cost absorbed by the reformat commit; alejandra's
determinism wins long-term.

### D5: Stages and rules

**Decision**: `stages: [scan, validate, test]` — `scan` and `validate` come
from the included template(s) and MUST be listed (meditek-stages trap: a
missing stage yields zero-job pipelines with "chosen stage does not exist" on
the lint API). `workflow:rules` mirrors ansible-playbooks: MR events, default
branch pushes, web, schedule. Jobs run without `changes:` filters — atlantis
is small; full runs keep the gate honest and avoid path-filter drift.

**Why**: the meditek-stages-on-existing-CI trap is documented and cheap to
avoid; unconditional runs avoid "this MR didn't trigger the nix jobs because
it only touched README" surprises where a broken eval rides a green path
filter.

### D6: Substituter strategy for nix eval jobs

**Decision**: nix jobs set `NIX_CONFIG` env with `extra-substituters` pointing
at the host binary cache if one exists, else nothing; jobs rely on the
runner's LAN mirror for image pulls and upstream caches (cache.nixos.org) for
store paths.

**Why**: there is no host binary cache today (hosts build locally). Inventing
one is out of scope. First eval of nixpkgs closure is slow (~10-20 min);
subsequent runs on the same runner benefit from `/cache` volume only if the
nix store persists — it does NOT in a fresh container per job, so eval jobs
will re-download the closure each run. Accepted trade-off (see Risks), with
the CI-local store cache as the mitigation lever if it becomes painful.

**Mitigation lever (deferred)**: a named volume for `/nix/store` on the check
runner, or a `nix`-tagged runner with a persistent volume, or standing up
attic/cachevillle. Any of these is a follow-up change, not this one.

## Risks / Trade-offs

- [First pipeline is slow — nix eval pulls the whole nixpkgs closure] →
  Acceptable one-time-ish cost; subsequent evals on a warm runner still
  re-fetch unless D6's lever is pulled. If a full run exceeds ~30 min,
  split per-host jobs across runners or add the persistent `/nix` volume.
- [`nix flake check --no-build` passes while a host is unevaluable] → covered
  by the per-host eval jobs (D2); the two together close the gap.
- [Untracked-file blindness of flakes] → pipeline evaluates the pushed tree;
  an unstaged new module is invisible to both local and CI eval (documented
  in the spec as an accepted limitation). `git add` before push remains the
  author's discipline; the dendritic trap is recorded in nixos-config-management
  skill §0.5 trap B.
- [meditek template drift breaking atlantis pipelines] → templates are
  included at `ref: master`; a breaking template change reds every estate
  repo simultaneously, which is visible and fixable centrally. Pin to a tag
  if it ever bites.
- [gitleaks history scan cost on every push] → GIT_DEPTH 0 full-history scan
  on a small repo is seconds; if the repo grows, gate `gitleaks_history` to
  schedules via template override (job-level `rules` in atlantis's file can
  override included job rules without re-declaring the script).
- [Runner queueing — check runner concurrency 5] → worst case today: 4 nix
  jobs + 4 scan jobs + pre-commit = 9 jobs, 5 concurrent; queueing delays
  minutes, not hours. Bump concurrency or add a runner if it bothers.

## Migration Plan

1. Land `.gitlab-ci.yml` + `.pre-commit-config.yaml` on a branch; first
   pipeline runs cold (slow nix eval) — expect it, don't panic.
2. If the lint API reports stage errors (zero-job pipelines): verify
   `stages:` includes `scan`/`validate`/`test` per the meditek trap.
3. Rollout is inverse-rolling: there is no production cutover. The first MR
   that benefits is the next one; no existing behavior changes.
4. Rollback: delete `.gitlab-ci.yml` (and optionally the pre-commit config).
   Nothing else references them.

## Open Questions

- Should the one-time alejandra reformat land as its own commit (chore:
  format) before the pre-commit hook turns on, to keep the reformat diff out
  of feature diffs? → yes, task 3.x handles it; flagged here because the
  reformat touches every `.nix` file in the repo (~large mechanical diff).
