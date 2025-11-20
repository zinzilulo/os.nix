_:

let
  mod = "Mod1";

  commonFonts = {
    names = [ "SF Mono" ];
    size = 8.0;
  };

  commonKeybindings = {
    "${mod}+Return" = "exec alacritty";
    "${mod}+Shift+q" = "kill";

    "${mod}+j" = "focus left";
    "${mod}+k" = "focus down";
    "${mod}+l" = "focus up";
    "${mod}+semicolon" = "focus right";
    "${mod}+Left" = "focus left";
    "${mod}+Down" = "focus down";
    "${mod}+Up" = "focus up";
    "${mod}+Right" = "focus right";

    "${mod}+Shift+j" = "move left";
    "${mod}+Shift+k" = "move down";
    "${mod}+Shift+l" = "move up";
    "${mod}+Shift+semicolon" = "move right";
    "${mod}+Shift+Left" = "move left";
    "${mod}+Shift+Down" = "move down";
    "${mod}+Shift+Up" = "move up";
    "${mod}+Shift+Right" = "move right";

    "${mod}+h" = "split h";
    "${mod}+v" = "split v";
    "${mod}+f" = "fullscreen toggle";
    "${mod}+s" = "layout stacking";
    "${mod}+w" = "layout tabbed";
    "${mod}+e" = "layout toggle split";
    "${mod}+Shift+space" = "floating toggle";
    "${mod}+space" = "focus mode_toggle";
    "${mod}+a" = "focus parent";

    "${mod}+1" = "workspace number 1";
    "${mod}+2" = "workspace number 2";
    "${mod}+3" = "workspace number 3";
    "${mod}+4" = "workspace number 4";
    "${mod}+5" = "workspace number 5";
    "${mod}+6" = "workspace number 6";
    "${mod}+7" = "workspace number 7";
    "${mod}+8" = "workspace number 8";
    "${mod}+9" = "workspace number 9";
    "${mod}+0" = "workspace number 10";

    "${mod}+Shift+1" = "move container to workspace number 1";
    "${mod}+Shift+2" = "move container to workspace number 2";
    "${mod}+Shift+3" = "move container to workspace number 3";
    "${mod}+Shift+4" = "move container to workspace number 4";
    "${mod}+Shift+5" = "move container to workspace number 5";
    "${mod}+Shift+6" = "move container to workspace number 6";
    "${mod}+Shift+7" = "move container to workspace number 7";
    "${mod}+Shift+8" = "move container to workspace number 8";
    "${mod}+Shift+9" = "move container to workspace number 9";
    "${mod}+Shift+0" = "move container to workspace number 10";
  };

  resizeMode = {
    "j" = "resize shrink width 10 px or 10 ppt";
    "k" = "resize grow   height 10 px or 10 ppt";
    "l" = "resize shrink height 10 px or 10 ppt";
    "semicolon" = "resize grow   width 10 px or 10 ppt";
    "Left" = "resize shrink width 10 px or 10 ppt";
    "Down" = "resize grow   height 10 px or 10 ppt";
    "Up" = "resize shrink height 10 px or 10 ppt";
    "Right" = "resize grow   width 10 px or 10 ppt";
    "Return" = ''mode "default"'';
    "Escape" = ''mode "default"'';
  };

in
{
  inherit mod commonFonts resizeMode;

  swayKeybindings = commonKeybindings // {
    "${mod}+d" = "exec bemenu-run --prompt ''";
    "${mod}+Shift+r" = "reload";
    "${mod}+Shift+e" = "exec swaymsg exit";
    "${mod}+r" = ''mode "resize"'';
  };

  i3Keybindings = commonKeybindings // {
    "${mod}+d" = "exec dmenu_run";
    "${mod}+Shift+r" = "reload";
    "${mod}+Shift+e" = "exit";
    "${mod}+r" = ''mode "resize"'';
  };
}
