{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;

      # good hygiene
      X11Forwarding = false;
      AllowAgentForwarding = false;
      AllowTcpForwarding = "no";
    };
  };

  # If you use firewall
  networking.firewall.allowedTCPPorts = [ 22 ];
}