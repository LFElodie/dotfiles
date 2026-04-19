#!/usr/bin/env bash

run_preflight_ubuntu24() {
  require_command git
  require_command ssh
  log_info "preflight checks are available"
}

