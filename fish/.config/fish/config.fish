# Tool environment is inherited from interactive-shell or Bash.
# Keep this file focused on interactive preferences, not exported tool paths.
if status is-interactive
    set -g fish_greeting
    alias cp="cp -i"
    alias mv="mv -i"
end
