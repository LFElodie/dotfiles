#!/usr/bin/env bash
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MODULE_DIR/../lib/common.sh"

KITTY_INSTALLER_URL="${KITTY_INSTALLER_URL:-https://sw.kovidgoyal.net/kitty/installer.sh}"
KITTY_INSTALL_DIR="${KITTY_INSTALL_DIR:-$HOME/.local/kitty.app}"
KITTY_BIN_DIR="${KITTY_BIN_DIR:-$HOME/.local/bin}"
KITTY_APPLICATIONS_DIR="${KITTY_APPLICATIONS_DIR:-$HOME/.local/share/applications}"

install_kitty_desktop_files() {
  local desktop_file
  local kitty_dir

  mkdir -p "$KITTY_BIN_DIR" "$KITTY_APPLICATIONS_DIR"
  ln -sfn "$KITTY_INSTALL_DIR/bin/kitty" "$KITTY_BIN_DIR/kitty"
  ln -sfn "$KITTY_INSTALL_DIR/bin/kitten" "$KITTY_BIN_DIR/kitten"

  kitty_dir="$(readlink -f "$KITTY_INSTALL_DIR")"
  for desktop_file in kitty.desktop kitty-open.desktop; do
    if [[ -f "$KITTY_INSTALL_DIR/share/applications/$desktop_file" ]]; then
      cp -f \
        "$KITTY_INSTALL_DIR/share/applications/$desktop_file" \
        "$KITTY_APPLICATIONS_DIR/$desktop_file"
      sed -i \
        -e "s|Icon=kitty|Icon=$kitty_dir/share/icons/hicolor/256x256/apps/kitty.png|g" \
        -e "s|Exec=kitty|Exec=$kitty_dir/bin/kitty|g" \
        "$KITTY_APPLICATIONS_DIR/$desktop_file"
    fi
  done

  if command_exists update-desktop-database; then
    update-desktop-database "$KITTY_APPLICATIONS_DIR" >/dev/null 2>&1 || true
  fi
}

run_kitty() {
  local installer
  local rc

  require_command curl
  require_command sh
  require_command readlink
  require_command cp
  require_command ln
  require_command sed

  installer="$(mktemp)"
  if curl -fsSL "$KITTY_INSTALLER_URL" -o "$installer" \
    && sh "$installer" launch=n dest="$KITTY_INSTALL_DIR"; then
    rc=0
  else
    rc=$?
  fi
  rm -f "$installer"

  if (( rc != 0 )); then
    log_error "Kitty installation failed"
    return "$rc"
  fi

  install_kitty_desktop_files
  log_info "Kitty installed: $($KITTY_BIN_DIR/kitty --version | head -n 1)"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_kitty "$@"
fi
