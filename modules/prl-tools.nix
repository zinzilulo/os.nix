{
  config,
  lib,
  pkgs,
  nixpkgs-unstable,
  ...
}:

let
  unstablePkgs = import nixpkgs-unstable {
    inherit (pkgs) system;
    config = {
      allowUnfreePredicate = pkg: lib.getName pkg == "prl-tools";
    };
  };
in
{
  nixpkgs.config.allowUnfree = true;

  hardware.parallels = {
    enable = true;
    package = unstablePkgs.prl-tools;
  };
}
