{
  lib,
  config,
  ...
}:

let
  cfg = config.unfreePackages;
in
{
  options = {
    unfreePackages.packages = lib.mkOption {
      type = lib.types.listOf (lib.types.listOf lib.types.str);
      default = [ ];
      description = "A list of unfree packages to allow. Modules can append to this.";
    };
  };

  config = {
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      let
        allUnfree = lib.concatLists cfg.packages;
      in
      lib.elem (lib.getName pkg) allUnfree;
  };
}
