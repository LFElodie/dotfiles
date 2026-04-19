#!/usr/bin/env bash

run_apt_packages() {
  local packages=(
    openssh-server
    build-essential
  )
  log_info "apt package module ready: ${packages[*]}"
}

