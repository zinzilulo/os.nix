{
  lib,
  fetchFromGitHub,
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
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "libkrun";
    rev = "v${version}";
    hash = "sha256-6HBSL5Zu29sDoEbZeQ6AsNIXUcqXVVGMk0AR2X6v1yU=";
  };

  patches = [
    ./no-mv.patch
  ];

  cargoHash = "sha256-UIzbtBJH6aivoIxko1Wxdod/jUN44pERX9Hd+v7TC3Q=";

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
