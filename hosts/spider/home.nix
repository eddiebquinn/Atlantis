{ ... }:

{
  home.file.".config/hypr/hosts.conf".source =
    ../../modules/home/configs/hypr/hosts/spider.conf;

  home.file.".config/waybar/config.jsonc".source =
    ../../modules/home/configs/waybar/hosts/spider.jsonc;
}
