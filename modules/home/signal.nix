{
  flake.modules.homeManager.eddie =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        signal-desktop
      ];
    };
}
