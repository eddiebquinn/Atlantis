{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    fastfetch
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      hm-test = "echo HM Running";
    };
  };

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
        ${pkgs.fastfetch}/bin/fastfetch
      fi
    '';
  };

 programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;

      # Format: user@host:path (git) $
      format = "$username@$hostname:$directory$git_branch$git_status$character";

      username = {
        show_always = true;
        format = "$user";
      };

      hostname = {
        ssh_only = false;
        format = "$hostname";
      };

      directory = {
        truncation_length = 0; # show full relative path (~ and repo root awareness)
        truncate_to_repo = false;
        format = "$path";
      };

      git_branch = {
        format = " [$branch]($style)";
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style)";
      };

      character = {
        success_symbol = " $";
        error_symbol = " $";
      };
    };
  };
}