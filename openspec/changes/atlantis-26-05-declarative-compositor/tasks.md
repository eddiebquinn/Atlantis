# Tasks

## 1. Branch + eval gate

- [ ] 1.1 Branch `feat/declarative-compositor` from current master
  (NOT from the old `feat/nixpkgs-26.05` — that branch was closed in
  favour of this fresh MR).
- [ ] 1.2 Confirm `flake.nix` input pins on the new branch still match
  master (`nixos-26.05`, `home-manager release-26.05`).
- [ ] 1.3 `nixos-rebuild build --flake .#spider` — eval must succeed
  with the `pathways.pathsToLink` assertion satisfied and the gpg/ssh
  `matchBlocks` → `settings` migration clean.
- [ ] 1.4 Same for `.#blackhand`.
- [ ] 1.5 Same for `.#8ug8ear` — this is the host most likely to break
  (the imported `modules/nixos/wm/hyprland.nix` is being deleted; the
  `hosts.conf` chain is being deleted). If this eval fails, the
  conversion is not safe to merge.

## 2. Spider window (smaller host first)

- [ ] 2.1 `sudo nixos-rebuild switch --flake .#spider`. If activation
  exits 4 on `dbus-broker.service` user-unit reload, treat as expected:
  reboot, then re-run switch (exit 0).
- [ ] 2.2 Reboot into the new generation.
- [ ] 2.3 `rm -f ~/.config/hypr/hyprland.conf` once. Confirm
  `~/.config/hypr/hyprland.lua` is a symlink into the Nix store.
- [ ] 2.4 Login to Hyprland: waybar + hyprpaper present, wofi spawns,
  screenshot bind works, kb layout gb, focus binds (SUPER+h/j/k/l)
  work. Triple-check: no `hyprland.conf` shadows the generated
  `hyprland.lua`.

## 3. Blackhand window (daily driver, second)

- [ ] 3.1 `sudo nixos-rebuild switch --flake .#blackhand`; same
  dbus-broker exit-4 expectation → reboot → re-switch.
- [ ] 3.2 Reboot; `rm -f ~/.config/hypr/hyprland.conf`; confirm
  `hyprland.lua` is a Nix-store symlink.
- [ ] 3.3 Login: triple-head layout correct (DP-3 portrait left,
  DP-2 scaled centre, DP-1 portrait right), workspace banks on the
  right monitors, binds work.

## 4. 8ug8ear window (X230, third — added after the original spec)

- [ ] 4.1 `sudo nixos-rebuild switch --flake .#8ug8ear`; same
  dbus-broker caveat → reboot → re-switch.
- [ ] 4.2 Reboot; `rm -f ~/.config/hypr/hyprland.conf`; confirm
  `hyprland.lua` is a Nix-store symlink.
- [ ] 4.3 Login: X230 internal display, single monitor, default
  layout from the `monitor = { output = ""; mode = "preferred"; ...}`
  attr in `hosts/8ug8ear/home.nix`. Verify the splash flag is honoured
  on a fresh compositor boot (`misc:disable_splash_rendering = true`
  is now declarative, so eval verification is direct).
- [ ] 4.4 Confirm hostname reads `8ug8ear` after switch (the GRUB /
  hostname fix from MR !32 must still be in effect).

## 5. Repository + MR hygiene

- [ ] 5.1 Open a fresh MR from `feat/declarative-compositor` → master
  with a description that documents: (a) the real diff vs current
  master, (b) the channel-bump-is-already-on-master callout, (c) the
  8ug8ear extension. Reference MR !32 (the X230 work) for context
  but not MR !28 (which is closed).
- [ ] 5.2 Note in the description that spider is verified first,
  blackhand follows, 8ug8ear third (the same order as the verification
  windows above).
- [ ] 5.3 Merge the MR once all three hosts pass their verification
  windows.
- [ ] 5.4 Archive this change (`openspec archive
  atlantis-26-05-declarative-compositor`).

## 6. Post-merge stability soak

- [ ] 6.1 All three hosts stable for a working session with no
  compositor regressions (gaps, blur, cursor size, tearing behaviour,
  splash flag behaviour) before the next change starts.

## 7. Coupling note (informational)

- The checklist item "Update to 26.05" and the checklist item
  "Convert hyprland config over to nixdriven" are coupled into this
  single openspec change because Hyprland's Lua config format requires
  Hyprland 0.55+, which is what nixos-26.05 ships. One MR covers both.
