{ pkgs, ... }:

let
  wm = import ./wm.nix { inherit pkgs; };
in
{
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = wm.mod;
      fonts = wm.commonFonts;

      output."Virtual-1".scale = "2";

      terminal = "alacritty";
      menu = "bemenu-run --prompt ''";
      floating.modifier = wm.mod;

      keybindings = wm.swayKeybindings;

      modes.resize = wm.resizeMode;

      bars = [
        {
          statusCommand = "i3status";
        }
      ];
    };
  };

  programs.bemenu.enable = true;
}
