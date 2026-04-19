#!/usr/bin/env bash

DEV_ENV_DIR="${DEV_ENV_DIR:-$HOME/dev_env}"

run_dev_env() {
  local tools=(
    yapf
    pyrefly
    ruff
  )
  log_info "dev env module ready at $DEV_ENV_DIR: ${tools[*]}"
}

