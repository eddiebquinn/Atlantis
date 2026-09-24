{
  # Pangolin ZTNA client (fosrl/cli) — the single-binary WireGuard-based
  # zero-trust-network-access client for end-user devices. Distinct from
  # Newt (fosrl/newt), which is a docker-compose tunnel connector for
  # homelab hosts, deployed via cf-pangolin + Ansible.
  #
  # Opt-in: imported by 8ug8ear only. Other hosts import this aggregate
  # when they need ZTNA access to Pangolin core.
  #
  # This is split across two aggregates: NixOS installs the package;
  # Home Manager owns the user's own files (xdg.configFile,
  # home.file.<...>). NixOS modules can't write to those namespaces —
  # both are Home Manager options, not NixOS ones.

  flake.modules.nixos.pangolin-cli =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.pangolin-cli
      ];
    };

  flake.modules.homeManager.eddie =
    { ... }:
    {
      # waybar include fragment — waybar reads this directory via
      # the top-level "includes" entry in the host's waybar.jsonc.
      xdg.configFile."waybar/includes/pangolin.jsonc".source = ./pangolin-waybar.jsonc;

      # Polling helper. Waybar runs this every `interval` seconds.
      home.file.".local/bin/pangolin-waybar-status" = {
        source = ./pangolin-waybar-status.sh;
        executable = true;
      };
    };
}
