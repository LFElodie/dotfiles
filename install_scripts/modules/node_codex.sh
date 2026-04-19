#!/usr/bin/env bash

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MODULE_DIR/../lib/common.sh"

run_node_codex() {
  require_command npm
  ensure_sudo

  sudo npm install -g n
  sudo n stable
  hash -r || true
  sudo npm install -g @openai/codex

  if [[ "${INSTALL_CODEX_AUTH:-1}" == "1" ]]; then
    sudo npm install -g @loongphy/codex-auth
  fi

  cat <<'MSG'
[INFO] Codex CLI installed. Complete interactive authentication manually when needed:
  codex login
MSG
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_node_codex "$@"
fi
