{ config, pkgs, ... }:

{
  home.username = "eddie";
  home.homeDirectory = "/home/eddie";
  programs.git.enable = true;
  home.stateVersion = "25.05";
  programs.bash = {
    enable = true;
    shellAliases = {
      hm-test = "echo HM Running";
    };
  };
}
