#!/usr/bin/env bash
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MODULE_DIR/../lib/common.sh"

run_input_method() {
  local profile_source="$DOTFILES_ROOT/fcitx5/profile"
  local profile_target="$HOME/.config/fcitx5/profile"

  require_command im-config
  require_command install
  mkdir -p "$(dirname "$profile_target")"

  # profile 会被 Fcitx5 自行改写，因此部署为普通文件而不是符号链接。
  install -m 0644 "$profile_source" "$profile_target"
  im-config -n fcitx5

  log_info "Fcitx5 configured; re-login to refresh the graphical session environment"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_input_method "$@"
fi
