#!/usr/bin/env bash

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MODULE_DIR/../lib/common.sh"

run_preflight_ubuntu24() {
  require_command bash
  require_command git
  require_command ssh
  require_command curl

  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "24.04" ]]; then
      log_warn "expected Ubuntu 24.04, found ${PRETTY_NAME:-unknown system}"
    else
      log_info "system target confirmed: ${PRETTY_NAME}"
    fi
  else
    log_warn "cannot read /etc/os-release"
  fi

  ensure_sudo

  if curl --head --silent --fail --max-time 10 https://github.com >/dev/null; then
    log_info "network check passed: github.com reachable"
  else
    log_warn "github.com is not reachable now; later git/npm steps may fail"
  fi

  if ssh -T -o BatchMode=yes -o ConnectTimeout=10 git@github.com >/tmp/dotfiles-github-ssh-check.log 2>&1; then
    log_info "GitHub SSH check passed"
  else
    local rc=$?
    if grep -Fq "successfully authenticated" /tmp/dotfiles-github-ssh-check.log 2>/dev/null; then
      log_info "GitHub SSH check passed"
    else
      log_warn "GitHub SSH check did not pass yet; confirm SSH key setup before cloning private repos"
      log_warn "ssh output: $(tr '\n' ' ' </tmp/dotfiles-github-ssh-check.log 2>/dev/null || true)"
      return "$rc"
    fi
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_preflight_ubuntu24 "$@"
fi
