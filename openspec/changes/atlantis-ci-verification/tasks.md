## 1. CI Config Foundation

- [ ] 1.1 Create `.gitlab-ci.yml` at repo root with `stages: [scan, validate, test]`, `workflow:rules` matching MR events / default-branch push / web / schedule, and the meditek include (`project: foundry/meditek`, `ref: master`, `file: /templates/security.yml`). Verify via the GitLab CI Lint API (`POST /projects/38/ci/lint?include_merged_yaml=true`): `valid: true`, zero errors, and `scan`/`validate` stage jobs present in the merged YAML.
- [ ] 1.2 Push the branch and confirm the first real pipeline creates jobs (not zero-job ghost pipelines). If zero jobs: re-run the lint API, look for "chosen stage does not exist", fix `stages:` per the meditek-stages trap.
- [ ] 1.3 Confirm the inherited scan jobs (`gitleaks_current`, `gitleaks_history`, `trivy_config`, `hadolint`) ran and exited green (hadolint exits 0 with "No Dockerfiles found" — expected for atlantis). Record job names + durations in the MR description for the cold-start baseline.

## 2. Nix Eval Test Stage

- [ ] 2.1 Add the repo-wide flake check job (`flake-check`): `image: nixos/nix:2.35.2`, `tags: [check]`, `stage: test`, before_script writes `experimental-features = nix-command flakes` to `/etc/nix/nix.conf`, script runs `nix flake check --no-build --show-trace`. Verify: job log shows the flake evaluating and exiting 0 on master's tree.
- [ ] 2.2 Add per-host eval jobs (`eval:8ug8ear`, `eval:spider`, `eval:blackhand`): same image/tags/stage, script `nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath` (verify non-empty output = the derivation path string). First run is cold — expect nixpkgs closure download; record duration.
- [ ] 2.3 Negative test: on the branch, temporarily break one host (e.g. reference a nonexistent option in `modules/hosts/spider.nix`), push, confirm `eval:spider` fails while `flake-check` may pass — proving the per-host gate catches what repo-wide check misses. Revert the breakage in a follow-up commit on the same branch. Verify: pipeline red on the break commit, green after revert.

## 3. Pre-Commit

- [ ] 3.1 One-time reformat commit (`chore: alejandra reformat`): run `nix-shell -p alejandra --run 'alejandra .'` on a clean tree, commit the mechanical diff alone (no other changes in that commit). Verify: `git show --stat` shows only `.nix` files, and the pre-commit hook (once installed) passes on the reformatted tree.
- [ ] 3.2 Create `.pre-commit-config.yaml` with alejandra + `check-merge-conflicts`, `end-of-file-fixer`, `trailing-whitespace`, `check-yaml`, `check-added-large-files`. Verify locally: `nix-shell -p pre-commit --run 'pre-commit run --all-files'` exits 0 on the reformatted tree.
- [ ] 3.3 Add CI-side enforcement job (`pre-commit`): `image: nixos/nix:2.35.2`, `tags: [check]`, `stage: test`, script runs `nix-shell -p pre-commit alejandra --run 'pre-commit run --all-files'`. Verify: job green on the branch; then (optionally, same negative-test pattern as 2.3) confirm it fails when a formatting drift file is pushed.

## 4. Gate Verification & Docs

- [ ] 4.1 Open the MR (artifacts + implementation commits per the combined-MR pattern; list the artifact commit first in the description). Verify the MR shows the pipeline blocking merge while red and allowing merge when green (GitLab's merged-status widget honors the pipeline only if "Pipelines must succeed" is on — check Project Settings → Merge requests; if off, note it and enable).
- [ ] 4.2 Record the coverage audit in the MR description: the three per-host jobs map 1:1 to `modules/flake/hosts.nix` (`8ug8ear`, `spider`, `blackhand`). State the rule for future hosts: adding a host to the flake requires adding its eval job in the same MR (spec requirement).
- [ ] 4.3 After merge + soak (a few pipelines), archive the change via `openspec archive atlantis-ci-verification` and confirm `openspec/specs/ci-verification/spec.md` exists with the merged requirements.
