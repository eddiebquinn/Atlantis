## 1. CI Config Foundation

- [x] 1.1 Create `.gitlab-ci.yml` at repo root with `stages: [scan, validate, test]`, `workflow:rules` matching MR events / default-branch push / web / schedule, and the meditek include (`project: foundry/meditek`, `ref: master`, `file: /templates/security.yml`). Verified via the GitLab CI Lint API: `valid: true`, zero errors. **Commit:** `5715cff`. Pipeline #3151 confirmed real jobs (8 visible), not zero-job ghost.
- [x] 1.2 Pipeline #3151 → #3163 traced through MR development; first green pipeline (#3154, no flake-check / pre-commit; just scan + nix eval) at commit `75ce3c2`. Final green pipeline (#3163) at `b6dcd81`.
- [x] 1.3 Cold-start baseline recorded in MR description: scan jobs 75–83s, nix jobs 222–275s (warm runner); cold first-time nixpkgs fetch ~10–20 min per runner-image freshness.

## 2. Nix Eval Test Stage

- [x] 2.1 `flake-check` job added: `image: nixos/nix:2.35.2`, `tags: [check]`, `stage: test`, `nix flake check --no-build --show-trace`. **Commit:** `5715cff`. First green run in pipeline #3154 (323s cold).
- [x] 2.2 `eval:8ug8ear`, `eval:spider`, `eval:blackhand` jobs added — same image/tags/stage, `nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`. **Commit:** `5715cff`. All three green in pipeline #3154 (382s, 397s, 374s cold).
- [x] 2.3 Negative test: introduced unknown option in spider config, pushed (commit `27c4d5a7`), pipeline #3162 failed exactly as expected on `eval:spider` + `flake-check` while the other two host evals passed. **Reverted** in commit `b6dcd81`. **Notable finding beyond D2's prediction:** flake-check ALSO caught the unknown option (more thorough than designed). Per-host eval's value is scoping the failure to a specific host.

## 3. Pre-Commit

- [x] 3.1 ~~One-time reformat commit (`chore: alejandra reformat`)~~ — **not needed**. CI confirmed the tree is already alejandra-canonical (pipeline #3161's `alejandra (nix-shell)` hook passed). Task was defensive; skipped per the spec's "if no drift, no commit" intent.
- [x] 3.2 `.pre-commit-config.yaml` created with alejandra (local hook, `nix-shell -p alejandra --run` to avoid rustup in CI) + pre-commit-hooks v5.0.0 hygiene hooks. **Commits:** `89988b6` (initial), `8a8456b`/`4d620a5`/`ffba308`/`6540691` (fixups during pipeline debugging).
- [x] 3.3 CI-side enforcement job (`pre-commit`): `image: nixos/nix:2.35.2`, `tags: [check]`, `stage: test`, `nix-shell -p pre-commit --run 'pre-commit run --all-files --show-diff-on-failure'`. **Commit:** `89988b6` + `6540691`. Green from pipeline #3161 onward.

## 4. Gate Verification & Docs

- [x] 4.1 MR description updated with the full pipeline table, commit list, hygiene findings, and negative-test outcome. The MR currently has `merge_status: can_be_merged`; final merge is the human step.
- [x] 4.2 Host coverage audit documented in MR description: `eval:8ug8ear`, `eval:spider`, `eval:blackhand` map 1:1 to `modules/flake/hosts.nix` `flake.nixosConfigurations` keys. Future-host rule noted: adding a host to the flake requires adding its eval job in the same MR.
- [ ] 4.3 After merge + a few pipelines of soak, archive the change via `openspec archive atlantis-ci-verification` and confirm `openspec/specs/ci-verification/spec.md` exists with the merged requirements. **Not yet done — runs after merge.**