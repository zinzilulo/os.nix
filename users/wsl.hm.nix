{
  lib,
  pkgs,
  direnv-instant,
  ...
}:

{
  imports = [
    direnv-instant
    ./hm.nix
  ];

  programs = {
    bash = {
      enable = true;
      initExtra = "eval \"$(direnv-instant hook bash)\"";
      shellAliases = {
        ssh = "ssh.exe";
        ssh-add = "ssh-add.exe";
      };
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
        };
      };
    };

    git = {
      enable = true;
      lfs.enable = true;
      package = pkgs.git.override { withLibsecret = true; };
      settings = {
        credential.helper = "libsecret";
        core.sshCommand = "ssh.exe";
        gpg.format = "ssh";
        "gpg \"ssh\"" = {
          program = "/mnt/c/Users/_fervor_/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe";
        };
      };
    };
  };

  home = {
    packages = with pkgs; [
      fzf
      gh

      tokei
      git-fame

      xclip
      wl-clipboard
    ];

    sessionPath = [ "$HOME/.local/bin" ];

    stateVersion = "26.11";
  };
}
