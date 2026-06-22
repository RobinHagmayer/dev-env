# Load XDG environment.d files for shells that were not started by systemd user environment.
# Environment variables themselves are defined in ~/.config/environment.d/*.conf.
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME "$HOME/.config"

for file in $XDG_CONFIG_HOME/environment.d/*.conf
    test -f "$file"; or continue

    while read --line line
        set line (string trim -- "$line")

        # Skip blank lines and comments.
        test -n "$line"; or continue
        string match -q '#*' -- "$line"; and continue

        set -l assignment (string split --max 1 '=' -- "$line")
        test (count $assignment) -eq 2; or continue

        set -l key $assignment[1]
        set -l value $assignment[2]

        # Support optional double quotes for compatibility with older files.
        if string match -qr '^".*"$' -- "$value"
            set value (string sub --start 2 --end -1 -- "$value")
        end

        # Expand references such as $HOME, $XDG_DATA_HOME, and $PATH using the
        # variables already exported by earlier lines/files and the parent env.
        set value (printf '%s' "$value" | envsubst)

        if test "$key" = PATH
            set -gx PATH (string split ':' -- "$value")
        else
            set -gx $key "$value"
        end
    end < "$file"
end
