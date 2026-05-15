if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_greeting
end

alias nnvim="NVIM_APPNAME=nightly-nvim nvim"
alias cp="cp -i"
alias mv="mv -i"

# Custom FFmpeg with VMAF
set -gx PATH $HOME/ffmpeg-build/bin $PATH
set -gx LD_LIBRARY_PATH $HOME/ffmpeg-build/lib $LD_LIBRARY_PATH
set -gx PATH $HOME/.local/bin $PATH
