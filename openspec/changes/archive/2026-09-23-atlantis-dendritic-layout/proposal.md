## Why

After the 26.05 + declarative-compositor change lands, the remaining userland
config surfaces (waybar, wofi, fastfetch, hyprpaper) still live as raw files
in a `modules/home/configs/` grab-bag wired through scattered `home.file`
indirections in `home/eddie/home.nix`. That layout predates the dendritic
pattern the rest of the fleet is converging on: one feature module owning
its configuration and its assets, hosts importing modules — not files.

## What Changes

- Convert waybar to `programs.waybar` (settings attrs + CSS as
  `programs.waybar.style`), with per-host module layouts declared in
  `hosts/<host>/home.nix`.
- Convert wofi to `programs.wofi` (settings + style).
- Convert fastfetch to `programs.fastfetch` (structured settings).
- Re-home hyprpaper into a feature module owning its config and the
  wallpapers asset directory; migrate the config from pre-0.8
  `preload =` / `wallpaper =` syntax to the 0.8+ block syntax that the
  26.05-channel hyprpaper requires.
- Rename `modules/home/devlopment.nix` → `development.nix` (typo) and
  update the import.
- Delete `modules/nixos/wm/qtile.nix` (verified unimported by any host).
- Thin `home/eddie/home.nix` to an import list only; delete
  `modules/home/configs/` entirely.

Out of scope: Hyprland rice (separate later change — see
`atlantis-dendritic-rice`), any NixOS-layer modules beyond the dead-module
deletion.

**Sequencing:** This change is blocked on `atlantis-26-05-declarative-compositor`
landing and a stability soak. The dendritic pattern this change
introduces is the same pattern that change establishes for Hyprland
(monitor / workspace attrs in host files, settings in feature modules).
Picking that up before the pattern is in production would mean re-doing
work when the upstream change ships.

## Capabilities

### New Capabilities
- `module-ownership`: the repository-layout contract — every userland config
  surface is owned by a feature module that declares its program settings
  and assets; no central grab-bag directory, no cross-tree `home.file`
  indirections, no dead modules.

### Modified Capabilities

(none)

## Impact

- `modules/home/{waybar,wofi,fastfetch,hyprpaper}.nix` — new feature
  modules (hyprpaper via `xdg.configFile`, others via HM program options).
- `modules/home/configs/` — deleted; wallpapers and any non-declarative
  assets move to `modules/home/hyprpaper/` (beside their module).
- `modules/home/devlopment.nix` → `modules/home/development.nix`.
- `modules/nixos/wm/qtile.nix` — deleted (dead code).
- `home/eddie/home.nix`, `hosts/{blackhand,spider}/home.nix` — import list
  and per-host waybar settings.
- Runtime: hyprpaper syntax migration is behavior-relevant on both hosts;
  everything else is no-op at runtime (config content equivalent).
