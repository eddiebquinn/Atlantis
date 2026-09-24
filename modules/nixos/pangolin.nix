{
  # Defined but currently imported by no host — carried over from the
  # pre-dendritic tree unchanged. Under this pattern an unreferenced
  # module definition costs nothing at eval time; deleting it is a
  # separate decision (see openspec/changes/atlantis-dendritic-layout).
  flake.modules.nixos.pangolin =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs."fosrl-olm"
      ];
    };
}
