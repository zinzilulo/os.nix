{ pkgs, lib, ... }:

let
  xcodeTheme = pkgs.fetchFromGitHub {
    owner = "juniorxxue";
    repo = "xcode-theme";
    rev = "654abf6c14dd3c3a65e629799b5d83d3354b598c";
    hash = "sha256-Mzh9SBV4EhQkgElVRAcg5q32wPnro5tVGGUUS0NqebE=";
  };

  inherit (pkgs.stdenv) isDarwin;
in
{
  programs = {
    tmux = {
      enable = true;
      keyMode = "vi";
      mouse = true;
      historyLimit = 50000;
      escapeTime = 0;
      focusEvents = true;
      terminal = "tmux-256color";

      plugins = with pkgs.tmuxPlugins; [
        resurrect
        {
          plugin = continuum;
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on'
            set -g @continuum-save-interval '5'
            set -g @continuum-restore 'on'
          '';
        }
      ];

      extraConfig = ''
        set -g status-keys vi
      '';
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };

    emacs = {
      enable = true;

      extraPackages =
        epkgs: with epkgs; [
          evil
        ];

      extraConfig = ''
        (tool-bar-mode -1)
        ${lib.optionalString (!isDarwin) ''
          (menu-bar-mode -1)
        ''}
        (scroll-bar-mode -1)
        (set-frame-font "SF Mono 12" nil t)

        (require 'cl-lib)
        (add-to-list 'load-path "${xcodeTheme}")

        (condition-case err
            (progn
              (require 'xcode-dark-theme)
              (load-theme 'xcode-dark t))
          (error
           (message "Could not load xcode-dark-theme: %s" err)))

        (require 'evil)
        (evil-mode 1)
      '';
    };
  };

  xdg.configFile."nvim/init.lua".text = ''
    vim.opt.syntax = "enable"
    vim.opt.cursorline = true
    vim.opt.relativenumber = true
    vim.opt.number = true
    vim.opt.modeline = true
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.autoindent = true
    vim.opt.autochdir = true
    vim.opt.clipboard = "unnamedplus"

    vim.keymap.set("v", ">", ">gv", { noremap = true })
    vim.keymap.set("v", "<", "<gv", { noremap = true })
  '';

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
