{ pkgs, lib, ... }:

let
  xcodeTheme = pkgs.fetchFromGitHub {
    owner = "juniorxxue";
    repo = "xcode-theme";
    rev = "654abf6c14dd3c3a65e629799b5d83d3354b598c";
    hash = "sha256-Mzh9SBV4EhQkgElVRAcg5q32wPnro5tVGGUUS0NqebE=";
  };

  inherit (pkgs) stdenv;
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

      plugins = with pkgs.vimPlugins; [
        fzf-lua
        lean-nvim
      ];

      extraPackages = with pkgs; [
        fd
        fzf
        ripgrep
      ];

      initLua = ''
        vim.g.mapleader = " "

        vim.opt.syntax = "enable"
        vim.opt.cursorline = true
        vim.opt.relativenumber = true
        vim.opt.modeline = true
        vim.opt.expandtab = true
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.autoindent = true
        vim.opt.smartindent = true
        vim.opt.ignorecase = true
        vim.opt.smartcase = true
        vim.opt.clipboard = "unnamedplus"

        vim.keymap.set("v", ">", ">gv", { noremap = true })
        vim.keymap.set("v", "<", "<gv", { noremap = true })

        require("fzf-lua").setup({
          fzf_colors = true,
        })

        vim.keymap.set("n", "<leader>ff", function()
          require("fzf-lua").files()
        end, { desc = "Find files" })

        vim.keymap.set("n", "<leader>fg", function()
          require("fzf-lua").live_grep()
        end, { desc = "Live grep" })

        vim.keymap.set("n", "<leader>fb", function()
          require("fzf-lua").buffers()
        end, { desc = "Find buffers" })

        vim.keymap.set("n", "<leader>fh", function()
          require("fzf-lua").help_tags()
        end, { desc = "Help tags" })

        require("lean").setup({
          mappings = true,
        })
      '';
    };

    emacs = {
      enable = true;

      extraConfig = ''
        (tool-bar-mode -1)
        ${lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
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
      '';
    };
  };
}
