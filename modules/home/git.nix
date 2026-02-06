{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    signing = {
      key = "CA98D5946FA3A374BA7E2D8FB254FBF3F060B796";
      signByDefault = true;
    };

    extraConfig = {
      gpg.program = "gpg";
      tag.gpgSign = true;
    };
  };
}

