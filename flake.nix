{
  description = "Atlantis Build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rycee Firefox add-ons packaged as a flake (minimal alternative to full NUR)
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, firefox-addons, ... }@inputs:
  let
    defaultSystem = "x86_64-linux";

    # Per-system overlays. Currently patches waybar 0.15.0 to fix
    # Hyprland 0.55.2 IPC dispatch — see overlays/default.nix for
    # the rationale and patches/waybar-pr5013-lua-dispatch.patch for
    # the backport itself.
    mkOverlays = _system: import ./overlays;

    mkHost =
      { hostName
      , system ? defaultSystem
      }:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs hostName; };

        modules = [
          ./hosts/${hostName}/configuration.nix

          home-manager.nixosModules.home-manager

          ({ ... }: {
            nixpkgs.overlays = mkOverlays system;

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";

              # For Home-Manager modules
              extraSpecialArgs = { inherit inputs hostName; };

              users.eddie = { ... }: {
                imports = [
                  ./home/eddie/home.nix
                  ./hosts/${hostName}/home.nix
                ];
              };
            };
          })
        ];
      };
  in
  {
    nixosConfigurations = {
      "8ug8ear" = mkHost { hostName = "8ug8ear"; };
      spider = mkHost { hostName = "spider"; };
      blackhand = mkHost { hostName = "blackhand"; };
    };
  };
}
