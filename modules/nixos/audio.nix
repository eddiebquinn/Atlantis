{
  # Opt-in: imported by blackhand only.
  flake.modules.nixos.audio =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        pavucontrol
      ];

      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };
    };
}
