let
  brews = [
    "container"
  ];

  autoUpdatedCasks = [
    "1password"
    "adguard"
    "app-cleaner"
    "bartender"
    "betterzip"
    "chatgpt"
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
    "thaw"
    "tor-browser"
    "typora"
    "vlc"
    "zotero"
  ];

  notAutoUpdatedCasks = [
    "pear-devs/pear/pear-desktop"
    "adobe-digital-editions"
    "apparency"
    "calibre"
    "inkscape"
    "keyboardcleantool"
    "qflipper"
    "stellarium"
    "synologyassistant"
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
