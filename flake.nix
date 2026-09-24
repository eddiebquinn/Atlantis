{
  description = "Atlantis Build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Dendritic pattern substrate.
    #
    # flake-parts gives flake outputs a module system; import-tree
    # auto-imports every .nix file under ./modules as a flake-parts
    # module. Between them, no file in this repo carries an
    # `imports = [ ... ]` list of repo-local paths — the directory
    # tree IS the import graph. Adding a feature means adding a file.
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

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

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
