{
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
      };
    };

    git = {
      enable = true;
      lfs.enable = true;
      package = pkgs.git.override { withLibsecret = true; };
      settings = {
        credential.helper = "libsecret";
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

  home = {
    packages = with pkgs; [
      ripgrep
      fd
      fzf
      lazygit
      gh
    ];

    sessionPath = [ "$HOME/.local/bin" ];

    stateVersion = "26.05";
  };
}
