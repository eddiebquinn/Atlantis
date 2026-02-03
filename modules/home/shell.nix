{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      hm-test = "echo HM Running";
    };
  };
}
