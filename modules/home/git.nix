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

    settings = {
      gpg.program = "gpg";
      tag.gpgSign = true;
    };
  };
}

