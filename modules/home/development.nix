{
  # Renamed from the pre-conversion `devlopment.nix` (typo). Under
  # import-tree the filename is the only thing that referenced it, so
  # the rename needed no import updates anywhere.
  flake.modules.homeManager.eddie = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
