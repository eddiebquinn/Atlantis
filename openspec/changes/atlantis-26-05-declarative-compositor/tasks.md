## 1. Evaluation gate (on feat/nixpkgs-26.05)

- [ ] 1.1 Checkout `feat/nixpkgs-26.05` on spider (or in a scratch clone), run
  `nixos-rebuild build --flake .#spider`, confirm eval succeeds with the
  compositor module + pathsToLink assertion satisfied
- [ ] 1.2 Same for `.#blackhand`; confirm no eval errors from the gpg/ssh
  settings migration (matchBlocks deprecation warning from the module chain
  is known upstream noise — accept, do not chase)
- [ ] 1.3 Confirm `modules/nixos/wm/hyprland.nix` and the `.conf` chain are
  absent from the branch tree, and spider's configuration.nix no longer
  imports the deleted module

## 2. Spider window (smaller host first)

- [ ] 2.1 `sudo nixos-rebuild switch --flake .#spider`; if activation exits 4
  on `dbus-broker.service` user-unit reload, treat as expected: reboot, then
  re-run switch to complete activation (exit 0)
- [ ] 2.2 Reboot into the new generation
- [ ] 2.3 Channel proof: `grep VERSION_ID /etc/os-release` → `26.05`;
  `readlink /run/current-system` contains `26.05`; `sudo bootctl list` shows
  the new generation as default
- [ ] 2.4 `rm -f ~/.config/hypr/hyprland.conf`; confirm
  `~/.config/hypr/hyprland.lua` is a symlink into the Nix store
- [ ] 2.5 Login to Hyprland: waybar + hyprpaper present, wofi spawns,
  screenshot bind works, kb layout gb, focus binds (SUPER+h/j/k/l) work

## 3. Blackhand window (daily driver, second)

- [ ] 3.1 `sudo nixos-rebuild switch --flake .#blackhand`; same dbus-broker
  exit-4 expectation → reboot → re-switch
- [ ] 3.2 Reboot; channel proof as 2.3
- [ ] 3.3 `rm -f ~/.config/hypr/hyprland.conf`; hyprland.lua symlink check
- [ ] 3.4 Login: triple-head layout correct (DP-3 portrait left, DP-2 scaled
  centre, DP-1 portrait right), workspace banks on the right monitors,
  binds work

## 4. Repository + MR hygiene

- [ ] 4.1 Rewrite MR !28 description to document the real diff: channel pins
  + lock, declarative compositor module, deleted NixOS module + conf chain,
  per-host attrs, pathsToLink, gpg/ssh migration, and the manual `.conf`
  purge + verification runbook
- [ ] 4.2 Note in the description that spider is verified first; blackhand
  follows (links to the runbook steps 2.x / 3.x)
- [ ] 4.3 Merge MR !28 once both hosts pass their windows; archive this
  change (`openspec archive atlantis-26-05-declarative-compositor`)

## 5. Post-merge stability soak

- [ ] 5.1 Both hosts stable for a working session with no compositor
  regressions (gaps, blur, cursor size, tearing behaviour) before the
  dendritic change starts
