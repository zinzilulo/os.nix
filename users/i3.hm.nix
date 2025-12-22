{ pkgs, ... }:

let
  wm = import ./wm.nix { inherit pkgs; };
in
{
  xsession.enable = true;

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = wm.mod;
      fonts = wm.commonFonts;

      terminal = "alacritty";
      menu = "dmenu_run";

      keybindings = wm.i3Keybindings;
      modes.resize = wm.resizeMode;

      bars = [
        {
          statusCommand = "i3status";
        }
      ];
    };
  };

  xresources.properties = {
    "Xft.dpi" = "192";
    "Xft.autohint" = "0";
    "Xft.lcdfilter" = "lcddefault";
    "Xft.hintstyle" = "hintfull";
    "Xft.hinting" = "1";
    "Xft.antialias" = "1";
    "Xft.rgba" = "rgb";
    "URxvt.font" = "xft:SF Mono:size=8";
  };

  home.packages = [
    pkgs.dmenu
  ];
}
