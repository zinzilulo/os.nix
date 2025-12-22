{
  lib,
  pkgs,
  ...
}:

let
  onePassPath = "~/.1password/agent.sock";
in
{
  imports = [
    ./hm.nix
    ./sway.hm.nix
    ./i3.hm.nix
    ./i3status.hm.nix
  ];

  programs = {
    bash = {
      enable = true;
      initExtra = "eval \"$(direnv hook bash)\"";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

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

    ssh = {
      enable = true;

      enableDefaultConfig = false;

      matchBlocks."*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";

        identityAgent = onePassPath;
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

  services.gnome-keyring = {
    enable = true;
    components = [
      "secrets"
      "ssh"
      "pkcs11"
    ];
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
      fzf
      lazygit
      gh

      xclip
      wl-clipboard
    ];

    sessionPath = [ "$HOME/.local/bin" ];

    stateVersion = "25.11";
  };
}
