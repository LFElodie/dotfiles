#!/usr/bin/env bash
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MODULE_DIR/../lib/common.sh"

run_default_terminal() {
  local kitty_bin="${KITTY_BIN:-$HOME/.local/bin/kitty}"

  if [[ ! -x "$kitty_bin" ]]; then
    log_warn "kitty not found at $kitty_bin; skip default terminal setup"
    return 0
  fi

  require_command update-alternatives
  ensure_sudo
  sudo update-alternatives --install \
    /usr/bin/x-terminal-emulator x-terminal-emulator "$kitty_bin" 60
  sudo update-alternatives --set x-terminal-emulator "$kitty_bin"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_default_terminal "$@"
fi
