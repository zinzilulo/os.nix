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

  systemd.services."prlshprint" = {
    wantedBy = lib.mkForce [ ];

    unitConfig = {
      ConditionPathExists = lib.mkForce "!/dev/null";
    };
  };

  hardware.parallels = {
    enable = true;
    package = unstablePkgs.prl-tools;
  };
}
