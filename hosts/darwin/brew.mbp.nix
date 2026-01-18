let
  taps = [
    "th-ch/youtube-music"
  ];

  autoUpdatedCasks = [
    "1password"
    "adguard"
    "altserver"
    "app-cleaner"
    "bartender"
    "betterzip"
    "coconutbattery"
    "crossover"
    "cyberduck"
    "daisydisk"
    "discord"
    "downie"
    "drivedx"
    "font-sf-mono"
    "google-chrome"
    "jordanbaird-ice@beta"
    "macs-fan-control"
    "minecraft"
    "mochi-diffusion"
    "musescore"
    "namechanger"
    "netnewswire"
    "obs"
    "obsidian"
    "osu"
    "parallels"
    "permute"
    "playcover-community"
    "sf-symbols"
    "spotify"
    "steam"
    "swish"
    "tor-browser"
    "typora"
    "vlc"
    "zotero"
  ];

  notAutoUpdatedCasks = [
    "th-ch/youtube-music/youtube-music"
    "adobe-digital-editions"
    "calibre"
    "inkscape"
    "keyboardcleantool"
    "qflipper"
    "stellarium"
    "synologyassistant"
  ];

  actuallyAutoUpdatedCasks = [
    "apparency"
    "audacity"
    "dictionaries"
    "mp3tag"
    "rustdesk"
    "sabaki"
  ];
in
{
  homebrew = {
    enable = true;

    onActivation.cleanup = "zap";

    inherit taps;

    casks = autoUpdatedCasks ++ notAutoUpdatedCasks ++ actuallyAutoUpdatedCasks;
  };
}
