{
  flake.modules.homeManager.eddie = {
    home.file.".config/wofi".source = ./wofi;
  };
}
