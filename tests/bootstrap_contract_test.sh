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
  starship
  oh_my_zsh
  zsh_plugins
  dotbot
  dev_env
  node_codex
  obsidian_sync
  verify
)

assert_file install_scripts/lib/common.sh
assert_file install_scripts/install_font.sh
assert_executable install_scripts/bootstrap_ubuntu24.sh
assert_contains install_scripts/bootstrap_ubuntu24.sh "run_preflight_ubuntu24"
assert_contains install_scripts/bootstrap_ubuntu24.sh "run_apt_packages"
assert_contains install_scripts/bootstrap_ubuntu24.sh "run_starship"
assert_contains install_scripts/bootstrap_ubuntu24.sh "run_oh_my_zsh"
assert_contains install_scripts/bootstrap_ubuntu24.sh "run_zsh_plugins"
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
assert_contains install_scripts/modules/apt_packages.sh "zoxide"
assert_contains install_scripts/modules/apt_packages.sh "direnv"
assert_contains install_scripts/modules/apt_packages.sh "git-delta"
assert_not_contains install_scripts/modules/apt_packages.sh "autojump"
assert_contains install_scripts/modules/starship.sh "v1.26.0"
assert_contains install_scripts/modules/starship.sh "https://starship.rs/install.sh"
assert_contains install_scripts/modules/zsh_plugins.sh "Aloxaf/fzf-tab"
assert_contains install_scripts/install_font.sh 'readonly MAPLE_MONO_VERSION="v7.9"'
assert_contains install_scripts/install_font.sh 'readonly MAPLE_MONO_SHA256='
assert_contains install_scripts/install_font.sh "MapleMono-NF-Regular.ttf"
assert_contains install_scripts/install_font.sh "MapleMono-NF-Bold.ttf"
assert_contains install_scripts/install_font.sh "MapleMono-NF-Italic.ttf"
assert_contains install_scripts/install_font.sh "MapleMono-NF-BoldItalic.ttf"
assert_not_contains install.conf.yaml "~/.local/share/fonts:"
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
assert_file obsidian/rclone/obsidian-bisync-filter.txt
assert_contains obsidian/bin/obsidian-sync-init "--resync"
assert_contains obsidian/bin/obsidian-sync-init "这不是日常同步命令"
assert_contains obsidian/bin/obsidian-sync-init "Path1 本地文件可能覆盖 Path2 云端版本"
assert_contains obsidian/bin/obsidian-sync-init "请输入 y 继续"
assert_contains obsidian/bin/obsidian-sync-init "read -r confirm"
assert_contains obsidian/bin/obsidian-sync-init '"${confirm}" == "y"'
assert_contains obsidian/bin/obsidian-sync-init "已取消 Obsidian 同步状态重建。"
assert_not_contains obsidian/bin/obsidian-sync-init "--create-empty-src-dirs"
assert_file ros2/rclone/ros2-ws-bisync-filter.txt
assert_contains ros2/bin/ros2-ws-sync "gdrive:sync_space/ros2_ws"
assert_contains ros2/bin/ros2-ws-sync-init "--resync"
assert_contains ros2/bin/ros2-ws-sync-init "这不是日常同步命令"
assert_contains ros2/bin/ros2-ws-sync-init "Path1 本地文件可能覆盖 Path2 云端版本"
assert_contains ros2/bin/ros2-ws-sync-init "请输入 y 继续"
assert_contains ros2/bin/ros2-ws-sync-init "read -r confirm"
assert_contains ros2/bin/ros2-ws-sync-init '"${confirm}" == "y"'
assert_contains ros2/bin/ros2-ws-sync-init "已取消 ros2_ws 同步状态重建。"
assert_not_contains ros2/bin/ros2-ws-sync "--create-empty-src-dirs"
assert_not_contains ros2/bin/ros2-ws-sync-init "--create-empty-src-dirs"
assert_contains ros2/rclone/ros2-ws-bisync-filter.txt "- build/**"
assert_contains ros2/rclone/ros2-ws-bisync-filter.txt "- install/**"
assert_contains ros2/rclone/ros2-ws-bisync-filter.txt "- log/**"
assert_contains install.conf.yaml "bash install_scripts/modules/zsh_plugins.sh setup_repo"
assert_contains install.conf.yaml "~/.local/bin/ros2-ws-sync: ros2/bin/ros2-ws-sync"
assert_contains install.conf.yaml "~/.local/bin/ros2-ws-sync-init: ros2/bin/ros2-ws-sync-init"
assert_contains install.conf.yaml "~/.config/starship.toml: starship/starship.toml"
assert_contains install.conf.yaml "~/.local/bin/fd: bin/fd"
assert_contains install.conf.yaml "~/ros2_ws/.envrc: ros2/envrc"
assert_contains install.conf.yaml "~/.config/rclone/ros2-ws-bisync-filter.txt: ros2/rclone/ros2-ws-bisync-filter.txt"
assert_not_contains install.conf.yaml "~/.oh-my-zsh/custom/plugins:"
assert_not_contains install.conf.yaml "zsh/custom/plugins/*"
assert_not_contains .gitmodules "submodule.zsh/custom/plugins/zsh-autosuggestions"
assert_not_contains .gitmodules "submodule.zsh/custom/plugins/zsh-completions"
assert_not_contains .gitmodules "submodule.zsh/custom/plugins/zsh-syntax-highlighting"
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
assert_contains zsh/zshrc 'export ZSH_CUSTOM="$HOME/.local/share/oh-my-zsh/custom"'
assert_contains zsh/zshrc 'ZSH_THEME=""'
assert_contains zsh/zshrc 'fpath=("$ZSH_CUSTOM/plugins/zsh-completions/src" $fpath)'
assert_contains zsh/zshrc "fzf-tab"
assert_contains zsh/zshrc "direnv"
assert_contains zsh/zshrc 'eval "$(zoxide init zsh)"'
assert_contains zsh/zshrc 'eval "$(starship init zsh)"'
assert_contains zsh/zshrc "ros2_on()"
assert_contains zsh/zshrc 'if _dotfiles_ros2_setup_file "$HOME/ros2_ws"; then'
assert_contains zsh/zshrc "add-zsh-hook precmd _dotfiles_ros2_completions"
assert_contains zsh/zshrc 'typeset -U path PATH'
assert_contains zsh/zshrc 'path=(${path:#/usr/include})'
assert_contains zsh/zshrc 'path=(${path:#/usr/bin/})'
assert_contains zsh/zshrc 'LD_LIBRARY_PATH="/usr/local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"'
assert_contains zsh/zshrc 'GAZEBO_MODEL_PATH="${GAZEBO_MODEL_PATH:+$GAZEBO_MODEL_PATH:}$HOME/.gazebo/models"'
assert_not_contains zsh/zshrc 'source /opt/ros/jazzy/setup.zsh'
assert_not_contains zsh/zshrc 'register-python-argcomplete ros2'
assert_not_contains zsh/zshrc 'PATH="$PATH:/usr/include/"'
assert_not_contains zsh/zshrc 'open -a typora'
assert_not_contains zsh/zshrc "autojump"
assert_file starship/starship.toml
assert_contains starship/starship.toml '[custom.ros]'
assert_file ros2/envrc
assert_contains ros2/envrc 'source "$workspace_setup"'
assert_executable bin/fd
assert_contains bin/fd 'exec fdfind "$@"'
assert_file ranger/plugins/zoxide.py
[[ ! -e "$ROOT/ranger/plugins/autojump.py" ]] || fail "legacy Ranger autojump plugin should be removed"
assert_contains ranger/plugins/zoxide.py '["zoxide", "query", "--", self.arg(1)]'
assert_contains set_git.sh "core.pager delta"
assert_contains set_git.sh "delta.line-numbers true"
assert_contains set_git.sh "merge.conflictStyle zdiff3"
assert_contains install_scripts/modules/verify.sh "verify_environment"
assert_contains install_scripts/modules/verify.sh "Starship config link"
assert_contains install_scripts/modules/verify.sh "ROS2 workspace envrc link"
assert_contains install_scripts/modules/verify.sh "clangd"
assert_contains install_scripts/modules/verify.sh "cmake-format"
assert_contains install_scripts/modules/verify.sh "dotfiles clang-format standard"
assert_contains install_scripts/modules/verify.sh "obsidian-sync executable"
assert_contains install_scripts/modules/verify.sh "obsidian vault directory"

