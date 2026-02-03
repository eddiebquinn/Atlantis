{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      hm-test = "echo HM Running";
    };

  initExtra = ''
    if [[ $- == *i* ]] && [[ -z "$SSH_CONNECTION" ]]; then
      ${pkgs.fastfetch}/bin/fastfetch
    fi
  '';
  };
}