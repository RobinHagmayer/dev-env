# My personal development environment

This repo contains my configuration files and scripts to easily setup a new machine.
I use GNU stow for managing the symlinks.

## Stow packages

From the repo root, stow the packages used on this machine:

```sh
stow env_vars fish git ghostty kitty nvim pnpm
```

The `scripts` package is optional and is only needed on machines where I want `~/.local/scripts`.

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
