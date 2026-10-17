# Nix CLI trial

Try **ripgrep, fd, fzf, jq, bat, ShellCheck, git, stow, wget, curl,
Node.js 24 LTS and pnpm** without replacing your existing installations. Your configs stay managed by Stow.

## Start

```sh
cd ~/.dotfiles/nix
nix --extra-experimental-features 'nix-command flakes' develop path:.
```

This opens a temporary Bash shell using the Nix tools. Try:

```sh
command -v rg
bat flake.nix
```

Run **`exit`** to return to your normal shell and tools.
Programs can still read and change your files; this is not a sandbox.

## Change packages

Edit the `tools` list in **`flake.nix`**, then exit and start the shell again.

**`flake.lock`** keeps package versions fixed. Keep both files in Git.

## Update versions

From this directory:

```sh
nix --extra-experimental-features 'nix-command flakes' flake update nixpkgs --flake path:.
nix --extra-experimental-features 'nix-command flakes' develop path:.
```

Test the tools, then commit the changed `flake.lock`. Update Nix-managed tools
through Nix, not their built-in updaters.

## Ghostty GUI trial

```sh
cd ~/.dotfiles/nix
nix --extra-experimental-features 'nix-command flakes' run path:.#ghostty
```

Opens a separate Ghostty 1.3.1 window using your existing config. Your usual
terminal and desktop launcher stay unchanged. Close the window to stop it.

Uses `nix-gl-host` for this machine's NVIDIA drivers. AMD/Intel-only machines
need a different graphics wrapper. This uses Nixpkgs, not Ghostty's development flake.

## New machine

[Install Nix](https://nix.dev/install-nix.html), open a new terminal, then follow
**Start** above. This setup targets x86-64 Linux. Do not run `stow nix`.
