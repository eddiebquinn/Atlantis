{ ... }:

{
  # Per-host hosts.conf wiring removed in §2.9d.
  home.file.".config/waybar/config.jsonc".source =
    ../../modules/home/configs/waybar/hosts/blackhand.jsonc;

  services.gpg-agent.sshKeys = [
    "A9DB04F9B83610084AADB572724309E505A4D4B0"
  ];
}
