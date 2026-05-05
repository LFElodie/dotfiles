#!/usr/bin/env bash
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MODULE_DIR/../lib/common.sh"

RIME_REPO_URL="https://github.com/iDvel/rime-ice"
RIME_USER_DIR="$HOME/.local/share/fcitx5/rime"

setup_repo() {
  mkdir -p "$(dirname "$RIME_USER_DIR")"

  if [[ -d "$RIME_USER_DIR/.git" ]]; then
    log_info "rime-ice repo already exists in $RIME_USER_DIR"
    return 0
  fi

  if [[ -e "$RIME_USER_DIR" ]]; then
    local backup="${RIME_USER_DIR}.pre-dotfiles-$(date +%Y%m%d-%H%M%S)"
    log_warn "existing Rime user dir detected, moving to $backup"
    mv "$RIME_USER_DIR" "$backup"
  fi

  log_info "cloning rime-ice into $RIME_USER_DIR"
  git clone --depth 1 "$RIME_REPO_URL" "$RIME_USER_DIR"
}

deploy_rime() {
  if [[ ! -d "$RIME_USER_DIR" ]]; then
    log_warn "skip Rime deploy: $RIME_USER_DIR does not exist"
    return 0
  fi

  if ! command_exists rime_deployer; then
    log_warn "skip Rime deploy: rime_deployer not found"
    return 0
  fi

  mkdir -p "$RIME_USER_DIR/build"
  log_info "deploying Rime config"
  rime_deployer --build "$RIME_USER_DIR" "$RIME_USER_DIR" "$RIME_USER_DIR/build"
  (
    cd "$RIME_USER_DIR"
    rime_deployer --set-active-schema rime_ice
  )
}

main() {
  local action="${1:-}"
  case "$action" in
    setup_repo)
      setup_repo
      ;;
    deploy)
      deploy_rime
      ;;
    *)
      log_error "usage: $0 {setup_repo|deploy}"
      return 1
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
