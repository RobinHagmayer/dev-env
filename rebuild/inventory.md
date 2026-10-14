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
- Neovim: original system editor retained; modern app uses separately pinned upstream HEAD (see `ansible/playbooks/neovim-modern.yml`), or Neovim 0.12+; fish 4.8.0

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

The original Neovim config and lockfile remain available as a fallback. Restore the independent `nvim-modern` app following [its README](../nvim-modern/README.md); its plugins and tools are isolated by `NVIM_APPNAME`. The following plugin list is a historical snapshot of the original config:

```text
blink.cmp fff.nvim kanagawa.nvim lspkind mason-lspconfig
mason-tool-installer mason.nvim nvim-lspconfig nvim-treesitter nvim-web-devicons
```

Use `ansible/playbooks/nerd-fonts.yml` to install Meslo Nerd Fonts. The older dotfiles installer is retained for reference only.

## Rebuild order

1. Install company-managed software and sign in.
2. Clone the dotfiles repository. Install developer tools with the playbooks in `ansible/`; Rust, pnpm and Go also generate their terminal environment fragments.
3. Back up local startup files, then stow `shell bash fish ghostty` following the dotfiles README. Include other packages such as `uv` after review; resolve existing file conflicts rather than blindly adopting them.
4. Install remaining APT/Snap/Flatpak applications and global tools. Optionally build `ansible/playbooks/neovim-modern.yml`, run `bash nvim-modern/setup-tools.sh`, then stow `nvim-modern`. Launch `nvim-modern` to restore its isolated plugins/tools; plain `nvim` remains the fallback.
5. Re-authenticate GitHub, cloud, Docker and other CLIs; restore only approved Bitwarden secrets.
6. Restore supported Neo4j dumps after installing Neo4j Desktop.
