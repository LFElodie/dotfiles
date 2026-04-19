#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

source "$SCRIPT_DIR/modules/preflight_ubuntu24.sh"
source "$SCRIPT_DIR/modules/apt_packages.sh"
source "$SCRIPT_DIR/modules/oh_my_zsh.sh"
source "$SCRIPT_DIR/modules/dotbot.sh"
source "$SCRIPT_DIR/modules/dev_env.sh"
source "$SCRIPT_DIR/modules/node_codex.sh"
source "$SCRIPT_DIR/modules/obsidian_sync.sh"
source "$SCRIPT_DIR/modules/verify.sh"

main() {
  run_step "preflight" run_preflight_ubuntu24
  run_step "apt packages" run_apt_packages
  run_step "oh my zsh" run_oh_my_zsh
  run_step "dotbot" run_dotbot
  run_step "dev env" run_dev_env
  run_step "node and codex" run_node_codex
  run_step "obsidian sync" run_obsidian_sync
  run_step "verify environment" verify_environment
}

main "$@"

