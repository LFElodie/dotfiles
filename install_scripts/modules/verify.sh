#!/usr/bin/env bash

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MODULE_DIR/../lib/common.sh"

VERIFY_FAILURES=0

verify_required() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    printf '[PASS] %s\n' "$label"
  else
    printf '[FAIL] %s\n' "$label" >&2
    VERIFY_FAILURES=$((VERIFY_FAILURES + 1))
  fi
}

verify_optional() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    printf '[PASS] %s\n' "$label"
  else
    printf '[WARN] %s\n' "$label" >&2
  fi
}

verify_default_terminal() {
  local expected
  local selected

  expected="$(readlink -f "$HOME/.local/bin/kitty")"
  selected="$(update-alternatives --query x-terminal-emulator 2>/dev/null \
    | awk -F': ' '$1 == "Value" {print $2}')"
  [[ -n "$selected" && "$(readlink -f "$selected")" == "$expected" ]]
}

verify_git_pager() {
  [[ "$(git config --global core.pager)" == "delta" \
    && "$(git config --global pager.log)" == "delta" ]]
}

report_graphical_session() {
  local session_type="${XDG_SESSION_TYPE:-}"

  if [[ ! "$session_type" =~ ^(x11|wayland)$ ]] && command_exists loginctl; then
    session_type="$(loginctl list-sessions --no-legend 2>/dev/null \
      | awk -v user="$USER" '$3 == user {print $1}' \
      | while read -r session_id; do
          loginctl show-session "$session_id" -p Type --value 2>/dev/null
        done \
      | grep -E '^(x11|wayland)$' \
      | head -n 1 || true)"
  fi

  if [[ "$session_type" =~ ^(x11|wayland)$ ]]; then
    printf '[INFO] graphical session: %s\n' "$session_type"
  else
    printf '[INFO] graphical session: unavailable (for example, SSH or TTY)\n'
  fi
}

verify_environment() {
  VERIFY_FAILURES=0
  report_graphical_session

  verify_required "git" git --version
  verify_required "zsh" zsh --version
  verify_required "Oh My Zsh" test -d "$HOME/.oh-my-zsh"
  verify_required "zshrc link" test -L "$HOME/.zshrc"
  verify_required "Starship" starship --version
  verify_required "Starship config link" test -L "$HOME/.config/starship.toml"
  verify_required "zoxide" zoxide --version
  verify_required "fzf-tab" test -d "$HOME/.local/share/oh-my-zsh/custom/plugins/fzf-tab"
  verify_required "direnv" direnv version
  verify_required "git-delta" delta --version
  verify_required "Git pager uses delta" verify_git_pager
  verify_required "fd compatibility command" fd --version
  verify_required "Kitty" "$HOME/.local/bin/kitty" --version
  verify_required "Kitty config link" test -L "$HOME/.config/kitty/kitty.conf"
  verify_required "Kitty desktop entry" test -f "$HOME/.local/share/applications/kitty.desktop"
  verify_required "Kitty default terminal" verify_default_terminal
  verify_required "input method environment link" test -L "$HOME/.config/environment.d/im.conf"
  verify_required "GLFW X11 input method" grep -Fxq 'GLFW_IM_MODULE=ibus' "$HOME/.config/environment.d/im.conf"
  verify_required "PAM GLFW X11 input method" grep -Fxq 'GLFW_IM_MODULE DEFAULT=ibus' "$HOME/.pam_environment"
  verify_required "Fcitx5 profile" test -f "$HOME/.config/fcitx5/profile"
  verify_required "Fcitx5 selected by im-config" grep -Eq '^run_im fcitx5$' "$HOME/.xinputrc"
  verify_required "ROS2 workspace envrc link" test -L "$HOME/ros2_ws/.envrc"
  verify_required "dev_env yapf" test -x "$HOME/dev_env/bin/yapf"
  verify_required "dev_env pyrefly" test -x "$HOME/dev_env/bin/pyrefly"
  verify_required "dev_env ruff" test -x "$HOME/dev_env/bin/ruff"
  verify_required "dev_env dependency consistency" "$HOME/dev_env/bin/python" -m pip check
  verify_required "nvim" nvim --version
  verify_required "tmux" tmux -V
  verify_required "clangd" clangd --version
  verify_required "cmake-format" cmake-format --version
  verify_required "Fcitx5 Rime 状态重置插件" test -L "$HOME/.local/share/fcitx5/addon/rime_state_reset.conf"
  verify_required "Fcitx5 Rime 状态重置脚本" test -L "$HOME/.local/share/fcitx5/lua/rime_state_reset/main.lua"
  verify_required "node" node --version
  verify_required "npm" npm --version
  verify_required "codex" codex --version
  verify_required "rclone" rclone version
  verify_required "obsidian-sync link" test -L "$HOME/.local/bin/obsidian-sync"
  verify_required "obsidian-sync executable" test -x "$HOME/.local/bin/obsidian-sync"
  verify_required "dotfiles yapf standard" test -f "$DOTFILES_ROOT/ros2/.style.yapf"
  verify_required "dotfiles clang-format standard" test -f "$DOTFILES_ROOT/ros2/.clang-format"
  verify_required "dotfiles cmake-format standard" test -f "$DOTFILES_ROOT/ros2/cmake-format.yaml"
  verify_required "obsidian sync service enabled" systemctl --user is-enabled obsidian-sync-on-login.service

  verify_optional "rclone gdrive authorization" bash -c 'rclone listremotes | grep -Fxq "gdrive:"'
  verify_optional "Obsidian vault directory" test -d "$HOME/Documents/Obsidian Vault"

  if (( VERIFY_FAILURES > 0 )); then
    log_error "$VERIFY_FAILURES required environment checks failed"
    return 1
  fi

  log_info "all required environment checks passed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  append_unique_path "$HOME/.local/bin"
  verify_environment "$@"
fi
