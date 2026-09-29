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
    direnv-instant.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs =
    {
      self,
      direnv-instant,
      nixos-unstable,
      nixpkgs-unstable,
      nixos-wsl,
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

      mkNixos =
        {
          hostName,
          system,
          modules,
          isWSL ? false,
        }:
        nixos-unstable.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit home-manager direnv-instant;
            inherit (local) userName;
            nixos-pkgs = nixos-unstable.legacyPackages.${system};
            nixpkgs-pkgs = nixpkgs-unstable.legacyPackages.${system};
            inherit hostName;
          }
          // nixos-unstable.lib.optionalAttrs isWSL {
            inherit nixos-wsl;
          };

          inherit modules;
        };

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
            ];

            shellHook = ''
              echo "Nix Shell:"
              echo "deadnix:       $(deadnix --version)"
              echo "nix:           $(nix --version)"
            '';
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs-unstable.legacyPackages.${system}.nixfmt-tree);

      nixosConfigurations = {
        nixos-wsl = mkNixos {
          hostName = local.hosts."nixos-wsl";
          system = "x86_64-linux";
          modules = [ ./hosts/wsl/default.nix ];
          isWSL = true;
        };

        nixos-homelab = mkNixos {
          hostName = local.hosts."nixos-homelab";
          system = "x86_64-linux";
          modules = [ ./hosts/homelab/default.nix ];
        };

        nixos-homelab-lxc = mkNixos {
          hostName = local.hosts."nixos-homelab-lxc";
          system = "x86_64-linux";
          modules = [ ./hosts/homelab-lxc/default.nix ];
        };

        parallels-x86_64 = mkNixos {
          hostName = local.hosts."nixos-x86_64";
          system = "x86_64-linux";
          modules = [ ./hosts/parallels/default.nix ];
        };

        qemu_amd-x86-64 = mkNixos {
          hostName = local.hosts."nixos-x86_64";
          system = "x86_64-linux";
          modules = [ ./hosts/qemu_amd-x86-64/default.nix ];
        };

        parallels-aarch64 = mkNixos {
          hostName = local.hosts."nixos-aarch64";
          system = "aarch64-linux";
          modules = [ ./hosts/parallels/default.nix ];
        };
      };

      darwinConfigurations = {
        darwin-mbp =
          let
            system = "aarch64-darwin";
          in
          nix-darwin.lib.darwinSystem {

            specialArgs = {
              inherit
                self
                system
                home-manager
                direnv-instant
                ;
              inherit (local) userName;
              nixpkgs-pkgs = nixpkgs-unstable.legacyPackages.${system};
              hostName = local.hosts."darwin-mbp";
            };

            modules = [
              ./hosts/darwin/mbp.nix
            ];
          };
      };
    };
}
