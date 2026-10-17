{
  description = "Optional CLI trial for this Ubuntu workstation; configs stay in Stow";

  # flake.lock pins the exact revision once `nix flake lock` has been run.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-gl-host = {
      url = "github:numtide/nix-gl-host";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-gl-host, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      graphicsWrapper = nix-gl-host.packages.${system}.default;
      ghosttyTrial = pkgs.writeShellScriptBin "ghostty-nix" ''
        # Don't inherit resource paths from the terminal launching this trial.
        export GHOSTTY_RESOURCES_DIR=${pkgs.ghostty}/share/ghostty
        export GHOSTTY_BIN_DIR=${pkgs.ghostty}/bin
        exec ${graphicsWrapper}/bin/nixglhost ${pkgs.ghostty}/bin/ghostty --gtk-single-instance=false "$@"
      '';
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
      packages.${system}.ghostty = ghosttyTrial;
      apps.${system}.ghostty = {
        type = "app";
        meta.description = "Ghostty trial using host NVIDIA graphics drivers";
        program = "${ghosttyTrial}/bin/ghostty-nix";
      };

      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = tools;
      };
    };
}
