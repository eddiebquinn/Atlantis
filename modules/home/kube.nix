{ config, pkgs, ... }:
{
  programs.kubectl = {
    enable = true;
  };
}
