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
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentry.package = pkgs.pinentry-gtk2;
    defaultCacheTtl = 3600;
    maxCacheTtl = 86400;
  };

  programs.zsh.initContent = ''
    export SSH_AUTH_SOCK="$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)"
  '';

  programs.ssh = {
    enable = true;
    matchBlocks."all" = {
      host = "*";
      identityAgent = "${config.home.homeDirectory}/.gnupg/S.gpg-agent.ssh";
      identityFile = "${config.home.homeDirectory}/.ssh/id_gpg.pub";
      identitiesOnly = true;
    };
  };
}
