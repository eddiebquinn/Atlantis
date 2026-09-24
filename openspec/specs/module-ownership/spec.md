# module-ownership Specification

## Purpose
The repository-layout contract for Atlantis userland configuration: every
config surface is owned by exactly one feature module that declares its
program settings and its assets, leaving no central grab-bag, no cross-tree
file indirections, and no dead modules.

## Requirements

### Requirement: Program configs are declared, not deployed as files

Userland programs with home-manager support (waybar, wofi, fastfetch) SHALL
be configured through their `programs.<name>` options in feature modules,
not by deploying raw config files via `home.file`/`xdg.configFile`
indirections.

#### Scenario: waybar configured via programs.waybar
- **WHEN** the user profile evaluates
- **THEN** waybar's module layout, styling, and per-host differences are
  expressed as `programs.waybar.settings` and `programs.waybar.style`
  attrs, and no `home.file.".config/waybar/..."` entry exists

#### Scenario: wofi and fastfetch follow the same pattern
- **WHEN** the user profile evaluates
- **THEN** wofi's settings/style and fastfetch's module list are expressed
  as `programs.wofi.*` and `programs.fastfetch.*` attrs respectively

### Requirement: Programs without HM modules own their files locally

Programs lacking a home-manager module (hyprpaper) SHALL have a dedicated
feature module that owns both the config file (via `xdg.configFile`) and
the asset directory it references, co-located beside the module.

#### Scenario: hyprpaper config and wallpaper live together
- **WHEN** the hyprpaper feature module is imported
- **THEN** the module deploys `hyprpaper.conf` and the wallpapers directory
  from paths under its own directory, and no other module references those
  files

### Requirement: hyprpaper config uses 0.8+ syntax

The deployed `hyprpaper.conf` SHALL use the block syntax required by
hyprpaper 0.8 and later (as shipped on the 26.05 channel); the legacy
`preload =` / `wallpaper =` key-value form MUST NOT remain.

#### Scenario: wallpaper applies on a 0.8+ hyprpaper
- **WHEN** a Hyprland session starts on either host after this change
- **THEN** hyprpaper applies the black-triangle wallpaper without a config
  parse error or fallback to an empty background

### Requirement: Central entry point is imports only

`home/eddie/home.nix` SHALL contain only module imports (plus user-level
state options); it MUST NOT deploy files or declare program settings
itself.

#### Scenario: no file wiring in the central home file
- **WHEN** the central home file is inspected after this change
- **THEN** it holds an import list and no `home.file` entries

### Requirement: No dead or misnamed modules

Modules not imported by any host or user profile SHALL NOT exist in the
repository, and module filenames SHALL match their subject
(`development.nix`, not `devlopment.nix`).

#### Scenario: qtile module removed
- **WHEN** the repository is searched for `wm/qtile` after this change
- **THEN** no such file exists and no host configuration references it

#### Scenario: development module import resolves
- **WHEN** the user profile evaluates
- **THEN** the import of the development module resolves to
  `modules/home/development.nix`
