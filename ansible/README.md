# Ansible playbooks

Personal Ansible playbooks, part of the dev-env repository (`~/.dotfiles/ansible`).
Run every command in this README from this directory.

## Prerequisites

Fresh Ubuntu LTS with `curl`, `git` and `openssh-client` (all usually preinstalled).

### 1. Install uv (manual step)

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Restart the shell and verify:

```sh
uv --version
```

uv manages its own Python, so the distro's `python3` is not used.

### 2. Install Ansible with uv

Ansible is a project dependency, so the version is pinned in `pyproject.toml` and `uv.lock`.

First-time setup of the project (only once, then commit the files):

```sh
uv init --bare
uv add ansible
```

On any other machine, after cloning:

```sh
uv sync
```

Verify:

```sh
uv run ansible --version
```

Run Ansible commands through `uv run`, e.g. `uv run ansible-playbook playbook.yml`.

## Usage

Install the base packages and developer tools (Rust, Go, Zig, pnpm + Node.js + npm) on this machine:

```sh
uv run ansible-playbook playbooks/dev-tools.yml --ask-become-pass
```

Install pinned Pi, Claude Code and Codex releases:

```sh
uv run ansible-playbook playbooks/ai-tools.yml --ask-become-pass
```

Install only selected tools:

```sh
uv run ansible-playbook playbooks/ai-tools.yml --tags pi --ask-become-pass
uv run ansible-playbook playbooks/ai-tools.yml --tags claude,codex --ask-become-pass
```

