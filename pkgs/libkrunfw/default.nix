{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "libkrunfw";
  version = "4.10.0";

  src = fetchurl {
    url = "https://github.com/containers/libkrunfw/releases/download/v${version}/libkrunfw-${version}-prebuilt-aarch64.tar.gz";
    hash = "sha256-ZzLgQkzpD6JGpKdbtfM1eog1RtvKCV/uB6fVh+gtlLA=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R ./* $out/
    runHook postInstall
  '';

  meta = with lib; {
    description = "A dynamic library bundling the guest payload consumed by libkrun";
    homepage = "https://github.com/containers/libkrunfw";
    license = with licenses; [
      gpl2Only
      lgpl21Only
    ];
    platforms = [ "aarch64-darwin" ];
  };
}
