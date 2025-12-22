{
  lib,
  fetchFromGitHub,
  fetchurl,
  rustPlatform,
  pkg-config,
  dtc,
  zig,
  xz,
  libkrunfw,
  virglrenderer-krunkit,
  libepoxy,
  gnumake,
}:

rustPlatform.buildRustPackage rec {
  pname = "libkrun";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "libkrun";
    rev = "943e6d9";
    hash = "sha256-ZMR6+psxA8IOidilcZxoiwiL4Npo6kBmGDt/96oTjdE=";
  };

  patches = [
    (fetchurl {
      url = "https://raw.githubusercontent.com/slp/homebrew-krun/533300d/patches/libkrun-makefile-add-cross-compilation-support.diff";
      hash = "sha256-LZjgJSVaBJjQac1+WF7P25gnfeyeIpECtch1rDAkVn0=";
    })
    ./no-mv.patch
  ];

  cargoHash = "sha256-WZDLz560Un+2P+I6y9V3RB4jiHW0NLN0X8y2TAvwFp8=";

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
    make BLK=1 NET=1 GPU=1 BUILD_INIT=0
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
}
