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

      # 🔕 Disable terminal bell (no flash / beep)
      bell = {
        animation = "Linear";
        duration = 0;
      };

      # 📋 Clipboard keybinds
      keyboard.bindings = [
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }
      ];

      # 🖱️ Mouse behaviour
      mouse = {
        hide_when_typing = true;
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
