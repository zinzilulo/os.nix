let
  taps = [
    "th-ch/youtube-music"
  ];

  brews = [
    "container"
  ];

  autoUpdatedCasks = [
    "1password"
    "adguard"
    "adobe-creative-cloud"
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
    "jetbrains-toolbox"
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
    "keyboardcleantool"
    "qflipper"
    "stellarium"
    "synologyassistant"
  ];

  actuallyAutoUpdatedCasks = [
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

    inherit taps brews;

    casks = autoUpdatedCasks ++ notAutoUpdatedCasks ++ actuallyAutoUpdatedCasks;
  };
}
