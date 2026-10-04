# My personal development environment

This repo contains my configuration files and scripts to easily setup a new machine.
I use GNU stow for managing the symlinks.

## Stow packages

From the repo root, stow the packages used on this machine:

```sh
stow --no-folding agents
stow env_vars fish git ghostty kitty nvim pi pnpm
```

The `scripts` package is optional and is only needed on machines where I want `~/.local/scripts`.

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

The `pi` package stows the portable global configuration:

- `~/.pi/agent/settings.json`
- `~/.pi/agent/APPEND_SYSTEM.md`
- `~/.pi/agent/extensions/guardrails.json`
- `~/.pi/agent/extensions/web-tools/` (`webfetch` and Exa-backed `websearch`)

After stowing `pi` on a new machine, install the vendored extension's runtime dependencies:

```sh
pnpm install --prod --dir ~/.pi/agent/extensions/web-tools
```

`websearch` uses Exa's official MCP free tier and does not require an API key.
`settings.json` declares installed Pi packages, so Pi can restore them without
committing generated package directories. Credentials (`auth.json`), trust
decisions, sessions, logs, model caches, downloaded binaries, and generated
`git/` and `npm/` package contents remain local and must not be committed.

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
