{ config, inputs, ... }:

# Home-manager glue, NixOS side.
#
# Part of `workstation`, so every host gets it. Host-specific home
# config is contributed by each host's own file via
# `home-manager.users.eddie`, which merges with the definition here
# rather than replacing it.
{
  flake.modules.nixos.workstation = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";

      # For Home-Manager modules
      extraSpecialArgs = { inherit inputs; };

      users.eddie = {
        imports = [ config.flake.modules.homeManager.eddie ];
      };
    };
  };
}
