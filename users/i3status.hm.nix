{
  programs.i3status = {
    enable = true;
    enableDefault = false;
    general = {
      colors = true;
      interval = 1;
    };
    modules = {
      "ipv6" = {
        position = 10;
        settings = {
          format_up = "Useless Protocol: %ip";
          format_down = "E: down";
        };
      };
      "ethernet _first_" = {
        position = 20;
        settings = {
          format_up = "Leaked IP: %ip (%speed)";
          format_down = "E: down";
        };
      };
      "disk /" = {
        position = 30;
        settings = {
          format = "%avail";
        };
      };
      "cpu_usage" = {
        position = 40;
        settings = {
          format = "%usage";
        };
      };
      "memory" = {
        position = 50;
        settings = {
          format = "%used | %available";
          threshold_degraded = "1G";
          format_degraded = "MEMORY < %available";
        };
      };
      "battery all" = {
        position = 60;
      };
      "tztime local" = {
        position = 70;
        settings = {
          format = "%Y-%m-%d %H:%M:%S";
        };
      };
    };
  };
}
