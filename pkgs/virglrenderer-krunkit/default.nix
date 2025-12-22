{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  python3,
  libepoxy,
  moltenvk,
  vulkan-headers,
}:

stdenv.mkDerivation rec {
  pname = "virglrenderer-krunkit";
  version = "0.10.4e-krunkit";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "slp";
    repo = "virglrenderer";
    rev = version;
    hash = "sha256-+c7HxTCd5rRSlCAJ1KobyVvZJ2Fp71l4PzMItTGH4G8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    libepoxy
    moltenvk
    vulkan-headers
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail \
        "libdrm_dep = dependency('libdrm', version : '>=2.4.50', required: get_option('drm').enabled())" \
        "libdrm_dep = dependency('libdrm', version : '>=2.4.50', required: (get_option('drm').enabled() and host_machine.system() != 'darwin'))"
  '';

  mesonFlags = [
    "-Dvenus=true"
    "-Drender-server=false"
  ];

  meta = with lib; {
    description = "VirGL virtual OpenGL renderer";
    homepage = "https://gitlab.freedesktop.org/slp/virglrenderer";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
