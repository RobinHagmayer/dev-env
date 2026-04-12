# Neovim Configuration

Personal Neovim config built on Neovim 0.12's native package management. No plugin manager dependency.

## Directory Structure

```
├── init.lua                       Auto-loads all modules from config/ and plugins/
├── lua/
│   ├── config/
│   │   ├── globals.lua            Leader keys, provider disables, netrw settings
│   │   ├── keymaps.lua            Custom keymaps
│   │   ├── options.lua            Editor options (indentation, search, UI, etc.)
│   │   └── autocmds.lua           Autocommands (yank highlight, close-with-q, etc.)
│   └── plugins/
│       ├── lsp.lua                LSP setup, Mason, keymaps
│       ├── nvim-treesitter.lua    Treesitter parsing and folding
│       ├── completions.lua        Autocompletion
│       ├── nvim-web-devicons.lua  Icon support
│       └── colorscheme.lua        Kanagawa theme
├── after/ftplugin/                Per-language overrides (indentation)
├── .stylua.toml                   StyLua formatter config
└── nvim-pack-lock.json            Pinned plugin versions
```

## Plugins

| Plugin | Purpose | Why this one |
|---|---|---|
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP client configurations | Standard Neovim LSP config collection — avoids hand-writing each server's `cmd`, `root_dir`, etc. |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | Install LSP servers and tools | Easier than installing language servers via system package manager; works cross-platform |
| [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Bridge Mason ↔ LSP config | Keeps `ensure_installed` and server setup in sync |
| [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Auto-install non-LSP tools | Mason-lspconfig only handles LSP servers; this handles formatters/linters (e.g., stylua) |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting and folding | Neovim's built-in treesitter API requires per-language queries; this bundles them |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Autocompletion | Fuzzy matching with frecency, multi-source (LSP/path/snippets/buffer), signature help, cmdline completion — much richer than mini.completion or built-in `vim.lsp.completion` |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | File icons | <!-- TODO: which plugins consume these icons? blink.cmp has its own kind icons -->
| [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim) | Color scheme | This is my personal favorite colorscheme right now! |

## Architecture Decisions

### `vim.pack.add()` instead of a plugin manager
Neovim 0.12 ships a built-in package manager. No third-party dependency (lazy.nvim, packer, etc.) to maintain or break across Neovim upgrades. Plugin versions are pinned in `nvim-pack-lock.json`.

### Python LSP split: ruff + ty
Instead of a single Python LSP, responsibilities are split:
- **ruff** — formatting and linting
- **ty** — type checking, hover, and diagnostics

When both are attached to the same buffer, their capabilities are manually downscoped so they don't conflict (e.g., ruff's hover is disabled since ty provides better type info).

### blink.cmp with Rust fuzzy matcher
Blink.cmp auto-downloads a prebuilt Rust binary (frizbee) from GitHub releases when pinned to a version range like `>=1.0`. On a new machine, `vim.pack.add` clones the repo, then blink.cmp downloads the matching binary — no manual steps, no Rust toolchain needed. Falls back to a Lua implementation with a warning if download fails.

### blink.cmp auto-injects LSP capabilities
Blink.cmp's plugin file detects Neovim 0.11+ (`vim.lsp.config`) and auto-merges `get_lsp_capabilities()` into the wildcard LSP config. No manual capability setup needed in `lsp.lua`.

### No swap files, no backups
Using `undofile` instead — persistent undo across sessions without the noise of `.swp` and `~` backup files cluttering the filesystem.

### Treesitter parsers installed to `site` dir
Parsers are installed to `stdpath("data") .. "/site"`, keeping them separate from the config directory. This means nuking the config doesn't lose downloaded parsers.

### `auto_update = false` in mason-tool-installer
Tool versions are not auto-updated on startup. This avoids breaking changes from sneaking in. Update tools explicitly when you choose to.

## ftplugin Overrides

The `after/ftplugin/` directory sets 2-space indentation for Lua, CSS, YAML, TOML, JSON, and HTML — overriding the default 4-space setting in `options.lua`.

## Formatting

Code is formatted with [StyLua](https://github.com/JohnnyMorganz/StyLua) using the settings in `.stylua.toml`. Run on the whole config:

```sh
stylua lua/
```
