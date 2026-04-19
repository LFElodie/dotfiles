#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_file() {
  [[ -f "$ROOT/$1" ]] || fail "missing file: $1"
}

assert_executable() {
  [[ -x "$ROOT/$1" ]] || fail "not executable: $1"
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  grep -Fq -- "$pattern" "$ROOT/$file" || fail "$file missing pattern: $pattern"
}

assert_not_contains() {
  local file="$1"
  local pattern="$2"
  if grep -Fq -- "$pattern" "$ROOT/$file"; then
    fail "$file should not contain pattern: $pattern"
  fi
}

modules=(
  preflight_ubuntu24
  apt_packages
  oh_my_zsh
  dotbot
  dev_env
  node_codex
  obsidian_sync
  verify
)

assert_file install_scripts/lib/common.sh
assert_executable install_scripts/bootstrap_ubuntu24.sh
assert_contains install_scripts/bootstrap_ubuntu24.sh "run_preflight_ubuntu24"
assert_contains install_scripts/bootstrap_ubuntu24.sh "run_apt_packages"
assert_contains install_scripts/bootstrap_ubuntu24.sh "run_oh_my_zsh"
assert_contains install_scripts/bootstrap_ubuntu24.sh "run_dotbot"
assert_contains install_scripts/bootstrap_ubuntu24.sh "run_dev_env"
assert_contains install_scripts/bootstrap_ubuntu24.sh "run_node_codex"
assert_contains install_scripts/bootstrap_ubuntu24.sh "run_obsidian_sync"
assert_contains install_scripts/bootstrap_ubuntu24.sh "verify_environment"
assert_not_contains install_scripts/bootstrap_ubuntu24.sh "apt-get install"
assert_not_contains install_scripts/bootstrap_ubuntu24.sh "npm install -g"

for module in "${modules[@]}"; do
  assert_file "install_scripts/modules/${module}.sh"
  assert_contains "install_scripts/modules/${module}.sh" "run_${module}"
  assert_contains "install_scripts/modules/${module}.sh" "common.sh"
done

assert_contains install_scripts/modules/apt_packages.sh "openssh-server"
assert_contains install_scripts/modules/apt_packages.sh "build-essential"
assert_contains install_scripts/modules/apt_packages.sh "clangd"
assert_contains install_scripts/modules/apt_packages.sh "cmake-format"
assert_contains install_scripts/modules/apt_packages.sh "fontconfig"
assert_not_contains install_scripts/modules/apt_packages.sh "ccls"
assert_contains install_scripts/modules/dev_env.sh "DEV_ENV_DIR"
assert_contains install_scripts/modules/dev_env.sh "yapf"
assert_contains install_scripts/modules/dev_env.sh "pyrefly"
assert_contains install_scripts/modules/dev_env.sh "ruff"
assert_not_contains install_scripts/modules/dev_env.sh "cmake-language-server"
assert_contains install_scripts/modules/node_codex.sh "@openai/codex"
assert_contains install_scripts/modules/obsidian_sync.sh "rclone"
assert_executable obsidian/bin/obsidian-sync
assert_executable obsidian/bin/obsidian-sync-init
assert_executable ros2/bin/ros2-ws-sync
assert_executable ros2/bin/ros2-ws-sync-init
assert_file ros2/rclone/ros2-ws-bisync-filter.txt
assert_contains ros2/bin/ros2-ws-sync "gdrive:sync_space/ros2_ws"
assert_contains ros2/bin/ros2-ws-sync-init "--resync"
assert_not_contains ros2/bin/ros2-ws-sync "--create-empty-src-dirs"
assert_not_contains ros2/bin/ros2-ws-sync-init "--create-empty-src-dirs"
assert_contains ros2/rclone/ros2-ws-bisync-filter.txt "- build/**"
assert_contains ros2/rclone/ros2-ws-bisync-filter.txt "- install/**"
assert_contains ros2/rclone/ros2-ws-bisync-filter.txt "- log/**"
assert_contains install.conf.yaml "~/.local/bin/ros2-ws-sync: ros2/bin/ros2-ws-sync"
assert_contains install.conf.yaml "~/.local/bin/ros2-ws-sync-init: ros2/bin/ros2-ws-sync-init"
assert_contains install.conf.yaml "~/.config/rclone/ros2-ws-bisync-filter.txt: ros2/rclone/ros2-ws-bisync-filter.txt"
assert_not_contains install.conf.yaml "ros2-ws-sync-on-login"
[[ ! -e "$ROOT/ccls" ]] || fail "legacy ccls file should be removed"
[[ ! -e "$ROOT/clang-format" ]] || fail "legacy root clang-format file should be removed"
[[ ! -e "$ROOT/.vimspector.json" ]] || fail "legacy vimspector config should be removed"
[[ ! -e "$ROOT/install_packages.sh" ]] || fail "install_packages.sh should be removed"
[[ ! -e "$ROOT/install_scripts/setup_packages.sh" ]] || fail "setup_packages.sh should be removed"
assert_not_contains install.conf.yaml "setup_packages.sh"
assert_contains install_scripts/modules/apt_packages.sh "neovim-ppa/unstable"
assert_contains install_scripts/modules/dev_env.sh "python3 -m venv"
assert_contains install_scripts/modules/oh_my_zsh.sh "CHSH=no"
assert_contains install_scripts/modules/verify.sh "verify_environment"
assert_contains install_scripts/modules/verify.sh "clangd"
assert_contains install_scripts/modules/verify.sh "cmake-format"
assert_contains install_scripts/modules/verify.sh "dotfiles clang-format standard"
assert_contains install_scripts/modules/verify.sh "obsidian-sync executable"
assert_contains install_scripts/modules/verify.sh "obsidian vault directory"

bash -n "$ROOT/install_scripts/bootstrap_ubuntu24.sh"
for module in "${modules[@]}"; do
  bash -n "$ROOT/install_scripts/modules/${module}.sh"
done
bash -n "$ROOT/install_scripts/lib/common.sh"

printf 'bootstrap contract checks passed\n'
