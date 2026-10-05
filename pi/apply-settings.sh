#!/usr/bin/env bash
# Apply tracked preferences without tracking Pi's mutable settings file.
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
agent_dir=${PI_CODING_AGENT_DIR:-"$HOME/.pi/agent"}
settings="$agent_dir/settings.json"

command -v jq >/dev/null || { echo 'jq is required' >&2; exit 1; }
if [[ -L "$settings" ]]; then
  echo "Refusing to replace symlink: $settings. Unstow it and restore a local copy first." >&2
  exit 1
fi

mkdir -p -- "$agent_dir"
tmp=$(mktemp "$agent_dir/.settings.XXXXXX")
trap 'rm -f -- "$tmp"' EXIT

# Empty settings are valid on a new installation. Reject malformed inputs.
local_settings=/dev/null
if [[ -e "$settings" ]]; then
  local_settings=$settings
fi
jq -e -s '
  if length == 1 then [{}] + . else . end
  | if length != 2 or any(.[]; type != "object") then
      error("Settings and template must be JSON objects")
    elif (.[1] | has("lastChangelogVersion")) then
      error("Keep lastChangelogVersion out of the tracked template")
    else .[0] * .[1] end
' "$local_settings" "$root/settings.template.json" > "$tmp"

if [[ -f "$settings" ]]; then
  # Already applied: leave the file and its backup alone.
  if [[ "$(jq -S . "$settings")" == "$(jq -S . "$tmp")" ]]; then
    printf 'Preferences already applied to %s\n' "$settings"
    exit 0
  fi
  chmod --reference="$settings" "$tmp"
  # Timestamped, so repeated applies never overwrite the original settings.
  cp -p -- "$settings" "$settings.$(date +%Y%m%d-%H%M%S).bak"
fi
mv -- "$tmp" "$settings"
printf 'Applied preferences to %s\n' "$settings"
