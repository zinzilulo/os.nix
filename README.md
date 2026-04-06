# OS.nix

## Hosts

The flake defines these configurations:

### NixOS (`nixosConfigurations`)

| Flake name      | System        | Host key            |
|-----------------|---------------|---------------------|
| `nixos-homelab` | x86_64-linux  | `nixos-homelab`     |
| `nixos-homelab` | x86_64-linux  | `nixos-homelab-lxc` |
| `nixos-x86_64`  | x86_64-linux  | `nixos-x86_64`      |
| `nixos-aarch64` | aarch64-linux | `nixos-aarch64`     |

### macOS (`darwinConfigurations`)

| Flake name   | System         | Host key     |
|--------------|----------------|--------------|
| `darwin-mbp` | aarch64-darwin | `darwin-mbp` |

## Username and Hostnames

**IMPORTANT: The flake includes a placeholder `./local/default.nix`, but you must supply your own settings.**

Edit `./local/default.nix`:

```nix
{
  # Your local username
  userName = "your-user";

  # Hostnames for each flake configuration
  hosts = {
    nixos-homelab = "your-homelab-host";
    nixos-homelab-lxc = "your-homelab-lxc-host";
    nixos-x86_64 = "your-nixos-host";
    nixos-aarch64 = "your-arm-host";
    darwin-mbp = "your-mac-hostname";
  };
}
```

## Hardware Configuration (NixOS)

**IMPORTANT: Edit or replace the hardware config before rebuilding after a fresh install.**

```sh
sudo nixos-generate-config --show-hardware-config \
  > hosts/nixos/hardware-configuration.nix
sudo nixos-generate-config --show-hardware-config \
  > hosts/homelab/hardware-configuration.nix
```

## Caveats (NixOS)

- Needs `WLR_NO_HARDWARE_CURSORS=1` for proper cursor rendering under Sway in Parallels

## Commands

### NixOS Rebuild

```sh
sudo nixos-rebuild switch --flake .#nixos-homelab
sudo nixos-rebuild switch --flake .#nixos-homelab-lxc
sudo nixos-rebuild switch --flake .#nixos-x86_64
sudo nixos-rebuild switch --flake .#nixos-aarch64
```

### macOS (nix-darwin) Rebuild

From macOS:

```sh
sudo darwin-rebuild switch --flake .#darwin-mbp
```

### Garbage Collection / Optimisation

```sh
# Delete old generations (system)
sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system

# Garbage collect
sudo nix-collect-garbage -d

# Optimize store
sudo nix-store --optimise
```

