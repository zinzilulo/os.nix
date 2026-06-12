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

      startup = [
        {
          # Start swaybg using a glob from ~/.background-image.
          # Works only if exactly one image is present.
          command = "${pkgs.swaybg}/bin/swaybg -i $HOME/.background-image/* -m fill";
          always = true;
        }
      ];
    };

    # Make Parallels Tools clipboard window float instead of tiling
    extraConfig = ''
      for_window [title="Parallels Shared Clipboard"] floating enable
    '';
  };

  programs.bemenu.enable = true;
}
