{ config, pkgs, ... }:

{

  # Tools that make any shell nicer
  home.packages = with pkgs; [
    fastfetch
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      hm-test = "echo HM Running";
    };
  };


  # Enable zsh (this becomes your interactive shell)
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
    };

    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
      ll = "ls -lah";
      gs = "git status";
    };

    initExtra = ''
      if [[ $- == *i* ]] && [[ -z "$SSH_CONNECTION" ]]; then
        ${pkgs.fastfetch}/bin/fastfetch
      fi
    '';
  };
  
}