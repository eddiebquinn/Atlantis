{
  # Opt-in: imported by blackhand only.
  flake.modules.nixos.kube =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.kubectl
        pkgs.k3sup
        pkgs.kubernetes-helm
      ];
    };
}
