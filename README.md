# My personal development environment

This repo contains my configuration files and scripts to easily setup a new machine.
I use GNU stow for managing the symlinks.

## Stow packages

From the repo root, stow the packages used on this machine:

```sh
stow env_vars fish git ghostty nvim pnpm
```

The `scripts` package is optional and is only needed on machines where I want `~/.local/scripts`.
