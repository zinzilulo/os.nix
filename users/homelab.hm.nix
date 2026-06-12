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

    git = {
      enable = true;
      lfs.enable = true;
      package = pkgs.git.override { withLibsecret = true; };
      settings = {
        credential.helper = "libsecret";
      };
    };
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

    stateVersion = "26.11";
  };
}
