{
  lib,
  pkgs,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  rustPlatform,
  buildGoModule,
  pkg-config,
  libkrun,
  util-linux,
  gvproxy,
  pkgsCross,
}:

let
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "nohajc";
    repo = "anylinuxfs";
    rev = "f9b09a5";
    hash = "sha256-vz3c58wsz8mFjH52OZPia9GX6xTtZaSicrDxjTGKpmQ=";
  };

  linuxImage = fetchurl {
    url = "https://github.com/nohajc/libkrunfw/releases/download/v6.12.34-rev4/linux-aarch64-Image-v6.12.34-anylinuxfs.tar.gz";
    hash = "sha256-TF0NIBQZFcXO+dbd3NsGbTTmqMnTN+f6Cev0sOgtFPw=";
  };

  linuxModules = fetchurl {
    url = "https://github.com/nohajc/libkrunfw/releases/download/v6.12.34-rev4/modules.squashfs";
    hash = "sha256-iak4kjCgB9RdoaYqjWW7axFihN3foA0pNEVRMRP2ego=";
  };

  anylinuxfsBin = rustPlatform.buildRustPackage {
    pname = "anylinuxfs-bin";
    inherit version src;

    postUnpack = ''
      cd "$sourceRoot/anylinuxfs"
      sourceRoot="$PWD"
    '';

    cargoHash = "sha256-7lxZoojWoHT6/T4/TyDpHiAzis25swsI7/awz6xi1xU=";

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [
      libkrun
      util-linux
    ];

    doCheck = false;
  };

  vmproxyBin = pkgsCross.aarch64-multiplatform-musl.rustPlatform.buildRustPackage {
    pname = "vmproxy";
    inherit version src;

    postUnpack = ''
      cd "$sourceRoot/vmproxy"
      sourceRoot="$PWD"
    '';

    preBuild = ''
      mkdir -p .cargo
      cat > .cargo/config.toml <<EOF
      [source.crates-io]
      replace-with = "vendored-sources"

      [source.vendored-sources]
      directory = "$(pwd)/vmproxy-${version}-vendor"
      EOF
    '';

    cargoHash = "sha256-dfhCUWUZYom30XbYqtiwwwS/bp3V+O10MYH2HunVvrI=";

    CARGO_ENCODED_RUSTFLAGS = "-Ctarget-feature=+crt-static";
    RUSTFLAGS = "-C target-feature=+crt-static";

    doCheck = false;
  };

  initRootfsBin = buildGoModule {
    pname = "init-rootfs";
    inherit version src;

    modRoot = "init-rootfs";
    subPackages = [ "." ];

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ libkrun ];

    env.NIX_CFLAGS_COMPILE = "-I${libkrun}/include";
    env.NIX_LDFLAGS = "-L${libkrun}/lib -lkrun";

    vendorHash = "sha256-pnVetun00Nwb7+W0g6PgoO5+Yju5UpTlbVqNfHW33rA=";

    tags = [ "containers_image_openpgp" ];
    ldflags = [
      "-w"
      "-s"
    ];

    doCheck = false;
  };

in
stdenv.mkDerivation {
  pname = "anylinuxfs";
  inherit version src;

  dontBuild = true;

  nativeBuildInputs = [
    pkgs.darwin.cctools
    pkgs.makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec $out/etc $out/share $out/lib

    install -m 0755 ${anylinuxfsBin}/bin/anylinuxfs $out/bin/anylinuxfs
    install -m 0644 etc/anylinuxfs.toml $out/etc/anylinuxfs.toml

    install -m 0755 ${initRootfsBin}/bin/init-rootfs $out/libexec/init-rootfs
    install -m 0755 ${gvproxy}/bin/gvproxy $out/libexec/gvproxy
    install -m 0755 ${vmproxyBin}/bin/vmproxy $out/libexec/vmproxy
    ln -s libexec/vmproxy $out/vmproxy

    install -m 0644 anylinuxfs.entitlements $out/share/anylinuxfs.entitlements

    install -m 0644 ${linuxModules} $out/lib/modules.squashfs

    tmp="$(mktemp -d)"
    mkdir -p "$tmp/linux-image"
    tar -xzf ${linuxImage} -C "$tmp/linux-image"
    install -m 0644 "$tmp/linux-image/Image" $out/libexec/Image

    wrapProgram $out/bin/anylinuxfs \
      --prefix PATH : $out/libexec

    runHook postInstall
  '';

  postFixup = ''
    ent="$out/share/anylinuxfs.entitlements"

    fix_macho() {
      local bin="$1"
      if [ -f "$bin" ] && file "$bin" | grep -q 'Mach-O'; then
        install_name_tool -add_rpath ${libkrun}/lib "$bin" || true
        install_name_tool -change libkrun.1.dylib @rpath/libkrun.1.dylib "$bin" || true
        install_name_tool -change libkrun.dylib   @rpath/libkrun.dylib   "$bin" || true
      fi
    }

    fix_macho "$out/bin/.anylinuxfs-wrapped"
    fix_macho "$out/bin/anylinuxfs"
    fix_macho "$out/libexec/init-rootfs"

    /usr/bin/codesign --force -s - --entitlements "$ent" "$out/bin/.anylinuxfs-wrapped" || true
    /usr/bin/codesign --force -s - --entitlements "$ent" "$out/bin/anylinuxfs"
    /usr/bin/codesign --force -s - --entitlements "$ent" "$out/libexec/init-rootfs"
  '';

  meta = with lib; {
    description = "Mount any linux-supported filesystem read/write using nfs and a microVM";
    homepage = "https://github.com/nohajc/anylinuxfs";
    license = licenses.gpl3Plus;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "anylinuxfs";
  };
}
