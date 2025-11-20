{
  config,
  pkgs,
  self,
  userName,
  hostName,
  home-manager,
  ...
}:

let
  sfFamily = import ../../fonts/sf-family {
    inherit pkgs self;
  };
in
{
  imports = [
    ./hardware-configuration.nix
    home-manager.nixosModules.home-manager
    ../../modules/desktop-gnome.nix
    ../../modules/desktop-sway.nix
    ../../modules/desktop-i3.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = hostName;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;

  services.dbus.enable = true;
  security.polkit.enable = true;

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

  programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;

  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # services.openssh.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
    # media-session.enable = true;
  };

  services.printing.enable = true;

  fonts = {
    enableDefaultPackages = true;

    packages =
      with pkgs;
      [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
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

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ userName ];
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    wget

    neovim
    emacs

    tmux
    fastfetch
    btop

    firefox
  ];

  users.users.${userName} = {
    isNormalUser = true;
    description = userName;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${userName} = import ../../users/nixos.hm.nix;
  };

  system.stateVersion = "25.05";
}
