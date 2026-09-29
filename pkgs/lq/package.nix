{
  lib,
  pkgs,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "lq";
  version = "e9d503c";

  src = fetchFromGitHub {
    owner = "clux";
    repo = "lq";
    rev = "e9d503ce0ee0d8387420731b865d30f510317fa9";
    hash = "sha256-0Vfrsgss2QxzT47xXi8w/bc3KGvo1AUi32afB6d9fCE=";
  };

  cargoHash = "sha256-/0TR0eugSNf8swl3awKix6rYXc6wOSwSuFkZOv34N+A=";

  nativeCheckInputs = [ pkgs.jq ];

  meta = with lib; {
    description = "jq compatible yq/tq implementation in rust";
    homepage = "https://github.com/clux/lq";
    license = licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
