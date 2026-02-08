{ ... }:

{

  imports = [
    ../../kube.nix
  ];

  home.file.".config/hypr/hosts.conf".source =
    ../../modules/home/configs/hypr/hosts/blackhand.conf;

  home.file.".config/waybar/config.jsonc".source =
    ../../modules/home/configs/waybar/hosts/blackhand.jsonc;

  services.gpg-agent.sshKeys = [
    "A9DB04F9B83610084AADB572724309E505A4D4B0"
  ];
}
