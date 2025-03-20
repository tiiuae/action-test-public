{
  description = "Example public flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Example private repo
    hello-private = {
      url = "git+ssh://git@github.com/tiiuae/action-test-private";
    };
  };

  outputs = {
    self,
    nixpkgs,
    hello-private,
  }: let
    pkgs = import nixpkgs {system = "x86_64-linux";};
    formatter = pkgs.writeShellScriptBin "format" ''
      echo "[+] Running '$(realpath "$0")'"
      if [[ $# = 0 ]]; then set -- .; fi
      ${pkgs.lib.getExe pkgs.alejandra} "$@"
    '';
    say-hello = pkgs.writeShellScriptBin "say-hello" ''
      set -eu
      echo "[+] Running '$(realpath "$0")'"
      echo "Hello from action-test-public :-)"
    '';
  in {
    # packages
    packages.x86_64-linux.hello = say-hello;
    packages.x86_64-linux.hello-private = hello-private.packages.x86_64-linux.hello;

    # formatter
    formatter.x86_64-linux = formatter;

    # checks
    checks.x86_64-linux = {
      hello = self.packages.x86_64-linux.hello;
      hello-private = self.packages.x86_64-linux.hello-private;
      fmt = self.formatter.x86_64-linux;
    };

  };
}
