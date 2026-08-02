#!/usr/bin/env bash
set -euo pipefail

readonly CONFIG="install.conf.yaml"
readonly DOTBOT_DIR="dotbot"
readonly DOTBOT_BREW_DIR="dotbot-brew"
readonly DOTBOT_BIN="bin/dotbot"
readonly DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$DOTFILES_ROOT"
git -C "$DOTBOT_DIR" submodule sync --quiet --recursive
git submodule sync --quiet --recursive

submodules=("$DOTBOT_DIR")
if git ls-files --stage -- "$DOTBOT_BREW_DIR" | grep -q '^160000 '; then
  submodules+=("$DOTBOT_BREW_DIR")
fi

git submodule update --init --recursive "${submodules[@]}"

dotbot_args=(
  -d "$DOTFILES_ROOT"
  -c "$CONFIG"
  "$@"
)

if [[ -d "$DOTFILES_ROOT/$DOTBOT_BREW_DIR" ]]; then
  dotbot_args=(--plugin-dir "$DOTBOT_BREW_DIR" "${dotbot_args[@]}")
fi

"$DOTFILES_ROOT/$DOTBOT_DIR/$DOTBOT_BIN" "${dotbot_args[@]}"
