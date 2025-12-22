{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  cmake,
  ninja,
  libzip,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "katago";
  version = "1.16.4";

  src = fetchFromGitHub {
    owner = "lightvector";
    repo = "KataGo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-UGj3tWQ9NiXZ5PvU/K7zA54q4+CNUZ5iOe3+heqcA4g=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
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

  preConfigure = ''
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
    export SDKROOT="$(/usr/bin/xcrun --sdk macosx --show-sdk-path)"
    export SWIFTC="$(/usr/bin/xcrun --find swiftc)"

    export CC="$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
    export CXX="$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++"
  '';

  cmakeFlags = [
    "-DNO_GIT_REVISION=1"
    "-DUSE_BACKEND=METAL"
    "-GNinja"
    "-DCMAKE_Swift_COMPILER=$SWIFTC"
  ];

  configurePhase = ''
    runHook preConfigure
    cmake -S cpp -B build ${lib.concatStringsSep " " finalAttrs.cmakeFlags}
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cmake --build build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 build/katago $out/bin/katago

    mkdir -p $out/share/katago
    cp -r cpp/configs $out/share/katago/configs

    install -m644 ${finalAttrs.b18c384nbt} $out/share/katago/kata1-b18c384nbt-s9996604416-d4316597426.bin.gz
    install -m644 ${finalAttrs.network20b} $out/share/katago/g170e-b20c256x2-s5303129600-d1228401921.bin.gz
    install -m644 ${finalAttrs.network40b} $out/share/katago/g170-b40c256x2-s5095420928-d1229425124.bin.gz

    runHook postInstall
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    ./build/katago version
    ./build/katago runtests | tail -n 1 | grep -E "All tests passed$"
    runHook postCheck
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
})
