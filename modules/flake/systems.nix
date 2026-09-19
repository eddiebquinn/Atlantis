# flake-parts requires an explicit system list for its perSystem
# outputs. The whole fleet is x86_64-linux; each host additionally
# pins its own platform via nixpkgs.hostPlatform in its hardware
# module, which is what nixosSystem actually reads.
{
  systems = [ "x86_64-linux" ];
}
