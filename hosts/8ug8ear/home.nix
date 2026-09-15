{ ... }:

{
  home.file.".config/hypr/hosts.conf".source =
    ../../modules/home/configs/hypr/hosts/8ug8ear.conf;

  home.file.".config/waybar/config.jsonc".source =
    ../../modules/home/configs/waybar/hosts/8ug8ear.jsonc;

  services.gpg-agent.sshKeys = [
    "" # NEED TO GENERATE
  ];
}
