#!/usr/bin/env bash

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MODULE_DIR/../lib/common.sh"

DEV_ENV_DIR="${DEV_ENV_DIR:-$HOME/dev_env}"

run_dev_env() {
  local tools=(
    pynvim
    yapf
    ruff
    pyrefly
    debugpy
    cpplint
  )

  require_command python3

  if [[ ! -x "$DEV_ENV_DIR/bin/python" ]]; then
    python3 -m venv "$DEV_ENV_DIR"
  fi

  "$DEV_ENV_DIR/bin/python" -m pip install --upgrade pip setuptools wheel
  "$DEV_ENV_DIR/bin/python" -m pip install --upgrade "${tools[@]}"

  log_info "Python development environment ready: $DEV_ENV_DIR"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_dev_env "$@"
fi
