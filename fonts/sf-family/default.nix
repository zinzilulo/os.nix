{ pkgs, self }:

let
  sfFontNames = [
    "New-York"
    "SF-Camera"
    "SF-Cash"
    "SF-Compact"
    "SF-Compact-Rounded"
    "SF-Condensed"
    "SF-Hello"
    "SF-Mono"
    "SF-Pro"
    "SF-Rounded"
    "SF-Serif"
    "SF-Shields"
  ];

  mkSfFont =
    name:
    pkgs.stdenvNoCC.mkDerivation {
      pname = name;
      version = "1.0";
      src = self + "/fonts/sf-family/${name}.tar.gz";
      dontBuild = true;
      installPhase = ''
        mkdir -p "$out/share/fonts/${name}"
        cp -r . "$out/share/fonts/${name}/"
      '';
    };
in
map mkSfFont sfFontNames
