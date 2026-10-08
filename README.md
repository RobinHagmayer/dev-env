# My personal development environment

This repo contains my configuration files and scripts to easily setup a new machine.
I use GNU stow for managing the symlinks.

## Stow packages

From the repo root, stow the packages used on this machine:

```sh
stow --no-folding shell bash fish ghostty
```

Keep Bash as the login shell. Ghostty launches `~/.local/bin/interactive-shell`,
which loads the shared terminal environment and then replaces itself with Fish
(or starts Bash if Fish is missing, so a broken setup never closes the terminal).
Bash sources the same environment. No Bash login wrapper or Fish environment
parser is needed.

## Tool installation and environment

Install tools with the playbooks in `ansible/` (run them from that directory,
e.g. `cd ~/.dotfiles/ansible && uv run ansible-playbook playbooks/dev-tools.yml`).
Its Rust, pnpm
and Go roles generate `~/.config/shell/env.d/*.sh` from their installation
settings. Do not edit those generated files: change the corresponding Ansible
role defaults and rerun the playbook. Rust uses `~/.local/share/cargo` and
`~/.local/share/rustup`; Go uses its default GOPATH and discovers its GOROOT.

The `shell` package provides `~/.config/shell/env.sh`, which loads those
fragments and adds `~/.local/bin` without duplicating PATH entries. It also
sets the preferred editor. This is a terminal environment, not a systemd or
GNOME-wide environment. Desktop apps/services needing tool variables must be
configured explicitly. No Java or personal FFmpeg configuration is enabled.

For a terminal other than Ghostty/Kitty, configure its command as
`~/.local/bin/interactive-shell`. Fish started from an initialized Bash/Fish
inherits the environment. For an already-running terminal, start a fresh shell:

```sh
exec ~/.local/bin/interactive-shell
```

Fish's mutable `fish_variables` stays local. Prompt, theme, aliases and functions
are tracked as normal Fish configuration. `bash/.bashrc` is Ubuntu's stock `/etc/skel/.bashrc` (colour prompt, `lesspipe`,
completion, `~/.bash_aliases`) with the shared environment loader added on top.
After a distro upgrade, refresh it from `/etc/skel/.bashrc` and keep the loader
block. Back up and review existing startup files before replacing them.

## Other optional Stow packages

```sh
stow --no-folding agents
stow git kitty nvim uv
# Review local conflicts before deploying these:
stow pi pnpm
```

Use `stow --simulate --verbose ...` first. Do not blindly use `--adopt`: it
moves existing local files into the repository and may overwrite your intended
tracked settings. The old `env_vars` package was removed; if previously stowed,
unstow it before upgrading (or remove its now-broken symlink). If an old
`ghostty/config` link exists, remove it before deploying `config.ghostty`.

The `scripts` package is optional. Neovim and Nerd Font installation are now
provided by Ansible.

## Modern Neovim (independent trial config)

Your existing `nvim` config is retained. A second app provides current LSP,
project-local TypeScript/Effect support, FFF search, syntax editing, completion,
and contextual feature discovery:

```sh
bash nvim-modern/setup-tools.sh
stow --simulate --verbose nvim-modern
stow nvim-modern
nvim-modern
```

The launcher sets `NVIM_APPNAME=nvim-modern`, isolating plugins, Mason tools,
cache, and state. Plain `nvim` still uses the old config. Use **Space ?** for
contextual actions, **Space h h** for the guide, and **Space u h** for health.
See [nvim-modern/README.md](nvim-modern/README.md) for prerequisites, keymaps,
Effect/Oxlint project setup, updates, tests, and rollback.

The latest upstream runtime is separately pinned in
`ansible/playbooks/neovim-modern.yml` and installed into
`~/.local/opt/nvim-modern` without replacing the system Neovim. Its experimental
HEAD build is optional; the new config also works with Neovim 0.12+.

## Regional formats (German dates, currency and units, English UI)

The `locale` package keeps the display language English (`LANG=en_US.UTF-8`) but
sets the regional formats (`LC_TIME`, `LC_MONETARY`, `LC_NUMERIC`,
`LC_MEASUREMENT`, `LC_PAPER`) to `de_DE.UTF-8` through
`~/.config/environment.d/`. Unlike `shell/env.sh`, the systemd user session
reads this, so desktop apps such as Microsoft Edge inherit it. Generate the
locale first, then stow and log out and back in:

