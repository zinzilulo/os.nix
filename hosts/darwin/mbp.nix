{
  lib,
  pkgs,
  self,
  userName,
  hostName,
  home-manager,
  direnv-instant,
  ...
}:

{
  imports = [
    ./brew.mbp.nix
    home-manager.darwinModules.home-manager
  ];

  networking.hostName = hostName;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget

    neovim
    emacs

    tmux
    fastfetch
    btop
    macmon
  ];

  nix = {
    enable = true;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs = {
    hostPlatform = "aarch64-darwin";

    overlays = [
      (final: prev: {
        anylinuxfs = final.callPackage (self + /pkgs/anylinuxfs/package.nix) { };
        katago = final.callPackage (self + /pkgs/katago/package.nix) { };
        waifu2x-ncnn-vulkan = final.callPackage (self + /pkgs/waifu2x-ncnn-vulkan/package.nix) { };
        portal-stillalive-rust = final.callPackage (self + /pkgs/still-alive/package.nix) { };
      })
    ];

    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "google-chrome"
      ];
  };

  programs.zsh = {
    enable = true;
    promptInit = ''
      PS1="%n@%m %1~ %# "
    '';
    loginShellInit = builtins.readFile ./apple-zprofile;
    interactiveShellInit = builtins.readFile ./apple-zshrc;
  };

  programs.bash = {
    enable = true;
    interactiveShellInit = builtins.readFile ./apple-bashrc;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  users.users.${userName} = {
    home = "/Users/${userName}";
  };

  system = {
    primaryUser = userName;

    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = { inherit direnv-instant; };

    users.${userName} = import ../../users/darwin.hm.nix;
  };
}
