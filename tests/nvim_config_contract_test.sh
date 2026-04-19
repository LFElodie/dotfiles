#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

contains() {
  grep -Fq -- "$2" "$ROOT/$1" || fail "$1 missing pattern: $2"
}

not_contains() {
  if grep -Fq -- "$2" "$ROOT/$1"; then
    fail "$1 should not contain pattern: $2"
  fi
}

[[ -f "$ROOT/ros2/.style.yapf" ]] || fail "missing ros2/.style.yapf"
[[ -f "$ROOT/ros2/cmake-format.yaml" ]] || fail "missing ros2/cmake-format.yaml"
contains ros2/.style.yapf "based_on_style = google"
contains ros2/.style.yapf "column_limit = 120"
contains ros2/cmake-format.yaml "tab_size: 2"
contains lua/plugins/lsp.lua "dev_env"
contains lua/plugins/lsp.lua "yapf"
contains lua/plugins/lsp.lua ".style.yapf"
contains lua/plugins/lsp.lua "pyrefly"
contains lua/plugins/lsp.lua "ruff"
not_contains lua/plugins/lsp.lua "dev_venv"
not_contains lua/plugins/lsp.lua "lyenv"
not_contains lua/plugins/lsp.lua "ruff format --line-length"
contains lua/plugins/telescope.lua "dev_env"
not_contains lua/plugins/telescope.lua "dev_venv"

printf 'nvim config contract checks passed\n'
