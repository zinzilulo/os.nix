let
  brews = [
    "container"
  ];

  autoUpdatedCasks = [
    "1password"
    "app-cleaner"
    "betterzip"
    "coconutbattery"
    "crossover"
    "daisydisk"
    "discord"
    "downie"
    "drivedx"
    "font-sf-mono"
    "macs-fan-control"
    "minecraft"
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
    "adobe-digital-editions"
    "apparency"
    "calibre"
    "inkscape"
    "keyboardcleantool"
    "qflipper"
    "stellarium"
  ];

  actuallyAutoUpdatedCasks = [
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

    onActivation.cleanup = "check";

    inherit brews;

    casks = autoUpdatedCasks ++ notAutoUpdatedCasks ++ actuallyAutoUpdatedCasks;
  };
}
