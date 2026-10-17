{
  description = "GitOps configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          terraform
          just
          bws
          gitleaks
          lefthook
        ];
      };
    };
}
