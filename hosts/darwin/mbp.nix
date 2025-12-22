{
  pkgs,
  self,
  userName,
  hostName,
  home-manager,
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

  nixpkgs.overlays = [
    (final: prev: {
      virglrenderer-krunkit = final.callPackage (self + /pkgs/virglrenderer-krunkit/default.nix) { };
      libkrunfw = final.callPackage (self + /pkgs/libkrunfw/default.nix) { };
      libkrun = final.callPackage (self + /pkgs/libkrun/default.nix) { };
      anylinuxfs = final.callPackage (self + /pkgs/anylinuxfs/default.nix) { };
      katago = final.callPackage (self + /pkgs/katago/default.nix) { };
      waifu2x-ncnn-vulkan = final.callPackage (self + /pkgs/waifu2x-ncnn-vulkan/default.nix) { };
    })
  ];

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

  nixpkgs.hostPlatform = "aarch64-darwin";

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

    users.${userName} = import ../../users/darwin.hm.nix;
  };
}
