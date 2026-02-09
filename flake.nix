{
  description = "Homeserver configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
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
          ansible
          ansible-lint
          git-cliff
          fzf
        ];

        shellHook = ''
          echo "Homeserver dev shell"
          echo "Available tools: terraform, just, ansible-playbook, ansible-lint, git-cliff"
        '';
      };
    };
}
