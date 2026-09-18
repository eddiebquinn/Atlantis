# Tasks

## 1. Baseline module (rewrite, not conversion)

- [ ] 1.1 Branch `feat/compositor-rewrite` from current master.
- [ ] 1.2 Write `modules/home/hyprland.nix` as a **minimal skeleton**
  first: `enable`, `configType = "lua"`, `package = null`,
  `portalPackage = null`, `systemd.enable = true`, and an
  `extraConfig` containing ONLY the upstream example's preamble
  (source line, no sections, no binds). Nothing else.
- [ ] 1.3 Add `home.packages` (waybar, hyprpaper, wofi, grim, slurp,
  wl-clipboard) and the stub-removal activation hook.
- [ ] 1.4 Slim `modules/nixos/wm/hyprland.nix` to compositor enable +
  xwayland + portal pathsToLink.
- [ ] 1.5 `nixos-rebuild build --flake .#8ug8ear` — eval must pass.
- [ ] 1.6 Switch + reboot 8ug8ear. **Boot gate:** Hyprland starts, NO
  red error box, `hyprctl binds` returns more than the 3 emergency
  binds. If the red box appears, capture its text BEFORE any further
  edit — the error text is the only reliable diagnostic.

## 2. Incremental growth (one addition per boot-verified commit)

Each step: add ONE block to `extraConfig`, eval, switch, reboot,
verify. Never batch multiple additions — the parser errors are
positional (line numbers) and batching hides which shape failed.

- [ ] 2.1 Section config: single `hl.config({ general = {...} })` with
  gaps only. Boot-verify.
- [ ] 2.2 Add `decoration`, `animations` (+ per-leaf `hl.animation`
  calls), `dwindle`, `master`, `misc` (incl. splash flag), `input`,
  `cursor` sections to the `hl.config` block. One section per
  boot-verify cycle.
- [ ] 2.3 Env vars via `hl.env("KEY", "VALUE")` calls. Boot-verify.
- [ ] 2.4 Core binds: SUPER+Return/Q/M/E/V/D/R using
  `hl.bind(key, hl.dsp.*(...))`. Boot-verify with `hyprctl binds`.
- [ ] 2.5 Focus binds (hjkl), workspace-scroll binds, mouse binds
  (`hl.bindm`). Boot-verify.
- [ ] 2.6 Screenshot bind: SUPER+S via `os.execute` wrapper (the `$()`
  in the dispatcher string is parser-hostile; function body is not
  introspected). Boot-verify the bind registers (execution needs a
  session screenshot test).
- [ ] 2.7 Window rule (suppress-maximize) via raw `hl.window_rule({})`
  with bareword keys. Boot-verify.
- [ ] 2.8 Autostart: `hl.on("hyprland.start", ...)` for waybar +
  hyprpaper. Boot-verify both appear.
- [ ] 2.9 Delete `modules/home/configs/hypr/hyprland.conf` and the
  hosts/*.conf chain; rewire `home.file` → per-host attrs. Eval all
  three hosts.

## 3. Host rollout

- [ ] 3.1 8ug8ear full window: switch, reboot, `rm -f
  ~/.config/hypr/hyprland.conf` once, login — binds work, waybar +
  hyprpaper autostart, splash flag honoured.
- [ ] 3.2 spider: switch, reboot, same verification.
- [ ] 3.3 blackhand: switch, reboot, verify triple-head (DP-3 portrait
  left / DP-2 scaled centre / DP-1 portrait right) + workspace banks
  via the `banks` attr expansion.

## 4. Repository + MR hygiene

- [ ] 4.1 Open MR from `feat/compositor-rewrite` → master. Description
  documents: rewrite-not-conversion rationale, the MR !36 evidence,
  the boot-verified commit discipline.
- [ ] 4.2 Merge after all three hosts pass §3.
- [ ] 4.3 Archive this change (`openspec archive
  atlantis-26-05-declarative-compositor`).

## 5. Post-merge soak

- [ ] 5.1 All three hosts stable for a working session; any missing
  comfort from the old config becomes a follow-up commit, not a
  blocker.

## 6. Lessons folded into this change (informational)

- HM 26.05 Lua emitter shapes are parser-incompatible with Hyprland
  0.55 for: monitor single-string args, env tables, window_rule
  bracket keys, col.* dot syntax, bind string dispatchers, single
  quotes. All config content therefore lives in `extraConfig` as raw
  Lua mirroring the upstream example — HM typed attrs carry only
  enable/configType/package.
- The red-box error text is the only reliable diagnostic (hyprctl
  logs are silent on parse errors; screenshots over SSH go stale).
  Capture it before editing.
- One addition per boot-verified commit; positional parse errors make
  batched changes undiagnosable.
