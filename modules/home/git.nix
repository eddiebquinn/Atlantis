{ config, pkgs, ... }:

let
  gitFi = ./scripts/git-fi;
in
{
  programs.git = {
    enable = true;

    signing = {
      key = "CA98D5946FA3A374BA7E2D8FB254FBF3F060B796";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "ghostwire";
        email = "eddie@b-quinn.com";
      };

      gpg.program = "gpg";
      tag.gpgSign = true;

      init.defaultBranch = "master";
      pull.rebase = true;
      push.autoSetupRemote = true;

      alias = {
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
        fi = "!git-fi";
      };
    };
  };

  home.file.".local/bin/git-fi" = {
    source = gitFi;
    executable = true;
  };
}