#!/usr/bin/env bash

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MODULE_DIR/../lib/common.sh"

run_dotbot() {
  (cd "$DOTFILES_ROOT" && ./install)
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_dotbot "$@"
fi