bash -n "$ROOT/install_scripts/bootstrap_ubuntu24.sh"
bash -n "$ROOT/install_scripts/install_font.sh"
for module in "${modules[@]}"; do
  bash -n "$ROOT/install_scripts/modules/${module}.sh"
done
bash -n "$ROOT/install_scripts/lib/common.sh"
bash -n "$ROOT/ros2/envrc"
bash -n "$ROOT/bin/fd"
bash -n "$ROOT/set_git.sh"
zsh -n "$ROOT/zsh/zshrc"

syntax_highlighting_line="$(grep -n 'zsh-syntax-highlighting' "$ROOT/zsh/zshrc" | head -n 1 | cut -d: -f1)"
autosuggestions_line="$(grep -n 'zsh-autosuggestions' "$ROOT/zsh/zshrc" | head -n 1 | cut -d: -f1)"
fzf_tab_line="$(grep -n 'fzf-tab' "$ROOT/zsh/zshrc" | head -n 1 | cut -d: -f1)"
(( syntax_highlighting_line > autosuggestions_line )) \
  || fail "zsh-syntax-highlighting should load after zsh-autosuggestions"
(( syntax_highlighting_line > fzf_tab_line )) \
  || fail "zsh-syntax-highlighting should load after fzf-tab"

printf 'bootstrap contract checks passed\n'
