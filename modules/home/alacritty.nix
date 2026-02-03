{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        opacity = 0.92;
        padding = {
          x = 10;
          y = 10;
        };
        dynamic_padding = true;
      };

      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size = 11.0;
      };

      cursor = {
        style = "Beam";
        unfocused_hollow = true;
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      selection = {
        save_to_clipboard = true;
      };

      colors = {
        primary = {
          background = "0x0b0f14";
          foreground = "0xcdd6f4";
        };
      };
    };
  };
}
