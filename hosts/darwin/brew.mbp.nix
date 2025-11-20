let
  extraTaps = [
    "nikitabobko/tap"
    "th-ch/youtube-music"
  ];

  anylinuxfsTaps = [
    "nohajc/anylinuxfs"
    "slp/krun"
  ];

  mainBrews = [
    "container"
    "katago"
  ];

  anylinuxfsBrews = [
    "anylinuxfs"
    "dtc"
    "gettext"
    "libkrun"
    "libkrunfw"
    "libunistring"
    "util-linux"
  ];

  autoUpdatedCasks = [
    "1password"
    "adguard"
    "adobe-creative-cloud"
    "altserver"
    "app-cleaner"
    "bartender"
    "betterzip"
    "chatgpt"
    "coconutbattery"
    "crossover"
    "cyberduck"
    "daisydisk"
    "discord"
    "downie"
    "drivedx"
    "google-chrome"
    "jetbrains-toolbox"
    "jordanbaird-ice@beta"
    "macs-fan-control"
    "minecraft"
    "mochi-diffusion"
    "musescore"
    "namechanger"
    "netnewswire"
    "nikitabobko/tap/aerospace"
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
    "stellarium"
    "synologyassistant"
  ];

  actuallyAutoUpdatedCasks = [
    "dictionaries"
    "mp3tag"
    "rustdesk"
    "sabaki"
    "shutter-encoder"
  ];
in
{
  homebrew = {
    enable = true;

    onActivation.cleanup = "zap";

    taps = extraTaps ++ anylinuxfsTaps;

    brews = mainBrews ++ anylinuxfsBrews;

    casks = autoUpdatedCasks ++ notAutoUpdatedCasks ++ actuallyAutoUpdatedCasks;
  };
}
