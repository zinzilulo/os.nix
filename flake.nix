{
  description = "Flaky OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
    }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f: lib.genAttrs systems f;

      local = import ./local/default.nix;

      mkHost =
        {
          system,
          key,
        }:
        lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit self home-manager;
            inherit (local) userName;
            hostName = local.hosts.${key};
          };

          modules = [ ./hosts/nixos/default.nix ];
        };
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              statix
              deadnix
              nixfmt-tree
            ];

            shellHook = ''
              echo "Nix Shell:"
              echo "statix:        $(statix --version)"
              echo "deadnix:       $(deadnix --version)"
              echo "nixfmt-tree:   $(treefmt --version)"
              echo "nix:           $(nix --version)"
            '';
          };
        }
      );

      nixosConfigurations = {
        nixos-x86_64 = mkHost {
          system = "x86_64-linux";
          key = "nixos-x86_64";
        };

        nixos-aarch64 = mkHost {
          system = "aarch64-linux";
          key = "nixos-aarch64";
        };
      };

      darwinConfigurations = {
        darwin-mbp = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";

          specialArgs = {
            inherit self home-manager;
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
