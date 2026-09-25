## Why

Atlantis has no CI at all — no `.gitlab-ci.yml`, no linters, no eval gate. Every MR
merged so far (the 26.05 channel bump, the dendritic-pattern conversion, the
compositor rewrite) relied on a human running `nixos-rebuild build --flake .#<host>`
on real hardware before merge, or on nothing at all. The recurring failure modes
are known and mechanical: `flake.modules` aggregation breaks, `import-tree` missing
untracked files, home-manager/nixpkgs version drift, Lua-emitter output the Hyprland
parser rejects — all eval-time catchable, none currently gated. Meanwhile the wider
homelab already has a proven, shared CI substrate (foundry/meditek templates)
that atlantis doesn't participate in.

## What Changes

- Add a `.gitlab-ci.yml` to the repo root (first CI config atlantis has ever had).
- Include the foundry/meditek `templates/security.yml` scan template, giving the
  repo gitleaks (current + history), trivy config scan, and hadolint jobs on the
  shared `check` runner.
- Add a **test stage** with per-host nix eval jobs: one `nix flake check` job
  (repo-wide, no-build) plus one `nix eval .#nixosConfigurations.<host>...drvPath`
  job per host (`8ug8ear`, `spider`, `blackhand`), so every host's full system
  derivations actually evaluate — catching module wiring breakage that a
  repo-wide check can miss.
- Add a `.pre-commit-config.yaml` (nix formatter `alejandra`, plus the standard
  whitespace/YAML/merge-conflict hygiene hooks) so formatting drift is caught at
  commit time rather than diff-review time.

## Capabilities

### New Capabilities
- `ci-verification`: The repository's GitLab CI pipeline — which jobs run, what
  each gate proves, and the runner/tags contract they rely on.

### Modified Capabilities
<!-- No existing capability's requirements change: compositor-config, module-ownership,
     and system-channel are all about the NixOS configs themselves, not the pipeline
     that verifies them. -->

## Impact

- **New files**: `.gitlab-ci.yml`, `.pre-commit-config.yaml`. No existing tracked
  files change — no NixOS module, no flake input, no host config is touched.
- **Runner dependency**: jobs tagged `check` route to the existing
  `devstack-1-instance-runner-check` runner; the nix eval jobs need a runner able
  to pull and execute the `nixos/nix` image (pinned at a mirror-available tag).
- **First-pipeline risk**: the first push after this lands runs every job cold
  (nix eval fetches the full nixpkgs closure through the runner's registry
  mirror). Expected slow, one-time.
- **Host coverage source of truth**: the host list for the per-host jobs is
  `modules/flake/hosts.nix` (`flake.nixosConfigurations`). Adding a host means
  adding a CI job; the spec records this as an explicit requirement so a future
  host doesn't silently lose CI coverage.
