{
  lib,
  pkgs,
  direnv-instant,
  ...
}:

{
  imports = [
    direnv-instant.homeModules.direnv-instant

    ./hm.nix
    ./sway.hm.nix
    ./i3.hm.nix
    ./i3status.hm.nix
  ];

  xresources.properties."Xft.dpi" = "192";
  wayland.windowManager.sway.config.output."Virtual-1".scale = "2";

  programs = {
    bash = {
      enable = true;
      initExtra = "eval \"$(direnv-instant hook bash)\"";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    direnv-instant.enable = true;

    alacritty = {
      enable = true;
      settings = {
        font = {
          normal.family = "SF Mono";
          bold.family = "SF Mono";
          italic.family = "SF Mono";
          size = 11.0;
        };
        terminal.shell.program = "bash";
      };
    };

    kitty = {
      enable = true;
      font = {
        name = "SF Mono";
        size = 11.0;
      };
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          ForwardAgent = false;
          AddKeysToAgent = "no";
          IdentityAgent = "~/.1password/agent.sock";
        };
      };
    };

    git = {
      enable = true;
      lfs.enable = true;
      package = pkgs.git.override { withLibsecret = true; };
      settings = {
        credential.helper = "libsecret";
        "gpg \"ssh\"" = {
          program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
        };
      };
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  home = {
    file.".background-image".source = ../wallpapers;

    pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
      gtk.enable = true;
      sway.enable = true;
    };

    packages = with pkgs; [
      ripgrep
      fd
      fzf
      lazygit
      gh

      cloc
      git-fame

      xclip
      wl-clipboard
    ];

    sessionPath = [ "$HOME/.local/bin" ];

    stateVersion = "26.11";
  };
}
