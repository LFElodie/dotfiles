#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

source "$SCRIPT_DIR/modules/preflight_ubuntu24.sh"
source "$SCRIPT_DIR/modules/apt_packages.sh"
source "$SCRIPT_DIR/modules/kitty.sh"
source "$SCRIPT_DIR/modules/starship.sh"
source "$SCRIPT_DIR/modules/oh_my_zsh.sh"
source "$SCRIPT_DIR/modules/zsh_plugins.sh"
source "$SCRIPT_DIR/modules/fcitx5_rime.sh"
source "$SCRIPT_DIR/modules/dotbot.sh"
source "$SCRIPT_DIR/modules/input_method.sh"
source "$SCRIPT_DIR/modules/default_terminal.sh"
source "$SCRIPT_DIR/modules/dev_env.sh"
source "$SCRIPT_DIR/modules/node_codex.sh"
source "$SCRIPT_DIR/modules/obsidian_sync.sh"
source "$SCRIPT_DIR/modules/verify.sh"

main() {
  append_unique_path "$HOME/.local/bin"
  run_step "preflight" run_preflight_ubuntu24
  run_step "apt packages" run_apt_packages
  run_step "kitty" run_kitty
  run_step "starship" run_starship
  run_step "oh my zsh" run_oh_my_zsh
  run_step "zsh plugins" run_zsh_plugins
  run_step "rime-ice repository" setup_rime_repo
  run_step "dotbot" run_dotbot
  run_step "input method" run_input_method
  run_step "Rime deploy" deploy_rime
  run_step "Git config" bash "$DOTFILES_ROOT/set_git.sh"
  run_step "font" bash "$DOTFILES_ROOT/install_scripts/install_font.sh"
  run_step "default terminal" run_default_terminal
  run_step "dev env" run_dev_env
  run_step "node and codex" run_node_codex
  run_step "obsidian sync" run_obsidian_sync
  run_step "verify environment" verify_environment
}

main "$@"
