#!/usr/bin/env bash

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MODULE_DIR/../lib/common.sh"

run_verify() {
  verify_environment
}

verify_command() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    printf '[PASS] %s\n' "$label"
  else
    printf '[WARN] %s\n' "$label"
  fi
}

verify_environment() {
  verify_command "git" git --version
  verify_command "GitHub SSH" ssh -T git@github.com
  verify_command "zsh" zsh --version
  verify_command "Oh My Zsh" test -d "$HOME/.oh-my-zsh"
  verify_command "zshrc link" test -L "$HOME/.zshrc"
  verify_command "dev_env yapf" test -x "$HOME/dev_env/bin/yapf"
  verify_command "dev_env pyrefly" test -x "$HOME/dev_env/bin/pyrefly"
  verify_command "dev_env ruff" test -x "$HOME/dev_env/bin/ruff"
  verify_command "nvim" nvim --version
  verify_command "tmux" tmux -V
  verify_command "node" node --version
  verify_command "npm" npm --version
  verify_command "codex" codex --version
  verify_command "rclone" rclone version
  verify_command "rclone gdrive remote" bash -c 'rclone listremotes | grep -Fxq "gdrive:"'
  verify_command "obsidian-sync link" test -L "$HOME/.local/bin/obsidian-sync"
  verify_command "dotfiles yapf standard" test -f "$DOTFILES_ROOT/ros2/.style.yapf"
  verify_command "dotfiles cmake-format standard" test -f "$DOTFILES_ROOT/ros2/cmake-format.yaml"
  verify_command "obsidian sync service enabled" systemctl --user is-enabled obsidian-sync-on-login.service
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_verify "$@"
fi
