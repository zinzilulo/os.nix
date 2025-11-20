{
  description = "Flaky OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
    }:
    let
      inherit (nixpkgs) lib;

      local = import ./local/default.nix;

      mkHost =
        {
          system,
          key,
          isParallels ? false,
        }:
        lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit self home-manager nixpkgs-unstable;
            inherit (local) userName;
            hostName = local.hosts.${key};
            inherit isParallels;
          };

          modules = [ ./hosts/nixos/default.nix ] ++ lib.optionals isParallels [ ./modules/prl-tools.nix ];
        };
    in
    {
      nixosConfigurations = {
        nixos-x86_64 = mkHost {
          system = "x86_64-linux";
          key = "nixos-x86_64";
          isParallels = false;
        };

        prl-x86_64 = mkHost {
          system = "x86_64-linux";
          key = "prl-x86_64";
          isParallels = true;
        };

        nixos-aarch64 = mkHost {
          system = "aarch64-linux";
          key = "nixos-aarch64";
          isParallels = false;
        };

        prl-aarch64 = mkHost {
          system = "aarch64-linux";
          key = "prl-aarch64";
          isParallels = true;
        };
      };

      darwinConfigurations = {
        darwin-mbp = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";

          specialArgs = {
            inherit self home-manager nixpkgs-unstable;
            inherit (local) userName;
            hostName = local.hosts."darwin-mbp";
          };

          modules = [
            ./hosts/darwin/mbp.nix
          ];
        };
      };
    };
}
