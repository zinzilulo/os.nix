{ ... }:

{
  services = {
    libinput.enable = true;

    displayManager.gdm.enable = true;

    xserver = {
      enable = true;

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
