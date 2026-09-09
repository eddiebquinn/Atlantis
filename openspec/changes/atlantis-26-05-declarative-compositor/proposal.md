## Why

Atlantis pins nixpkgs/home-manager 25.11 while Hyprland 26.05 has dropped the
hyprlang config format entirely, and the WM's configuration currently lives in
hand-maintained `.conf` files wired through `home.file` indirections. A branch
(`feat/nixpkgs-26.05`, MR !28) already carries most of the combined
channel-bump + declarative-compositor migration, but it has never been built,
booted, or verified — and its MR description documents a fraction of what the
branch actually changes.

## What Changes

- Pin `nixpkgs` to `nixos-26.05` and `home-manager` to `release-26.05`
  (flake.nix + regenerated flake.lock; already present on MR !28's branch).
- Replace the raw `hyprland.conf` + per-host `hosts.conf` file chain with a
  home-manager `wayland.windowManager.hyprland` module
  (`modules/home/hyprland.nix`, `configType = "lua"`), with per-host
  monitor/workspace attrs in `hosts/<host>/home.nix`.
- Delete `modules/nixos/wm/hyprland.nix` and the sourced `.conf` files, and
  remove spider's NixOS-level import of the deleted module.
- Add `environment.pathsToLink` for portal/desktop entries on both hosts
  (home-manager 26.05 assertion).
- Fold in `programs.ssh.matchBlocks` → `programs.ssh.settings` migration
  (gpg.nix) required by home-manager 26.05.
- Rewrite MR !28's description to reflect the branch's real contents and the
  verification runbook.
- **BREAKING** (for the user's session): a stale `~/.config/hypr/hyprland.conf`
  must be removed once on each host or Hyprland ignores the generated Lua
  config. Documented in tasks as a manual step.

Out of scope: dendritic conversion of waybar/wofi/fastfetch/hyprpaper
(follow-up change), Hyprland rice (later change), MR !27 (unrelated).

## Capabilities

### New Capabilities
- `system-channel`: the release channel contract — both hosts build and run
  against pinned nixpkgs/home-manager 26.05 inputs with stateVersion held at
  25.11, verified by on-host checks.
- `compositor-config`: the Hyprland session configuration contract — generated
  by home-manager as the single source of truth, no hand-edited conf files,
  per-host monitors and workspace banks via host attrs.

### Modified Capabilities

(none — no existing specs)

## Impact

- `flake.nix`, `flake.lock` — input pins move to 26.05.
- `modules/home/hyprland.nix` — new declarative module (on branch).
- `modules/nixos/wm/hyprland.nix`, `modules/home/configs/hypr/hyprland.conf`,
  `modules/home/configs/hypr/hosts/{blackhand,spider}.conf` — deleted.
- `hosts/{blackhand,spider}/{home,configuration}.nix` — imports,
  pathsToLink, per-host hyprland attrs.
- `modules/home/gpg.nix` — ssh matchBlocks → settings migration.
- `home/eddie/home.nix` — import list + remaining file wiring.
- Runtime: both hosts require build → switch (dbus-broker user-unit reload may
  exit 4 on the major jump; reboot then re-switch) and a one-time
  `rm -f ~/.config/hypr/hyprland.conf`.
