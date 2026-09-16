{ ... }:

{
  home.file.".config/hypr/hosts.conf".source =
    ../../modules/home/configs/hypr/hosts/8ug8ear.conf;

  home.file.".config/waybar/config.jsonc".source =
    ../../modules/home/configs/waybar/hosts/8ug8ear.jsonc;

  services.gpg-agent.sshKeys = [
    "6C456670D420AA1C989355232D469E70938B45F0"
  ];
}
