# system-channel Specification

## Purpose
The release-channel contract for Atlantis hosts: which nixpkgs and
home-manager revisions the fleet builds and runs against, and how a channel
position is proven on a live host.

## Requirements

### Requirement: Channel inputs are pinned to 26.05

The flake inputs SHALL pin `nixpkgs` to the `nixos-26.05` branch and
`home-manager` to the `release-26.05` branch, and `flake.lock` SHALL be
regenerated in the same commit so the inputs the lock resolves match the
declared refs.

#### Scenario: Lock matches declared inputs
- **WHEN** the repository is evaluated with `nix flake check` or built via
  `nixos-rebuild --flake .#<host>`
- **THEN** the locked `nixpkgs` node resolves to the `nixos-26.05` ref and the
  locked `home-manager` node resolves to `release-26.05`, and the build does
  not fail on a stale-lock assertion

### Requirement: Running systems prove their channel

Each host SHALL be verifiably running the pinned channel after the switch:
`/etc/os-release` reports `VERSION_ID="26.05"` and the current system
generation's store path contains the 26.05 version string.

#### Scenario: Host reports 26.05 after switch and reboot
- **WHEN** a host has completed `nixos-rebuild switch` and been rebooted into
  the new generation
- **THEN** `grep VERSION_ID /etc/os-release` prints `26.05` and
  `readlink /run/current-system` contains `26.05`

### Requirement: stateVersion remains at the install release

The channel contract MUST NOT move `system.stateVersion` or
`home.stateVersion`: they stay at `25.11` on both hosts. A stateVersion bump
is a separate, deliberate change with state-migration implications.

#### Scenario: stateVersion untouched by the channel move
- **WHEN** the channel inputs move from 25.11 to 26.05
- **THEN** `system.stateVersion` reads `25.11` in every host configuration
  and `home.stateVersion` reads `25.11` for the eddie user

### Requirement: Deprecation fallout is resolved, not suppressed

Option renames forced by the 26.05 modules (for example home-manager's
`programs.ssh.matchBlocks` to `programs.ssh.settings`) SHALL be migrated to
the replacement syntax in the same change as the channel move, not left as
warnings or silenced.

#### Scenario: ssh module migrated with the bump
- **WHEN** home-manager 26.05 evaluates the user profile
- **THEN** `programs.ssh` configuration is expressed via `settings` blocks
  and no new eval error is raised by the gpg/ssh agent wiring
