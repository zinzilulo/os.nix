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

  libkrunfw = stdenvNoCC.mkDerivation rec {
    pname = "libkrunfw";
    version = "5.2.0";

    src = fetchurl {
      url = "https://github.com/containers/libkrunfw/releases/download/v${version}/libkrunfw-prebuilt-aarch64.tgz";
      hash = "sha256-zIKvO1Og4r7iHJoznLosaCwl6UZZEEgP+OZ48Tw55Uw=";
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
  };

  libkrun = rustPlatform.buildRustPackage rec {
    pname = "libkrun";
    version = "1.17.4";

    src = fetchFromGitHub {
      owner = "containers";
      repo = "libkrun";
      rev = "v${version}";
      hash = "sha256-Th4vCg3xHb6lbo26IDZES7tLOUAJTebQK2+h3xSYX7U=";
    };

    patches = [
      ./no-mv.patch
    ];

    cargoHash = "sha256-0xpAyNe1jF1OMtc7FXMsejqIv0xKc1ktEvm3rj/mVFU=";

    dontCargoBuild = true;

    strictDeps = true;

    nativeBuildInputs = [
      pkg-config
      dtc
      zig
      gnumake
    ];

    buildInputs = [
      xz
      libkrunfw
      virglrenderer-krunkit
      libepoxy
    ];

    doCheck = false;

    preBuild = ''
      tmp="$(mktemp -d)"
      export HOME="$tmp"
      export CARGO_HOME="$tmp/.cargo"
      export XDG_CACHE_HOME="$tmp/.cache"
      export ZIG_GLOBAL_CACHE_DIR="$tmp/zig-global-cache"
      export ZIG_LOCAL_CACHE_DIR="$tmp/zig-local-cache"

      export CARGO_NET_OFFLINE=true
      export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

      mkdir -p "$CARGO_HOME" "$XDG_CACHE_HOME" \
               "$ZIG_GLOBAL_CACHE_DIR" "$ZIG_LOCAL_CACHE_DIR"

      mkdir -p init
      zig cc -target aarch64-linux-musl -O2 -static -Wall \
        -o init/init init/init.c
      chmod +x init/init
    '';

    buildPhase = ''
      runHook preBuild
      make BLK=1 NET=1 GPU=1 TIMESYNC=1 BUILD_INIT=0
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      make PREFIX=$out BUILD_INIT=0 install
      runHook postInstall
    '';

    meta = with lib; {
      description = "A dynamic library providing Virtualization-based process isolation capabilities";
      homepage = "https://github.com/containers/libkrun";
      license = licenses.asl20;
      platforms = [ "aarch64-darwin" ];
    };
  };

  version = "0.12.2";

  src = fetchFromGitHub {
    owner = "nohajc";
    repo = "anylinuxfs";
    rev = "v${version}";
    hash = "sha256-j59Pg14+TNYAJNtZjV3oymv+ZwWOSuviREftaIa1G0g=";
  };

  linuxImage = fetchurl {
    url = "https://github.com/nohajc/libkrunfw/releases/download/v6.12.62-rev1/linux-aarch64-Images-v6.12.62-anylinuxfs.tar.gz";
    hash = "sha256-HedaPU7y7M1B3xDy6shDXbq6UjcfpCsLA4T9nPmh884=";
  };

  linuxModules = fetchurl {
    url = "https://github.com/nohajc/libkrunfw/releases/download/v6.12.62-rev1/modules.squashfs";
    hash = "sha256-hu1IXk5GuiZSYaVeJckuoV9hGAA/zslai6/eitOfaX8=";
  };

  vmnetHelper = fetchurl {
    url = "https://github.com/nirs/vmnet-helper/releases/download/v0.9.0/vmnet-helper.tar.gz";
    hash = "sha256-XHZBNCignORfr3Gff7L2IemzoLEDAkg3rs24MZzc8yw=";
  };

  anylinuxfsBin = rustPlatform.buildRustPackage {
    pname = "anylinuxfs-bin";
    inherit version src;

    postUnpack = ''
      cd "$sourceRoot/anylinuxfs"
      sourceRoot="$PWD"
    '';

    cargoHash = "sha256-bHM2JyL5aswoNUQrlVh0gr77+PjFP8NF7M4Kbmexwug=";

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

    cargoHash = "sha256-91lNC1pBW7y/l49lWU9iYEAbYCm4G3/tVr+YSAPEPQA=";

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

    vendorHash = "sha256-qBxmsoJP2AYnbW6hGu+3roANqmLeodAR1HSMA++3hAc=";

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

    mkdir -p $out/bin $out/libexec $out/etc $out/share $out/lib $out/share/alpine

    install -m 0755 ${anylinuxfsBin}/bin/anylinuxfs $out/bin/anylinuxfs
    install -m 0644 etc/anylinuxfs.toml $out/etc/anylinuxfs.toml
    install -m 0644 share/alpine/rootfs.ver $out/share/alpine/rootfs.ver

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
    install -m 0644 "$tmp/linux-image/Image-4K" $out/libexec/Image-4K

    mkdir -p "$tmp/vmnetHelper"
    tar -xzf ${vmnetHelper} -C "$tmp/vmnetHelper"
    install -m 0755 "$tmp/vmnetHelper/opt/vmnet-helper/bin/vmnet-helper" $out/libexec/vmnet-helper

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
