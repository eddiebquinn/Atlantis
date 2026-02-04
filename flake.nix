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
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.spider = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/spider/configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.eddie = import ./home/eddie/home.nix;
            backupFileExtension = "backup";
          };
        }
      ];
    };

    nixosConfigurations.blackhand = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/blackhand/configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.eddie = import ./home/eddie/home.nix;
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}