These roles install as your normal user and reconcile the versions selected by their defaults, including downgrades. Pi uses the official versioned managed-install manifests, checks their SHA256 digests, and installs locked dependencies with `npm ci --ignore-scripts`; its sessions and credentials are preserved. Pi pulls in pnpm for Node.js and a separately pinned npm package (pnpm's runtime installer does not bundle npm). Claude Code downloads a checksum-pinned native binary directly (its shell installer always downloads a latest bootstrap binary). The role merges `env.DISABLE_AUTOUPDATER: "1"` into existing Claude settings without replacing unrelated preferences, backing up changed settings. Codex uses its official non-interactive installer with an exact release argument, isolates installer HOME to prevent profile edits, and removes the standalone package's automatic-update marker. Check mode does not download or install tools.

Update these tools by changing their role defaults and rerunning this playbook, not with their self-update commands. Manual self-updates remain possible but the next playbook run restores the repository's pin. Authentication is a separate manual step; no credentials are managed by these roles. Other installation locations/package managers are not automatically migrated. Make sure `~/.local/bin` is on your shell PATH, e.g. for the current terminal:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

Install pinned GitHub CLI from its [official Debian/Ubuntu repository](https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian):

```sh
uv run ansible-playbook playbooks/gh.yml --ask-become-pass
```

The `gh` role installs the exact `gh_version` in `roles/gh/defaults/main.yml` (currently `2.102.0`) and puts the package on apt hold, preventing `apt upgrade` and unattended upgrades from changing it. To update or downgrade, deliberately change that pin and rerun the playbook. If the installed package already matches, the role skips the package installation even if the repository has dropped that version. An unavailable new pin fails instead of falling back to latest. The repository signing key is SHA256-verified and scoped to this repository; update its checksum deliberately if GitHub rotates the key. All installation tasks require sudo and are tagged `packages`. Authentication (`gh auth login`) is a separate manual step; no credentials are managed.

Install Fish shell from the [official Ubuntu Fish 4 PPA](https://launchpad.net/~fish-shell/+archive/ubuntu/release-4):

```sh
uv run ansible-playbook playbooks/fish.yml --ask-become-pass
```

This Ubuntu-only role adds the PPA with a repository-scoped signing key and installs the exact `fish_version` apt package, including its Ubuntu release suffix. The default is for this machine's Ubuntu release; override it for other releases after checking `apt-cache policy fish`. Rerunning does nothing when the installed version already matches `fish_version`, even if the PPA has since dropped that build. Fish is placed on apt hold so `apt upgrade` and unattended upgrades cannot move it; changing `fish_version` releases the hold, installs the new version and holds again. A new pin that is not (or no longer) in the PPA causes a failure rather than a fallback to latest; the PPA keeps only the current build per Ubuntu release, so reinstalling an old pin later may require another source. Unlike the user-home installs, all installation steps require sudo and are tagged `packages`. Your login shell and shell configuration are unchanged.

Install Meslo Nerd Font v3.4.0 (migrated from `~/.dotfiles/scripts/.local/scripts/install-nerd-font`):

```sh
uv run ansible-playbook playbooks/nerd-fonts.yml --ask-become-pass
```

The archive is cached and SHA256-verified, then extracted into `~/.local/share/fonts/Meslo` as your normal user. Reruns compare the archive contents and repair missing or changed files; the font cache is refreshed only when extraction changes something. Set `nerd_fonts_family`, `nerd_fonts_version` and the matching `nerd_fonts_sha256` in the role defaults to use another font/release. Check mode does not download or extract fonts. No terminal configuration is changed, and the original script and any previously installed fonts are left untouched; obsolete files are not automatically pruned.

Build and install the pinned stable Ghostty release from its source tarball (pulls in the Zig role):

```sh
uv run ansible-playbook playbooks/ghostty.yml --ask-become-pass
```

The default is Ghostty 1.3.1 with its saved SHA256 checksum. Floating `tip` builds are rejected. Reruns rebuild only when source/build settings change or the binary is missing. Old source/cache directories are retained. When building `gtk4-layer-shell` from source, the role uses `patchelf` to add `$ORIGIN/../lib` to Ghostty's library search path; this repair also runs when no rebuild is needed.

Ghostty uses its version-specific Zig executable under `~/.local/opt/zig-<version>/zig`. Its Zig dependency does not change `~/.local/bin/zig`, so running `dev-tools.yml` and `ghostty.yml` cannot fight over that link. Update `ghostty_version`, `ghostty_sha256`, and the required Zig version/checksum together, checking the source's `build.zig.zon` and [build documentation](https://ghostty.org/docs/install/build).

Build Neovim from source and install it as a DEB package (so `dpkg`/`apt remove neovim` removes it cleanly):

```sh
uv run ansible-playbook playbooks/neovim.yml --ask-become-pass
```

Every role installs the system packages it needs itself (tasks tagged `packages`, run with sudo), so each role works on its own. Run a subset with tags, and skip the sudo tasks when the packages are already there:

```sh
uv run ansible-playbook playbooks/dev-tools.yml --tags go,zig --ask-become-pass
uv run ansible-playbook playbooks/dev-tools.yml --skip-tags packages
```

Rust, pnpm and Go also generate POSIX environment fragments in `~/.config/shell/env.d`. The `shell` Stow package of this repository (`~/.dotfiles/shell`) loads them for Bash and its interactive Fish launcher; installation paths and generated exports come from the same role defaults. These files configure terminal environments, not GNOME or systemd services. Rust data lives in `~/.local/share/cargo` (`rust_home`) and `~/.local/share/rustup` (`rust_toolchain_home`). Existing `~/.cargo` and `~/.rustup` directories are moved there, with compatibility symlinks retained for old terminals; the role refuses to merge two existing installations. Rust uses `--no-modify-path`, and pnpm's installer runs with an isolated HOME so neither adds configuration to your real startup files. Rerun `dev-tools.yml --tags rust,pnpm,go` after changing their settings. Removing a tool does not automatically remove its environment fragment.

## Version policy

Tool versions are configured in `roles/<role>/defaults/main.yml`. A new upstream release alone must not change the selected version: update the pin (and any corresponding checksums), review/commit that change, then rerun the relevant playbook. Exact Node.js, npm, Rust and rustup versions are pinned too; `stable`, `latest`, bare Node majors and Ghostty `tip` are not accepted. Pi's two manifest checksums must be updated along with its version. Existing older releases/toolchains are retained rather than pruned.

Neovim reconciles its DEB version, including downgrades. Ghostty reconciles its build signature. Rust ensures the exact toolchain is installed and selected as default, with `--no-self-update` on toolchain installations. pnpm checks its own version and the exact Node.js/npm versions, independently repairing missing npm shims. AI roles select and verify their pinned versions.

OS prerequisite packages deliberately use apt `state: present`, not exact package pins. Ubuntu security/system upgrades are managed separately; refreshing apt metadata is not a tool version upgrade. Version pinning is not a frozen OS image: dependency packages, upstream installer scripts and release availability can still change.

Lint: `uv run ansible-lint`
