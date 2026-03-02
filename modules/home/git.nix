{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    userName = "ghostwire";
    userEmail = "eddie@b-quinn.com";

    signing = {
      key = "CA98D5946FA3A374BA7E2D8FB254FBF3F060B796";
      signByDefault = true;
    };

    aliases = {
      i     = "init";
      pl    = "pull";
      ps    = "push";
      cm    = "commit -S -m";
      amend = "commit --amend --no-edit";
      br    = "branch";
      co    = "checkout";
      cob   = "checkout -b";
      st    = "status";
      lg    = "log --oneline --graph --decorate --all";

      fi = ''!f() {
        if [ -z "$1" ]; then
          echo "Usage: git fi <namespace/repo>"
          return 1
        fi

        repo="$1"
        branch="master"
        remote="ssh://git@gitlab-ssh.eddiequinn.casa:2424/$repo.git"

        echo "→ Initialising git repo ($branch)"
        git init --initial-branch="$branch" || return 1

        echo "→ Adding remote: $remote"
        git remote add origin "$remote" || return 1

        echo "→ Creating initial commit"
        git add . || return 1
        git commit -m "Initial commit" || return 1

        echo "→ Pushing to origin"
        git push --set-upstream origin "$branch"
      }; f'';
    };

    extraConfig = {
      gpg.program = "gpg";
      tag.gpgSign = true;

      init.defaultBranch = "master";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}