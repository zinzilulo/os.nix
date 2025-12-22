{
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./hm.nix
  ];

  programs = {
    zsh = {
      enable = true;
      initContent = "eval \"$(direnv hook zsh)\"";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
    };
  };

  xdg = {
    enable = true;
    configFile."katago/gtp_katago.cfg".text =
      lib.replaceStrings [ "logDir = gtp_logs" ] [ "logDir = ${config.xdg.stateHome}/katago/gtp_logs" ]
        (builtins.readFile ./gtp_katago.cfg);
  };

  home = {
    stateVersion = "25.11";

    activation.katagoDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p ${lib.escapeShellArg (config.xdg.stateHome + "/katago/gtp_logs")}
    '';

    packages = with pkgs; [
      (writeShellApplication {
        name = "katago-gtp";
        runtimeInputs = [ katago ];
        text = ''
          set -eu

          MODEL_DIR="${katago}/share/katago"

          MODEL_FILE="g170-b40c256x2-s5095420928-d1229425124.bin.gz"

          PASSTHRU=()

          while [ "$#" -gt 0 ]; do
            case "$1" in
              --model)
                [ "$#" -ge 2 ] || { echo "katago-sabaki: --model requires a value (20b|40b|b18)"; exit 2; }
                case "$2" in
                  40b) MODEL_FILE="g170-b40c256x2-s5095420928-d1229425124.bin.gz" ;;
                  20b) MODEL_FILE="g170e-b20c256x2-s5303129600-d1228401921.bin.gz" ;;
                  b18) MODEL_FILE="kata1-b18c384nbt-s9996604416-d4316597426.bin.gz" ;;
                  *) echo "katago-sabaki: unknown model '$2' (use 20b|40b|b18)"; exit 2 ;;
                esac
                shift 2
                ;;

              --model-file)
                [ "$#" -ge 2 ] || { echo "katago-sabaki: --model-file requires a filename"; exit 2; }
                MODEL_FILE="$2"
                shift 2
                ;;

              *)
                PASSTHRU+=("$1")
                shift
                ;;
            esac
          done

          if printf '%s\n' "''${PASSTHRU[@]}" | grep -q -- "-config"; then
            :
          else
            PASSTHRU+=("-config" "$HOME/.config/katago/gtp_katago.cfg")
          fi

          exec katago gtp \
            -model "$MODEL_DIR/$MODEL_FILE" \
            "''${PASSTHRU[@]}"
        '';
      })

      ripgrep
      fzf
      lazygit
      gh

      aria2
      ffmpeg-full
      (pkgs.fio.override {
        withLibnbd = false;
      })
      iperf3
      pandoc
      rsync

      (pkgs.buildEnv {
        name = "ggml-org";
        paths = [
          pkgs.whisper-cpp
          pkgs.llama-cpp
        ];
        ignoreCollisions = true;
      })

      ideviceinstaller
      ipatool

      waifu2x-ncnn-vulkan
      katago
      anylinuxfs
    ];
  };
}
