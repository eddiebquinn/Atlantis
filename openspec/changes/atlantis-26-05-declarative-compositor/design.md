## Context

The 26.05 channel pin (`nixos-26.05` + `home-manager release-26.05`) is
already on master via commit `7db7426`. This change does not re-pin the
channel — it migrates the Hyprland session config to the declarative
form and extends the conversion to the third host (8ug8ear / X230,
added after this spec was first written).

The declarative compositor module itself was prototyped on
`feat/nixpkgs-26.05` (MR !28, closed 2026-09-16). The module survived
that branch in reviewable form (224 lines, Lua-mode configType, per-host
attrs pattern); this change inherits and extends that work.

## Goals / Non-Goals

**Goals:**
- Compositor config is a single source of truth: home-manager emits
  `hyprland.lua` from Nix attrs; no hand-edited conf files
  participate in any host session.
- All three hosts (`blackhand`, `spider`, `8ug8ear`) get the
  declarative conversion, including the splash-flag fold from the
  previous MR !32 work.
- `pathways.pathsToLink` assertion is satisfied so the home-manager
  `useUserPackages` mode evaluates cleanly.
- Per-host monitor / workspace topology lives in `hosts/<host>/home.nix`
  (mirroring how it was split across `hosts.conf` files previously).

**Non-Goals:**
- Re-pinning the channel pins (already on master).
- Waybar/wofi/fastfetch/hyprpaper → module conversion (separate change:
  `atlantis-dendritic-layout`).
- Hyprland rice / visual theming (separate change:
  `atlantis-dendritic-rice`).
- Touching MR !27 (unrelated blackhand nix-serve work).

## Decisions

- **Fresh MR, not rebased MR !28.** MR !28 was opened 2026-09-16
  against an older master and had never been built. Retargeting the API
  rejects same-value edits; closing it and opening a fresh MR is cleaner
  than a 60-commit rebase.
- **All three hosts in one change.** Adding 8ug8ear as a follow-up
  after the merge would just be re-doing the import-graph surgery
  against a half-converted state. Cleaner to extend the conversion
  in the same change.
- **Splash flag folds into the declarative module.** `misc.disable_splash_rendering = true`
  is added to `modules/home/hyprland.nix`'s `settings.config.misc` block,
  next to `force_default_wallpaper = 0`. The flag's runtime effect is
  unchanged but now lives in Nix — eval can confirm it's emitted
  correctly into the generated `hyprland.lua`.
- **Per-host `monitor` and `workspace_rule` attrs over the deleted
  `hosts.conf` chain.** The conversion loses nothing; the conf chain
  only carried `monitor = ,preferred,auto,1.0` and per-workspace bind
  overrides, both of which are cleanly expressible as Nix attrs.
- **Spider first, blackhand second, 8ug8ear third.** Smaller / less
  critical host first lets eval failures surface early without
  breaking a daily driver. 8ug8ear last because it's the host with
  the most divergent configuration (BIOS/MBR, GRUB not systemd-boot).

## Risks / Trade-offs

- **Eval gate is the only safety net for import-graph churn.** A
  broken `imports = [ ... ]` line fails the build loudly with a file
  + line number, but only if we run the eval. The `nixos-rebuild
  build` step in tasks §1.3 / 1.4 / 1.5 is mandatory before any
  switch attempt.
- **`dbus-broker` exit-4 on activation.** Known consequence of
  a major-version home-manager / NixOS jump. Recovery: reboot and
  re-run switch. Documented in the tasks so the first-time-it-happens
  operator doesn't panic.
- **8ug8ear-specific risk: stale `~/.config/hypr/hyprland.conf` from
  MR !32 work.** A `.conf` in `~/.config/hypr/` shadows the
  generated `hyprland.lua` because Hyprland prefers the `.conf` if
  both exist. Tasks §4.2 mandates a one-time `rm -f`.
- **Splash-flag regression risk.** If the flag does not survive the
  declarative conversion (Nix module not emitting the key into the
  generated Lua), the user's existing workaround (reboot to clear
  session-cached splash texture) may still apply. Task §4.3 includes
  a direct reboot-and-observe check on 8ug8ear.
- **No automated test for `hyprland.lua` content.** We verify by
  runtime behavior (waybar, binds, splash, wallpaper) — eval proves
  Nix attributes typecheck, not that the rendered file is semantically
  what Hyprland expects. The verification windows in tasks §2 / 3 / 4
  are the regression net.

## Out of scope (intentional)

- Waybar / wofi / fastfetch / hyprpaper module conversion — see
  `atlantis-dendritic-layout`.
- Visual / theming rice — see `atlantis-dendritic-rice`.
- Touching MR !27 (blackhand nix-serve, unrelated).
