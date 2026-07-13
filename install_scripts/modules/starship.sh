#!/usr/bin/env bash
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MODULE_DIR/../lib/common.sh"

STARSHIP_VERSION="${STARSHIP_VERSION:-v1.26.0}"
STARSHIP_BIN_DIR="${STARSHIP_BIN_DIR:-$HOME/.local/bin}"

run_starship() {
  local starship_bin="$STARSHIP_BIN_DIR/starship"
  local expected_version="${STARSHIP_VERSION#v}"
  local current_version=""

  if [[ -x "$starship_bin" ]]; then
    current_version="$($starship_bin --version | awk 'NR == 1 { print $2 }')"
  fi

  if [[ "$current_version" == "$expected_version" ]]; then
    log_info "Starship already installed: $current_version"
    return 0
  fi

  require_command curl
  require_command sh
  mkdir -p "$STARSHIP_BIN_DIR"

  local installer
  local rc
  installer="$(mktemp)"
  if curl -fsSL https://starship.rs/install.sh -o "$installer" \
    && sh "$installer" --yes --bin-dir "$STARSHIP_BIN_DIR" --version "$STARSHIP_VERSION"; then
    rc=0
  else
    rc=$?
  fi
  rm -f "$installer"

  if (( rc != 0 )); then
    log_error "Starship installation failed"
    return "$rc"
  fi

  log_info "Starship installed: $STARSHIP_VERSION"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_starship "$@"
fi
