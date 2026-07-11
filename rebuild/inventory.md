# Workstation rebuild inventory

Generated 2026-07-11 from local package metadata. This is a rebuild aid, not a script: validate company-managed software, Ubuntu version, package availability, and license/policy requirements before installing.

## Versions observed

- Ubuntu package tooling; Git 2.43.0
- Node 24.17.0; pnpm 11.8.0
- Python 3.12.3; uv is configured in `../uv/.config/uv/uv.toml`
- Rust/Cargo 1.96.0; Go present
- Java/OpenJDK 21.0.11
- Docker 29.6.1; Compose plugin 5.3.0
- Azure CLI 2.88.0; GitHub CLI 2.96.0
- Neovim 0.12.4; fish 4.8.0

## Install manually / through approved company channels

- Intune Portal and required Intune agent configuration
- NinjaOne agent and Zscaler Client (company-managed)
- Microsoft Edge Stable
- NVIDIA driver suitable for the reinstalled machine
- Neo4j Desktop

## APT packages intentionally installed

Developer/CLI packages:

```text
azure-cli build-essential clang cmake curl docker-buildx-plugin docker-ce
docker-ce-cli docker-compose-plugin fish flatpak fzf gh git google-cloud-cli
gnupg gpg imagemagick ksnip neovim ninja-build pkg-config python3-pip
python3.12-venv ripgrep stow tree wmctrl
```

Language, locale and dictionary packages were also manually installed. Reinstall only if useful: `gettext`, `hunspell-*`, `language-pack-*`, `wbritish`, `wngerman`, `wogerman`, `wswiss`.

## Snap applications

```text
firefox
ghostty
```

The other installed snaps are platform/runtime dependencies and will be pulled as needed.

## Flatpak applications

```text
com.discordapp.Discord
md.obsidian.Obsidian
org.onlyoffice.desktopeditors
```

## Global developer tools

pnpm global packages:

```text
@earendil-works/pi-coding-agent@0.80.6
@pnpm/exe@11.8.0
azure-functions-core-tools@4.12.1
azurite@3.35.0
node@24.17.0
```

Cargo-installed tools:

```text
tree-sitter-cli@0.26.6
typst-cli@0.14.2
zellij@0.44.3
```

## Editor and fonts

Neovim config and lock file are already stowed. The observed optional plugins are:

```text
blink.cmp fff.nvim kanagawa.nvim lspkind mason-lspconfig
mason-tool-installer mason.nvim nvim-lspconfig nvim-treesitter nvim-web-devicons
```

Use the existing `scripts/.local/scripts/install-nerd-font` dotfiles script to reinstall the Meslo Nerd Font family instead of copying `~/.local/share/fonts`.

## Rebuild order

1. Install company-managed software and sign in.
2. Clone/stow dotfiles; include the `uv` package after review.
3. Install APT/Snap/Flatpak applications and language runtimes.
4. Install global tools and open Neovim to restore plugins/tools from configuration.
5. Re-authenticate GitHub, cloud, Docker and other CLIs; restore only approved Bitwarden secrets.
6. Restore supported Neo4j dumps after installing Neo4j Desktop.
