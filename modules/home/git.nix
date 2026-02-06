{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    programs.git.settings.user.name = "ghostwire";
    programs.git.settings.user.email = "eddie@b-quinn.com";

    signing = {
      key = "CA98D5946FA3A374BA7E2D8FB254FBF3F060B796";
      signByDefault = true;
    };

    settings = {
      gpg.program = "gpg";
      tag.gpgSign = true;
    };
  };
}

