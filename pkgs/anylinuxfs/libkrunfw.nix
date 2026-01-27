{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "libkrunfw";
  version = "5.1.0";

  src = fetchurl {
    url = "https://github.com/containers/libkrunfw/releases/download/v${version}/libkrunfw-prebuilt-aarch64.tgz";
    hash = "sha256-6MMMEoLl8pBMuvGc974RGE2NxImp8k6EUQIkV+pwvjo=";
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
