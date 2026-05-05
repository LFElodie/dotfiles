#!/usr/bin/env bash
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MODULE_DIR/../lib/common.sh"

ZSH_CUSTOM_DIR="$HOME/.local/share/oh-my-zsh/custom"
ZSH_PLUGINS_DIR="$ZSH_CUSTOM_DIR/plugins"

ZSH_PLUGIN_SPECS=(
  "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git"
  "zsh-completions|https://github.com/zsh-users/zsh-completions.git"
  "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

clone_plugin() {
  local name="$1"
  local url="$2"
  local target="$ZSH_PLUGINS_DIR/$name"

  if [[ -d "$target/.git" ]]; then
    log_info "zsh plugin already exists: $target"
    return 0
  fi

  if [[ -e "$target" ]]; then
    log_warn "skip zsh plugin clone, target exists and is not a git repo: $target"
    return 0
  fi

  log_info "cloning zsh plugin $name"
  git clone --depth 1 "$url" "$target"
}

update_plugin() {
  local name="$1"
  local target="$ZSH_PLUGINS_DIR/$name"

  if [[ ! -d "$target/.git" ]]; then
    log_warn "skip zsh plugin update, repo missing: $target"
    return 0
  fi

  if [[ -n "$(git -C "$target" status --porcelain)" ]]; then
    log_warn "skip zsh plugin update, local changes detected: $target"
    return 0
  fi

  log_info "updating zsh plugin $name"
  git -C "$target" pull --ff-only
}

setup_repo() {
  require_command git
  mkdir -p "$ZSH_PLUGINS_DIR"

  local spec name url
  for spec in "${ZSH_PLUGIN_SPECS[@]}"; do
    IFS='|' read -r name url <<<"$spec"
    clone_plugin "$name" "$url"
  done
}

update_plugins() {
  require_command git
  mkdir -p "$ZSH_PLUGINS_DIR"

  local spec name url
  for spec in "${ZSH_PLUGIN_SPECS[@]}"; do
    IFS='|' read -r name url <<<"$spec"
    update_plugin "$name"
  done
}

run_zsh_plugins() {
  setup_repo
}

main() {
  local action="${1:-}"
  case "$action" in
    setup_repo)
      setup_repo
      ;;
    update)
      update_plugins
      ;;
    *)
      log_error "usage: $0 {setup_repo|update}"
      return 1
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
