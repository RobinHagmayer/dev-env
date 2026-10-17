{
  description = "Optional CLI trial for this Ubuntu workstation; configs stay in Stow";

  # flake.lock pins the exact revision once `nix flake lock` has been run.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      tools = with pkgs; [
        ripgrep
        fd
        fzf
        jq
        bat
        shellcheck
        git
        stow
        wget
        curl
        nodejs_24 # Current LTS line; exact version comes from flake.lock.
        pnpm
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = tools;
      };
    };
}
