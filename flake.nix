{
  description = "Atlantis Build";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
      spider = mkHost { hostName = "spider"; };
      blackhand = mkHost { hostName = "blackhand"; };
    };
  };
}
