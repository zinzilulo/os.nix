{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  swift,
  cmake,
  ninja,
  libzip,
  pkg-config,
  protobuf,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "katago";
  version = "1.16.5";

  src = fetchFromGitHub {
    owner = "lightvector";
    repo = "KataGo";
    rev = "v${version}";
    hash = "sha256-+s4JO6+UMyeSHUqyRFEhJD2kmsdhcydanFWjTqxC1Tc=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    swift
    pkg-config
  ];

  buildInputs = [
    protobuf
    libzip
    zlib
  ];

  b18c384nbt = fetchurl {
    url = "https://media.katagotraining.org/uploaded/networks/models/kata1/kata1-b18c384nbt-s9996604416-d4316597426.bin.gz";
    hash = "sha256-nXpq/tj/W3SJRyfhVvBPDNNgYKJIJIkgCPu24MulHx0=";
  };

  network20b = fetchurl {
    url = "https://github.com/lightvector/KataGo/releases/download/v1.4.5/g170e-b20c256x2-s5303129600-d1228401921.bin.gz";
    hash = "sha256-fIqE7Z7nN+nH50Ggi/JC1j2ze2SOf2SULzqLG1EB58I=";
  };

  network40b = fetchurl {
    url = "https://github.com/lightvector/KataGo/releases/download/v1.4.5/g170-b40c256x2-s5095420928-d1229425124.bin.gz";
    hash = "sha256-Kzp4mB0ra1+uHPiXLgG/PkjSspG8XlLvQcm2XFPVmnE=";
  };

  cmakeFlags = [
    "-DNO_GIT_REVISION=1"
    "-DUSE_BACKEND=METAL"
    "-GNinja"
  ];

  configurePhase = ''
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
    export SDKROOT="$(/usr/bin/xcrun --sdk macosx --show-sdk-path)"
    export CC="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang";
    export CXX="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++";

    cmake -S cpp -B build ${lib.concatStringsSep " " cmakeFlags}
  '';

  buildPhase = ''
    cmake --build build
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m755 build/katago $out/bin/katago

    mkdir -p $out/share/katago
    cp -r cpp/configs $out/share/katago/configs

    install -m644 ${b18c384nbt} $out/share/katago/kata1-b18c384nbt-s9996604416-d4316597426.bin.gz
    install -m644 ${network20b} $out/share/katago/g170e-b20c256x2-s5303129600-d1228401921.bin.gz
    install -m644 ${network40b} $out/share/katago/g170-b40c256x2-s5095420928-d1229425124.bin.gz
  '';

  doCheck = true;
  checkPhase = ''
    ./build/katago version
    ./build/katago runtests | tail -n 1 | grep -E "All tests passed$"
  '';

  meta = with lib; {
    description = "Neural Network Go engine with no human-provided knowledge";
    homepage = "https://github.com/lightvector/KataGo";
    license = with licenses; [
      mit
      cc0
    ];
    mainProgram = "katago";
    platforms = [ "aarch64-darwin" ];
  };
}
