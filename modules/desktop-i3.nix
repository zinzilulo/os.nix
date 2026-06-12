{ ... }:

{
  services = {
    libinput.enable = true;

    xserver = {
      enable = true;

      displayManager.startx.enable = true;

      windowManager.i3 = {
        enable = true;
      };

      xkb = {
        layout = "us";
        variant = "mac";
      };
    };
  };
}
