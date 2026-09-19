{ config, inputs, ... }:

# Host assembly — the one place that turns module definitions into
# real systems.
#
# Each host contributes its own `flake.modules.nixos.<name>` from
# modules/hosts/<name>.nix (plus modules/hosts/<name>/hardware.nix,
# which merges into the same attribute). This file only realises them.
let
  mkHost =
    name:
    inputs.nixpkgs.lib.nixosSystem {
      # No `system` argument on purpose: each host's hardware module
      # sets nixpkgs.hostPlatform, which is the modern equivalent and
      # keeps the platform fact next to the hardware that determines it.
      specialArgs = { inherit inputs; };
      modules = [ config.flake.modules.nixos.${name} ];
    };
in
{
  flake.nixosConfigurations = {
    "8ug8ear" = mkHost "8ug8ear";
    spider = mkHost "spider";
    blackhand = mkHost "blackhand";
  };
}
