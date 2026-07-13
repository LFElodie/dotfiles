#!/usr/bin/env bash
set -euo pipefail

readonly MAPLE_MONO_VERSION="v7.9"
readonly MAPLE_MONO_SHA256="59098b87c895d871635d37680e88000ae2b2b25b55428195b228ec589e35fb89"
readonly MAPLE_MONO_URL="${MAPLE_MONO_URL:-https://github.com/subframe7536/maple-font/releases/download/${MAPLE_MONO_VERSION}/MapleMono-NF.zip}"
readonly FONT_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
readonly INSTALL_DIR="$FONT_ROOT/MapleMono-NF"
readonly DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly LEGACY_FONT_ROOT="$DOTFILES_ROOT/font"
TEMP_DIR=""

readonly FONT_FILES=(
  MapleMono-NF-Regular.ttf
  MapleMono-NF-Bold.ttf
  MapleMono-NF-Italic.ttf
  MapleMono-NF-BoldItalic.ttf
)

die() {
  printf '错误：%s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [[ -n "$TEMP_DIR" ]]; then
    rm -rf -- "$TEMP_DIR"
  fi
}

resolve_link_target() {
  local link_value
  link_value="$(readlink -- "$1")"
  if [[ "$link_value" == /* ]]; then
    readlink -m -- "$link_value"
  else
    readlink -m -- "$(dirname "$1")/$link_value"
  fi
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "缺少命令：$1"
}

is_installed() {
  [[ -f "$INSTALL_DIR/.version" ]] || return 1
  [[ "$(<"$INSTALL_DIR/.version")" == "$MAPLE_MONO_VERSION" ]] || return 1

  local font_file
  for font_file in "${FONT_FILES[@]}"; do
    [[ -f "$INSTALL_DIR/$font_file" ]] || return 1
  done
}

prepare_font_root() {
  if [[ -L "$FONT_ROOT" ]]; then
    local actual_target expected_target
    actual_target="$(resolve_link_target "$FONT_ROOT")"
    expected_target="$(readlink -m -- "$LEGACY_FONT_ROOT")"
    [[ "$actual_target" == "$expected_target" ]] || \
      die "$FONT_ROOT 是非 dotfiles 管理的符号链接，请手动处理"

    unlink "$FONT_ROOT"
  elif [[ -e "$FONT_ROOT" && ! -d "$FONT_ROOT" ]]; then
    die "$FONT_ROOT 已存在但不是目录"
  fi

  mkdir -p "$FONT_ROOT"
}

install_font() {
  local archive extract_dir staging_dir actual_sha256 font_file
  TEMP_DIR="$(mktemp -d)"
  archive="$TEMP_DIR/MapleMono-NF.zip"
  extract_dir="$TEMP_DIR/extracted"
  staging_dir="$TEMP_DIR/MapleMono-NF"

  printf '正在下载 Maple Mono NF %s...\n' "$MAPLE_MONO_VERSION"
  curl -fL --retry 3 --connect-timeout 10 -o "$archive" "$MAPLE_MONO_URL"

  actual_sha256="$(sha256sum "$archive" | awk '{print $1}')"
  [[ "$actual_sha256" == "$MAPLE_MONO_SHA256" ]] || \
    die "字体包 SHA-256 校验失败"

  mkdir -p "$extract_dir" "$staging_dir"
  unzip -q -j "$archive" "${FONT_FILES[@]}" -d "$extract_dir"

  for font_file in "${FONT_FILES[@]}"; do
    [[ -f "$extract_dir/$font_file" ]] || die "字体包缺少 $font_file"
    install -m 0644 "$extract_dir/$font_file" "$staging_dir/$font_file"
  done
  printf '%s\n' "$MAPLE_MONO_VERSION" >"$staging_dir/.version"

  prepare_font_root
  [[ ! -L "$INSTALL_DIR" ]] || die "$INSTALL_DIR 不应是符号链接"
  rm -rf -- "$INSTALL_DIR"
  mv "$staging_dir" "$INSTALL_DIR"
}

main() {
  require_command curl
  require_command fc-cache
  require_command install
  require_command sha256sum
  require_command unzip

  if is_installed; then
    printf 'Maple Mono NF %s 已安装，跳过下载。\n' "$MAPLE_MONO_VERSION"
  else
    install_font
  fi

  printf '正在刷新字体缓存...\n'
  fc-cache -f "$FONT_ROOT"
  printf 'Maple Mono NF %s 安装完成。\n' "$MAPLE_MONO_VERSION"
}

trap cleanup EXIT
main "$@"
