{
  description = "Flaky OS";

  inputs = {
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    direnv-instant.url = "github:Mic92/direnv-instant";
  };

  outputs =
    {
      self,
      direnv-instant,
      nixos-unstable,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs-unstable.lib.genAttrs systems f;

      local = import ./local/default.nix;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs-unstable {
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
              echo "deadnix:       $(deadnix --version)"
              echo "nixfmt-tree:   $(treefmt --version)"
              echo "nix:           $(nix --version)"
            '';
          };
        }
      );

      nixosConfigurations = {
        nixos-homelab = nixos-unstable.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = {
            inherit self home-manager;
            inherit (local) userName;
            inherit direnv-instant;
            hostName = local.hosts."nixos-homelab";
          };

          modules = [ ./hosts/homelab/default.nix ];
        };

        nixos-homelab-lxc = nixos-unstable.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = {
            inherit self home-manager;
            inherit (local) userName;
            inherit direnv-instant;
            hostName = local.hosts."nixos-homelab-lxc";
          };

          modules = [ ./hosts/homelab-lxc/default.nix ];
        };

        nixos-x86_64 = nixos-unstable.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = {
            inherit self home-manager;
            inherit (local) userName;
            inherit direnv-instant;
            hostName = local.hosts."nixos-x86_64";
          };

          modules = [ ./hosts/nixos/default.nix ];
        };

        nixos-aarch64 = nixos-unstable.lib.nixosSystem {
          system = "aarch64-linux";

          specialArgs = {
            inherit self home-manager;
            inherit (local) userName;
            inherit direnv-instant;
            hostName = local.hosts."nixos-aarch64";
          };

          modules = [ ./hosts/nixos/default.nix ];
        };
      };

      darwinConfigurations = {
        darwin-mbp = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";

          specialArgs = {
            inherit self home-manager;
            inherit (local) userName;
            inherit direnv-instant;
            hostName = local.hosts."darwin-mbp";
          };

          modules = [
            ./hosts/darwin/mbp.nix
          ];
        };
      };
    };
}
