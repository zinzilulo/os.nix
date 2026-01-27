{
  lib,
  pkgs,
  cctools,
  makeWrapper,
  stdenv,
  stdenvNoCC,
  fetchFromGitLab,
  fetchFromGitHub,
  fetchurl,
  rustPlatform,
  buildGoModule,
  pkg-config,
  util-linux,
  gvproxy,
  moltenvk,
  pkgsCross,
  dtc,
  zig,
  xz,
  libepoxy,
  gnumake,
}:

let
  virglrenderer-krunkit =
    (pkgs.virglrenderer.override {
      vulkanSupport = true;
    }).overrideAttrs
      (old: {
        pname = "virglrenderer";
        version = "0.10.4e-krunkit";

        src = fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "slp";
          repo = "virglrenderer";
          rev = "0.10.4e-krunkit";
          hash = "sha256-+c7HxTCd5rRSlCAJ1KobyVvZJ2Fp71l4PzMItTGH4G8=";
        };

        buildInputs = (old.buildInputs or [ ]) ++ [
          moltenvk
        ];

        postPatch = (old.postPatch or "") + ''
          substituteInPlace meson.build \
            --replace-fail \
              "libdrm_dep = dependency('libdrm', version : '>=2.4.50', required: get_option('drm').enabled())" \
              "libdrm_dep = dependency('libdrm', version : '>=2.4.50', required: (get_option('drm').enabled() and host_machine.system() != 'darwin'))"
        '';

        mesonFlags = [
          "-Dvenus=true"
          "-Drender-server=false"
        ];

        meta = old.meta // {
          platforms = [ "aarch64-darwin" ];
        };
      });

  libkrunfw = import ./libkrunfw.nix {
    inherit lib stdenvNoCC fetchurl;
  };
  libkrun = import ./libkrun.nix {
    inherit
      lib
      fetchFromGitHub
      rustPlatform
      pkg-config
      dtc
      zig
      xz
      libkrunfw
      virglrenderer-krunkit
      libepoxy
      gnumake
      ;
  };

  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "nohajc";
    repo = "anylinuxfs";
    rev = "v${version}";
    hash = "sha256-BpHEVg0Kjnckybgngif2Z8g+RimkyjowVFM3xhDtnkM=";
  };

  linuxImage = fetchurl {
    url = "https://github.com/nohajc/libkrunfw/releases/download/v6.12.62-rev1/linux-aarch64-Image-v6.12.62-anylinuxfs.tar.gz";
    hash = "sha256-2uN8qJR1grPgzcnv28LeX1RvmJ0a5NYhu8NOkM9BIAE=";
  };

  linuxModules = fetchurl {
    url = "https://github.com/nohajc/libkrunfw/releases/download/v6.12.62-rev1/modules.squashfs";
    hash = "sha256-hu1IXk5GuiZSYaVeJckuoV9hGAA/zslai6/eitOfaX8=";
  };

  anylinuxfsBin = rustPlatform.buildRustPackage {
    pname = "anylinuxfs-bin";
    inherit version src;

    postUnpack = ''
      cd "$sourceRoot/anylinuxfs"
      sourceRoot="$PWD"
    '';

    cargoHash = "sha256-KH5i24r9CTNkLebaOZzw9gagtGVKS8H0i3zj7r4KcJI=";

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

    cargoHash = "sha256-BByBLs1ft7b5bBtUGzcL+xYj2/kO9FWsvRHQ8g03KDA=";

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
    cctools
    makeWrapper
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
