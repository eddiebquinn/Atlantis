{
  description = "Atlantis Build";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    # Default; can be overridden per-host if you ever add ARM etc.
    defaultSystem = "x86_64-linux";

    mkHost =
      { hostName
      , system ? defaultSystem
      }:
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/${hostName}/configuration.nix

          home-manager.nixosModules.home-manager
          ({ ... }: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";

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
