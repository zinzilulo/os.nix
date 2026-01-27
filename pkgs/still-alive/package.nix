{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "portal-stillalive-rust";
  version = "f9cf19e";

  src = fetchFromGitHub {
    owner = "jindongjie";
    repo = "Portal_StillAlive_Rust";
    rev = "f9cf19eaad44bf97c2614af4a61a9c51da47187b";
    hash = "sha256-t4yzH9F4dfLUjpDkvWSqyd079tdWooSwJ8TmflkvjFU=";
  };

  cargoHash = "sha256-LrOfdhiznM1Xz9emCiWLCoDP9SexlN3uaNUm4zjJusk=";

  cargoPatches = [
    ./add-Cargo.lock.patch
  ];

  postInstall = ''
    mv $out/bin/Portal_StillAlive_Rust $out/bin/still-alive
  '';

  meta = with lib; {
    description = "Simulate final terminal scene from 'Portal: Still Alive' in any terminal environment";
    homepage = "https://github.com/jindongjie/Portal_StillAlive_Rust";
    license = licenses.gpl3;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
