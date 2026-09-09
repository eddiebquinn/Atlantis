## 1. Branch + scaffolding

- [ ] 1.1 Confirm MR !28 is merged and both hosts passed their verification
  windows + stability soak (change 1, tasks 5.1) before starting
- [ ] 1.2 Branch `feat/dendritic-layout` off master

## 2. Feature modules

- [ ] 2.1 Create `modules/home/waybar.nix`: `programs.waybar.enable`,
  settings attrs from `configs/waybar/config.jsonc`, style via
  `programs.waybar.style` pointing at co-located CSS; remove the
  `home.file` waybar wiring from `home/eddie/home.nix` and the per-host
  `hosts.conf` waybar entries from `hosts/*/home.nix`
- [ ] 2.2 Move per-host waybar module lists into
  `programs.waybar.settings` overrides in `hosts/{blackhand,spider}/home.nix`
  (side-by-side diff the jsonc→attrs conversion against the old files)
- [ ] 2.3 Create `modules/home/wofi.nix`: `programs.wofi` settings + style
  from `configs/wofi/{config,style.css}`; delete the raw files and their
  wiring
- [ ] 2.4 Create `modules/home/fastfetch.nix`: `programs.fastfetch`
  settings from `configs/fastfetch/config.jsonc`; delete the raw files and
  wiring
- [ ] 2.5 Create `modules/home/hyprpaper/` (module + wallpapers dir):
  `xdg.configFile."hypr/hyprpaper.conf"` written in 0.8+ block syntax
  (`wallpaper { monitor = ; path = ...; fit_mode = ... }`), wallpapers
  asset moved beside it; delete `configs/hypr/` remnants

## 3. Tree hygiene

- [ ] 3.1 `git mv modules/home/devlopment.nix modules/home/development.nix`;
  update the import in `home/eddie/home.nix`
- [ ] 3.2 Delete `modules/nixos/wm/qtile.nix` (verified unimported);
  remove the now-empty `modules/nixos/wm/` directory if nothing else
  remains
- [ ] 3.3 Delete `modules/home/configs/` entirely; confirm
  `home/eddie/home.nix` is imports-only

## 4. Verification

- [ ] 4.1 Eval both hosts: `nixos-rebuild build --flake .#spider` and
  `.#blackhand` — import-graph changes fail loudly here
- [ ] 4.2 Switch + login spider: waybar modules match the old layout,
  wofi style correct, fastfetch renders, wallpaper applies (hyprpaper
  0.8 syntax check)
- [ ] 4.3 Switch + login blackhand: same checks with the triple-head bar
- [ ] 4.4 Grep the tree for `configs/` references — zero hits expected

## 5. Land

- [ ] 5.1 Open MR with the conversion diff + side-by-side notes for the
  jsonc→attrs translations
- [ ] 5.2 After merge: archive this change; the rice change can start
  from a clean dendritic base
