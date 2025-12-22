{
  # Your local username
  userName = "your-user";

  # Hostnames for each flake configuration
  hosts = {
    nixos-x86_64 = "your-nixos-host";
    nixos-aarch64 = "your-arm-host";
    darwin-mbp = "your-mac-hostname";
  };
}
