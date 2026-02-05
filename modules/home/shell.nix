{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    fastfetch
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    history = {
      size = 10000;
      save = 10000;
    };

    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
      ll = "ls -lah";
      gs = "git status";
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      if [[ -o interactive ]] && [[ -z "$SSH_CONNECTION" ]]; then
        ${pkgs.fastfetch}/bin/fastfetch && echo " "
      fi
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;

      format = "[$username@$hostname]:$directory$git_branch$character";

      username = {
        show_always = true;
        format = "$user";
      };

      hostname = {
        ssh_only = false;
        format = "$hostname";
      };

      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
        format = "$path";
      };

      git_branch = {
        format = " ($branch)";
        style = "white";
      };

      character = {
        success_symbol = " \\$";
        error_symbol   = " \\$";
      };
    };
  };
}