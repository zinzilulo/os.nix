{
  # Your local username
  userName = "your-user";

  # Hostnames for each flake configuration
  hosts = {
    nixos-x86_64 = "your-nixos-host";
    prl-x86_64 = "your-parallels-host";
    nixos-aarch64 = "your-arm-host";
    prl-aarch64 = "your-arm-parallels-host";
    darwin-mbp = "your-mac-hostname";
  };
}
