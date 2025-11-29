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

  home.stateVersion = "25.05";

  programs.bash = {
    enable = true;
    initExtra = "eval \"$(direnv hook bash)\"";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.alacritty = {
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

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
          IdentityAgent ${onePassPath}
    '';
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

  programs.git = {
    enable = true;
    lfs.enable = true;
    package = pkgs.git.override { withLibsecret = true; };
    extraConfig = {
      credential.helper = "libsecret";
      "gpg \"ssh\"" = {
        program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
    };
  };

  home.pointerCursor = {
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

  home.packages = with pkgs; [
    ripgrep
    fzf
    lazygit
    gh

    xclip
    wl-clipboard
  ];

  home.sessionPath = [ "$HOME/.local/bin" ];
}
