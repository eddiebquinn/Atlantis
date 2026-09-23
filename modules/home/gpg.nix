{
  flake.modules.homeManager.eddie =
    { pkgs, ... }:
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
        enableDefaultConfig = false;

        # HM 26.05 deprecates `programs.ssh.matchBlocks` in favour of
        # `programs.ssh.settings.<host>` attrs. The HM `programs.ssh`
        # module exposes a top-level `settings.all` bucket for options
        # that apply to every host — which is exactly what this attribute
        # set was trying to express (host = "*"). See
        # openspec/changes/archive/2026-09-18-atlantis-26-05-declarative-compositor
        # proposal "Fold programs.ssh.matchBlocks → programs.ssh.settings.all".
        settings.all = {
          host = "*";
          identityAgent = "/run/user/1000/gnupg/S.gpg-agent.ssh";
        };
      };
    };
}
