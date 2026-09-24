{
  # Pangolin ZTNA client (fosrl/cli) — the single-binary WireGuard-based
  # zero-trust-network-access client for end-user devices. Distinct from
  # the Newt agent (fosrl/newt), which is a docker-compose tunnel
  # connector for homelab hosts, deployed via cf-pangolin + Ansible.
  #
  # Opt-in: imported by 8ug8ear only. Other hosts import this aggregate
  # when they need ZTNA access to Pangolin core.
  flake.modules.nixos.pangolin-cli =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.pangolin-cli
      ];
    };
}
