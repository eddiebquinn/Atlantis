{
  # The shared stylesheet only. Each host points
  # `.config/waybar/config.jsonc` at its own layout from
  # modules/hosts/<name>/waybar.jsonc.
  #
  # NOTE: ./waybar/config.jsonc is carried over from the old
  # modules/home/configs/waybar/ directory but is referenced by
  # nothing — every host supplies its own. Left in place rather than
  # deleted as part of a structural conversion.
  flake.modules.homeManager.eddie = {
    home.file.".config/waybar/style.css".source = ./waybar/style.css;
  };
}
