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
      ll = "ls -lah";
      gs = "git status";
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      if [[ -o interactive ]] && [[ -z "$SSH_CONNECTION" ]]; then
        ${pkgs.fastfetch}/bin/fastfetch && echo " "
      fi

      rebuild() {
        local prev_dir="$PWD"
        local host="$(hostname -s)"

        {
          cd /etc/nixos || return 1

          echo "→ Updating Atlantis repo…"
          sudo git pull --rebase --autostash || return 1

          echo "→ Rebuilding for host: $host"
          sudo nixos-rebuild switch --flake ".#$host"
        } always {
          cd "$prev_dir" || true
        }
      }

      fast-ginit() {
        if [[ -z "$1" ]]; then
          echo "Usage: fast-ginit <namespace/repo>"
          return 1
        fi

        local repo="$1"
        local remote="ssh://git@gitlab-ssh.eddiequinn.casa:2424/${repo}.git"

        echo "→ Initialising git repo (master)"
        git init --initial-branch=master || return 1

        echo "→ Adding remote: $remote"
        git remote add origin "$remote" || return 1

        echo "→ Creating initial commit"
        git add . || return 1
        git commit -m "Initial commit" || return 1

        echo "→ Pushing to origin"
        git push --set-upstream origin master
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
