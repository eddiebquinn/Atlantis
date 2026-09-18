{ ... }:

{
  # Per-host hosts.conf wiring removed in §2.9b.
  home.file.".config/waybar/config.jsonc".source =
    ../../modules/home/configs/waybar/hosts/8ug8ear.jsonc;

  services.gpg-agent.sshKeys = [
    "6C456670D420AA1C989355232D469E70938B45F0"
  ];
}
