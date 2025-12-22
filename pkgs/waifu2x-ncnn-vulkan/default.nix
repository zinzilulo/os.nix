{
  lib,
  fetchFromGitHub,
  cmake,
  ninja,
  makeWrapper,
  vulkan-headers,
  moltenvk,
  llvmPackages,
}:

llvmPackages.stdenv.mkDerivation rec {
  pname = "waifu2x-ncnn-vulkan";
  version = "20250915";

  src = fetchFromGitHub {
    owner = "nihui";
    repo = "waifu2x-ncnn-vulkan";
    rev = "a86cfb0";
    hash = "sha256-V1ZeLNjt5VZGVfhkaHMYd1Np9FYs15W4pby2QFgKyv8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    makeWrapper
  ];

  buildInputs = [
    vulkan-headers
    moltenvk
    llvmPackages.openmp
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DVulkan_LIBRARY=${moltenvk}/lib/libMoltenVK.dylib"
    "-DUSE_STATIC_MOLTENVK=ON"
  ];

  configurePhase = ''
    runHook preConfigure
    cmake -S src -B build ${lib.concatStringsSep " " cmakeFlags}
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cmake --build build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cmake --install build --prefix $out

    install -D -m 0755 build/waifu2x-ncnn-vulkan \
      $out/bin/waifu2x-ncnn-vulkan

    for dir in models/*; do
      [ -d "$dir" ] && cp -R "$dir" "$out/bin/"
    done

    wrapProgram $out/bin/waifu2x-ncnn-vulkan \
      --set-default VK_ICD_FILENAMES "" \
      --prefix DYLD_LIBRARY_PATH : "${moltenvk}/lib:${llvmPackages.openmp}/lib"

    runHook postInstall
  '';

  postFixup = ''
    install_name_tool -add_rpath ${moltenvk}/lib \
      $out/bin/waifu2x-ncnn-vulkan 2>/dev/null || true
    install_name_tool -add_rpath ${llvmPackages.openmp}/lib \
      $out/bin/waifu2x-ncnn-vulkan 2>/dev/null || true
  '';

  meta = with lib; {
    description = "waifu2x upscaler using ncnn + Vulkan (MoltenVK on macOS)";
    homepage = "https://github.com/nihui/waifu2x-ncnn-vulkan";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "waifu2x-ncnn-vulkan";
  };
}
