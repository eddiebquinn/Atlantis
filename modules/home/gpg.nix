{ config, pkgs, lib, ... }:

{
  programs.gpg = {
    enable = true;
    settings = {
      keyserver = "hkps://keys.openpgp.org";
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSSHSupport = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 86400;
    pinentryPackage = pkgs.pinentry-gtk2;
  };
}
