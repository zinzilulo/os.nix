{ pkgs, ... }:

{
  services = {
    libinput.enable = true;

    xserver = {
      enable = true;

      displayManager.gdm.enable = true;

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };

      xkb = {
        layout = "us";
        variant = "mac";
      };
    };
  };
}
