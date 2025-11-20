{
  pkgs,
  ...
}:

{
  programs.sway.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];

  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
}