```sh
(cd ansible && uv run ansible-playbook playbooks/locale.yml --ask-become-pass)
stow --no-folding locale
```

In Edge, set Settings > Languages > "Share additional operating system region"
to the fuller option. That setting lives in the browser profile and is not
tracked here. Whether Edge reads the `LC_*` variables is untested; the
fallback is launching it with `--lang=en-DE`.

## T3 Code data directory

T3 Code does not follow XDG and writes everything to `~/.t3`. The `t3code`
package sets `T3CODE_HOME=~/.local/share/t3` through `~/.config/environment.d/`,
so the desktop app, the `t3` CLI in GNOME terminals, and `t3 service install`
(which records the value in its unit) all use it. SSH and TTY logins do not read
`environment.d`; add the export to `shell/env.sh` if `t3` is needed there.

Stow it, then log out and back in **before** first launching T3 Code, or it
recreates `~/.t3`:

```sh
stow --no-folding t3code
```

## Shared agent skills

The `agents` package tracks `~/.agents/skills` and `~/.agents/skill-sources.toml`.
These are the shared skills retained for a new installation. Restore them with:

```sh
stow --no-folding agents
```

The `--no-folding` option keeps `~/.agents` as a real directory and links its
files into this repository, including all skill assets and helper scripts.

On this machine, `~/.claude/skills` already links to `~/.agents/skills`. To restore
that link on a fresh installation, when `~/.claude/skills` does not exist:

```sh
mkdir -p ~/.claude
ln -s ../.agents/skills ~/.claude/skills
```

Codex's built-in skills can be recreated by Codex. Skills outside
`~/.agents/skills` are not part of the retained backup set.

## Pi coding agent

Pi separates tracked preferences from mutable local settings:

- `pi/settings.template.json` contains intentional preferences only.
- `pi/.pi/agent/themes/` and `prompts/` are deployed through Stow.
- `~/.pi/agent/settings.json` is a local file, **not a symlink**. Pi can update
  bookkeeping such as `lastChangelogVersion` without dirtying this repository.

Restore from the repository root:

```sh
stow --simulate --verbose --no-folding pi
stow --no-folding pi
bash pi/apply-settings.sh
```

The script merges the template over local settings: objects merge recursively,
template values win, and arrays are replaced. Unspecified local fields survive.
It backs up changed settings to a timestamped `settings.json.<date>.bak`, leaves an already-applied file alone, preserves permissions,
and refuses to replace a symlink. `PI_CODING_AGENT_DIR` overrides the settings
location; Stow still targets the usual HOME paths. Close Pi before applying
settings to avoid concurrent writes, then restart it or run `/reload`.

When changing a preference through `/settings`, copy only the intended change
into the template. Reapply deliberately, not on every launch. Do not copy Pi's
bookkeeping into the template. Credentials (`auth.json`), trust decisions,
sessions, logs, model caches, downloaded binaries, installation directories,
and generated `git/`, `npm/`, and `node_modules/` contents remain local.

The older `extensions/guardrails.json` and `extensions/web-tools/` sources are
retained for review but excluded from Stow by `pi/.stow-local-ignore`.
The old `pi-guardrails` and `plannotator` package declarations are not restored.
Review compatibility before opting back in; the vendored web-tools extension
would also need its runtime dependencies installed with `pnpm install --prod`.

## Intune automatic check-in (Ubuntu/GNOME, corporate machines)

The `intune` package fixes hands-off Intune background check-in. By default the
shipped `intune-agent` timer looks for the device registration in the wrong
directory, so it never checks in unless the Intune app is opened manually; the
drop-in points it back at `~/.config/intune`, where `intune-portal` actually
writes the registration.

On a machine enrolled in Intune:

```sh
# 1. Enroll first: open "Microsoft Intune" and sign in once (incl. MFA).
#    This creates ~/.config/intune/registration.toml.
# 2. Stow the drop-in and run the setup/verify helper:
stow intune
~/.local/scripts/setup-intune-checkin   # needs the `scripts` package stowed
```

`setup-intune-checkin` checks the prerequisites, reloads the user daemon, and
triggers a test check-in. It also warns if a future package version makes the
workaround unnecessary (in which case: `stow -D intune && systemctl --user daemon-reload`).
See the comments in `intune/.config/systemd/user/intune-agent.service.d/10-fix-statedir.conf`.
