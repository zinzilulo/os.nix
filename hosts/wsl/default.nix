{
  config,
  userName,
  hostName,
  home-manager,
  direnv-instant,
  nixos-pkgs,
  nixpkgs-pkgs,
  nixos-wsl,
  ...
}:

let
  sfFamily = import ../../fonts/sf-family {
    pkgs = nixpkgs-pkgs;
  };
in
{
  imports = [
    nixos-wsl.nixosModules.default
    ../../modules/unfree-accumulator.nix
    home-manager.nixosModules.home-manager
    # ../../modules/desktop-sway.nix
    # ../../modules/desktop-i3.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = userName;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  unfreePackages.packages = [
    [
      "1password"
      "1password-cli"
    ]
  ];

  services = {
    dbus.enable = true;

    printing.enable = true;

    gnome.gnome-keyring.enable = true;
  };

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs = {
    mtr.enable = true;
  };

  documentation.dev.enable = true;

  fonts = {
    enableDefaultPackages = true;

    packages =
      with nixos-pkgs;
      [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
      ]
      ++ sfFamily;

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "SF Pro Display" ];
        sansSerif = [ "SF Pro Text" ];
        monospace = [ "SF Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  environment = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      GIT_EDITOR = "nvim";
    };

    systemPackages = with nixos-pkgs; [
      man-pages
      man-pages-posix

      file
      git
      lazygit
      curl
      wget

      neovim
      emacs

      tmux
      fastfetch
      btop

      rlwrap

      fd
      ripgrep
    ];
  };

  users.users.${userName} = {
    isNormalUser = true;
    description = userName;
    extraGroups = [
      "wheel"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      direnv-instant = direnv-instant.homeModules.direnv-instant;
    };

    users.${userName} = import ../../users/wsl.hm.nix;
  };

  system.stateVersion = "26.11";
}
