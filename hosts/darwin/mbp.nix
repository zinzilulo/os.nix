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

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = userName;

  users.users.${userName} = {
    home = "/Users/${userName}";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${userName} = import ../../users/darwin.hm.nix;
  };
}
