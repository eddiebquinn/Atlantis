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
      g = "git";
      ll = "ls -lah";
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"
      if [[ -o interactive ]] && [[ -z "$SSH_CONNECTION" ]]; then
        ${pkgs.fastfetch}/bin/fastfetch && echo " "
      fi

      rebuild() {
        local prev_dir="$PWD"
        local host="$(hostname -s)"
        local target_branch=""

        case "${1:-}" in
          --switch|-s)
            target_branch="${2:-master}"
            ;;
          "")
            ;;
          *)
            echo "Usage: rebuild [--switch|-s [branch-name]]"
            return 1
            ;;
        esac

        {
          cd /home/eddie/.local/share/atlantis || return 1

          if [[ -n "$target_branch" ]]; then
            echo "→ Switching Atlantis repo to branch: $target_branch"
            git fetch origin "$target_branch" || return 1
            git switch "$target_branch" 2>/dev/null || git switch -c "$target_branch" --track "origin/$target_branch" || return 1
          fi

          echo "→ Updating Atlantis repo…"
          git pull --rebase --autostash || return 1

          echo "→ Rebuilding for host: $host"
          sudo nixos-rebuild switch --flake ".#$host"
        } always {
          cd "$prev_dir" || true
        }
      }

    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;

      format = "$username@$hostname:$directory$git_branch$character";

      username = {
        show_always = true;
        format = "\\[$user";
      };

      hostname = {
        ssh_only = false;
        format = "$hostname\\]";
      };

      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
        format = "$path";
      };

      git_branch = {
        format = " \\($branch\\)";
        style = "white";
      };

      character = {
        success_symbol = " \\$";
        error_symbol   = " \\$";
      };
    };
  };
}
