{
  # Defined but currently imported by no host — carried over from the
  # pre-dendritic tree unchanged. `atlantis-dendritic-layout` proposes
  # deleting this; that is a separate change, so it survives the
  # structural conversion intact.
  flake.modules.nixos.qtile = {
    services.xserver = {
      enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 35;
      windowManager.qtile.enable = true;
    };

    services.libinput.enable = true;
  };
}
