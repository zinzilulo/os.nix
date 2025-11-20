{ pkgs, ... }:

{
  imports = [ ./hm.nix ];

  home.stateVersion = "25.05";

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  home.packages = with pkgs; [
    ripgrep
    fzf
    lazygit
    gh

    aria2
    fio
    iperf3
    pandoc
    rsync

    llama-cpp

    ideviceinstaller
    ipatool
  ];
}
