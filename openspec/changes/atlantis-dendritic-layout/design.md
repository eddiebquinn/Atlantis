## Context

MR !28's branch already established the pattern for one surface (hyprland):
feature module with settings attrs, per-host attrs in `hosts/<host>/home.nix`,
assets re-homed beside the module. This change extends that pattern to the
remaining surfaces. The raw files were audited: waybar (jsonc + css, with
per-host jsonc variants), wofi (key-value + css), fastfetch (jsonc),
hyprpaper (conf + wallpapers dir). The hyprpaper conf is still on pre-0.8
syntax (`preload =` / `wallpaper =`) which the 26.05-channel hyprpaper no
longer accepts — the conversion is also a syntax migration, not just a move.

## Goals / Non-Goals

**Goals:**
- Every userland surface follows the dendritic pattern: feature module owns
  settings + assets, no central grab-bag, no cross-tree indirections.
- Central `home/eddie/home.nix` reduced to an import list.
- hyprpaper on 0.8+ block syntax so the wallpaper actually applies on 26.05.
- Typo rename and dead-module removal done while the tree is being touched.

**Non-Goals:**
- Any visual/theming change (colors, fonts, modules shown) — rice is a
  later change.
- NixOS-layer reorganization beyond deleting the dead qtile module.
- Touching MR !28's scope; this change branches after !28 merges.

## Decisions

- **Hyprpaper gets a file-owning module, not a fake settings attrset.**
  hyprpaper has no home-manager program module; wrapping its conf in
  invented attrs would be ceremony without value. The module owns
  `hyprpaper.conf` (via `xdg.configFile`, written in 0.8 block syntax) and
  the wallpapers directory, both under `modules/home/hyprpaper/`.
- **CSS files become `programs.waybar.style` / `programs.wofi.style`.** The
  HM options accept a path (or text). Using a path to a co-located CSS
  asset keeps the module self-contained while staying declarative.
  Alternative rejected: inlining CSS as a Nix string — churn without gain.
- **Per-host waybar differences stay in host files.** The base module
  defines common modules/style; hosts override `programs.waybar.settings`
  module lists (blackhand's triple-head bar differs from spider's). This
  mirrors how hyprland monitors/workspaces were handled in MR !28.
- **waybar jsonc comments are converted, not preserved.** `programs.waybar`
  settings are typed Nix attrs; the jsonc comments in the current files
  don't survive. Acceptable loss — the attrset is self-describing.
- **Rename + dead-code removal ride along.** `devlopment.nix` → 
  `development.nix` and qtile deletion are tree hygiene in the same logical
  change as the re-homing; splitting them out is MR ceremony without
  review value.

## Risks / Trade-offs

- **Config-content equivalence is assumed, not machine-checked.** The
  jsonc→attrs conversions are hand-checked; a dropped key renders as a
  missing bar module or wofi quirk at next login, not an eval error.
  Mitigation: side-by-side diff during implementation, login check per
  host in tasks.
- **hyprpaper syntax migration is the one behavior-relevant change.** If
  the 0.8 block form is subtly wrong, wallpaper silently doesn't apply.
  Task includes explicit wallpaper-applied check on both hosts.
- **Hyprland `source =` chain already removed in MR !28** — this change
  inherits that; no additional migration risk from the conf chain.
- **Import-graph churn.** Renames and re-homing touch every import line;
  eval is the safety net (a broken path fails the build loudly).
- **qtile deletion is verified-safe but irreversible in git-history terms.**
  Verified unimported on master and the 26.05 branch (grep across both
  hosts' configuration.nix and the modules tree); recoverable from history
  if ever needed.
