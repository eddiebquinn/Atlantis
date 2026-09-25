# Tasks: atlantis-session-locking

## 1. Module implementation

- [x] 1.1 `modules/lock.nix`: NixOS `workstation` aggregate —
  `programs.hyprlock.enable = true` (package + PAM service). home
  `eddie` aggregate — `services.hypridle` (idle 600s → lock; 630s →
  DPMS off; before_sleep → lock; after_sleep → DPMS on) and
  `xdg.configFile."hypr/hyprlock.conf"` lock UI (Tokyo-Night palette,
  session wallpaper background).
- [x] 1.2 `modules/hyprland.nix`: add `local lock = "pidof hyprlock ||
  hyprlock"`; SUPER+l → lock; focus-right → SUPER+CTRL+l.
- [x] 1.3 `modules/hosts/8ug8ear.nix`: logind lid policy — suspend on
  lid close (battery + AC), ignore when docked. Uses 26.05 option
  names (`services.logind.settings.Login.HandleLidSwitch*`) — the old
  `lidSwitch*` aliases emit rename warnings at eval.

## 2. Wiring & eval gates

- [x] 2.1 `modules/flake/parts.nix` imports (or equivalent) so the new
  module file is picked up by import-tree; `git add` the new file
  (flakes only see tracked files). — No wiring change needed:
  `import-tree ./modules` auto-imports `modules/lock.nix`; file staged.
- [x] 2.2 Local pre-push eval: `nix flake check --no-build
  --show-trace` exit 0 + per-host eval (8ug8ear, spider, blackhand)
  all GREEN via nix-portable in the WebUI container. No rename
  warnings after switching to `settings.Login.*` option names.

## 3. Negative test (spec execution)

- [x] 3.1 Deliberate `services.hypridle.enble = true` typo reproduced
  locally: eval fails with `The option
  'home-manager.users.eddie.services.hypridle.enble' does not exist`
  (naming this module file in the error). Reverted; final ladder run
  green. CI runs the identical flake-check + eval:<host> commands on
  the MR pipeline.

## 4. MR

- [x] 4.1 Branch `feat/session-locking`, MR !48 to master, title
  `feat(lock): session locking — hyprlock + hypridle + lid suspend (8ug8ear)`.
  Description: rationale (issue #3), bind-conflict resolution note,
  verification evidence, negative-test outcome. Pipeline #3187: all
  9 jobs green (pre-commit, flake-check, eval:8ug8ear, eval:spider,
  eval:blackhand, gitleaks ×2, trivy, hadolint).
- [ ] 4.2 After merge: update this change's tasks to [x], then
  `openspec archive atlantis-session-locking` — only after user
  confirms live-on-hosts.

## 5. Live verification (user, on 8ug8ear)

- [ ] 5.1 `nixos-rebuild switch --flake .#8ug8ear` + log out / back in
  (hypridle is a systemd user service started by
  graphical-session.target).
- [ ] 5.2 Manual lock: SUPER+l → lock screen appears; password
  unlocks. Also `hyprlock` directly from a terminal.
- [ ] 5.3 Idle lock: leave idle 10 min → locked. (Or temporarily
  lower the timeout to e.g. 30s to verify, then revert.)
- [ ] 5.4 Lid: close lid → suspends; open lid → resumes into lock
  screen, no black screen.
- [ ] 5.5 Regression: SUPER+CTRL+l moves focus right; SUPER+h/j/k
  unchanged; waybar/wallpaper/autostart untouched.

## Hand-off note

Tasks 1–4 are WebUI-doable (this session). Task 5 needs the physical
laptop. Per pacing rules, expect one rebuild round-trip; the negative
test (3.1) rides the MR pipeline, not a separate push.
