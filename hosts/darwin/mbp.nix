{
  pkgs,
  self,
  system,
  userName,
  hostName,
  home-manager,
  direnv-instant,
  ...
}:

let
  nixpkgs = {
    hostPlatform = system;

    overlays = [
      (final: prev: {
        katago = final.callPackage (../../pkgs/katago/package.nix) { };
        waifu2x-ncnn-vulkan = final.callPackage (../../pkgs/waifu2x-ncnn-vulkan/package.nix) { };
        portal-stillalive-rust = final.callPackage (../../pkgs/still-alive/package.nix) { };
        lq = final.callPackage (../../pkgs/lq/package.nix) { };
      })
    ];
  };
in
{
  inherit nixpkgs;

  imports = [
    ./brew.mbp.nix
    home-manager.darwinModules.home-manager
  ];

  networking.hostName = hostName;

  environment.systemPackages = with pkgs; [
    git
    lazygit
    curl
    wget

    neovim
    emacs

    tmux
    fastfetch
    btop
    macmon

    rlwrap

    fd
    ripgrep
  ];

  nix = {
    enable = true;

    linux-builder = {
      enable = true;

      package = pkgs.darwin.linux-builder-vz;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
    };

    settings = {
      trusted-users = [ "@admin" ];

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
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

    extraSpecialArgs = {
      direnv-instant = direnv-instant.homeModules.direnv-instant;
    };

    users.${userName} = import ../../users/darwin.hm.nix;
  };
}
