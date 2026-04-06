{
  pkgs,
  userName,
  hostName,
  home-manager,
  direnv-instant,
  modulesPath,
  ...
}:

{
  imports = [
    ../../modules/unfree-accumulator.nix
    ./hardware-configuration.nix
    home-manager.nixosModules.home-manager
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services = {
    dbus.enable = true;

    openssh.enable = true;
  };

  security = {
    rtkit.enable = true;
  };

  time.timeZone = "Asia/Taipei";

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

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  networking = {
    inherit hostName;

    networkmanager.enable = false;

    # wireless.enable = true;

    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    firewall.enable = false;
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget

    neovim

    tmux
    fastfetch
    btop
  ];

  users.users.${userName} = {
    isNormalUser = true;
    description = userName;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "video"
      "render"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = { inherit direnv-instant; };

    users.${userName} = import ../../users/homelab.hm.nix;
  };

  system.stateVersion = "26.05";
}
