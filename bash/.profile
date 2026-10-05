# Login environment for Bash/POSIX shells; Fish is launched by the terminal.
if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh" ]; then
    . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"
fi

if [ -n "${BASH_VERSION:-}" ]; then
    case $- in
        *i*) [ ! -r "$HOME/.bashrc" ] || . "$HOME/.bashrc" ;;
    esac
fi
