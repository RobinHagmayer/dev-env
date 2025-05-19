set -Ux FNM_PATH "$XDG_DATA_HOME/fnm"
fish_add_path $FNM_PATH

fnm env --use-on-cd --shell fish | source
