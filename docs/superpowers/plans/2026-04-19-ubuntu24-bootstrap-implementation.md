# Ubuntu 24.04 Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现 Ubuntu 24.04 基础环境恢复的模块化 bootstrap，并同步更新 nvim、格式化标准和恢复手册。

**Architecture:** `install_scripts/bootstrap_ubuntu24.sh` 只做编排；具体逻辑放入 `install_scripts/modules/*.sh`，公共函数放入 `install_scripts/lib/common.sh`。测试使用自包含 Bash contract tests 验证脚本结构、模块入口、关键配置和 nvim 文本行为，避免在当前机器真实执行 apt/npm/sudo。

**Tech Stack:** Bash、dotbot YAML、Neovim Lua、Obsidian Markdown、rclone/systemd user service。

---

### Task 1: 添加模块化 bootstrap 骨架和合同测试

**Files:**
- Create: `install_scripts/bootstrap_ubuntu24.sh`
- Create: `install_scripts/lib/common.sh`
- Create: `install_scripts/modules/preflight_ubuntu24.sh`
- Create: `install_scripts/modules/apt_packages.sh`
- Create: `install_scripts/modules/oh_my_zsh.sh`
- Create: `install_scripts/modules/dotbot.sh`
- Create: `install_scripts/modules/dev_env.sh`
- Create: `install_scripts/modules/node_codex.sh`
- Create: `install_scripts/modules/obsidian_sync.sh`
- Create: `install_scripts/modules/verify.sh`
- Create: `tests/bootstrap_contract_test.sh`

- [ ] **Step 1: 写失败的合同测试**

Create `tests/bootstrap_contract_test.sh` with checks for:

```bash
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
done

assert_contains install_scripts/modules/apt_packages.sh "openssh-server"
assert_contains install_scripts/modules/apt_packages.sh "build-essential"
assert_contains install_scripts/modules/dev_env.sh "DEV_ENV_DIR"
assert_contains install_scripts/modules/dev_env.sh "yapf"
assert_contains install_scripts/modules/dev_env.sh "pyrefly"
assert_contains install_scripts/modules/dev_env.sh "ruff"
assert_contains install_scripts/modules/node_codex.sh "@openai/codex"
assert_contains install_scripts/modules/obsidian_sync.sh "rclone"

bash -n "$ROOT/install_scripts/bootstrap_ubuntu24.sh"
for module in "${modules[@]}"; do
  bash -n "$ROOT/install_scripts/modules/${module}.sh"
done
bash -n "$ROOT/install_scripts/lib/common.sh"

printf 'bootstrap contract checks passed\n'
```

- [ ] **Step 2: 运行测试确认失败**

Run: `bash tests/bootstrap_contract_test.sh`

Expected: FAIL because `install_scripts/bootstrap_ubuntu24.sh` does not exist yet.

- [ ] **Step 3: 实现最小模块骨架**

Create modules with strict Bash mode, source `lib/common.sh`, and provide `run_<module>` plus verification helpers where relevant. `bootstrap_ubuntu24.sh` loads modules and calls them in order.

- [ ] **Step 4: 运行测试确认通过**

Run: `bash tests/bootstrap_contract_test.sh`

Expected: `bootstrap contract checks passed`

- [ ] **Step 5: 提交**

```bash
git add install_scripts tests/bootstrap_contract_test.sh
git commit -m "feat: add modular ubuntu24 bootstrap skeleton"
```

### Task 2: 实现模块逻辑并精简旧脚本

**Files:**
- Modify: `install_scripts/modules/*.sh`
- Delete: `install_packages.sh`
- Delete: `install_scripts/setup_packages.sh`
- Modify: `install.conf.yaml`

- [ ] **Step 1: 扩展合同测试**

Add checks to `tests/bootstrap_contract_test.sh`:

```bash
[[ ! -e "$ROOT/install_packages.sh" ]] || fail "install_packages.sh should be removed"
[[ ! -e "$ROOT/install_scripts/setup_packages.sh" ]] || fail "setup_packages.sh should be removed"
assert_not_contains install.conf.yaml "setup_packages.sh"
assert_contains install_scripts/modules/apt_packages.sh "neovim-ppa/unstable"
assert_contains install_scripts/modules/dev_env.sh "python3 -m venv"
assert_contains install_scripts/modules/oh_my_zsh.sh "CHSH=no"
assert_contains install_scripts/modules/verify.sh "verify_environment"
```

- [ ] **Step 2: 运行测试确认失败**

Run: `bash tests/bootstrap_contract_test.sh`

Expected: FAIL because old scripts still exist and modules are incomplete.

- [ ] **Step 3: 实现模块逻辑**

Implement:

- apt module with Ubuntu 24.04 package list, including `openssh-server`, `build-essential`, `unzip`, `wget`, `rclone`.
- Oh My Zsh module with non-interactive install and no forced shell switching.
- dotbot module that runs `./install`.
- dev_env module that creates `~/dev_env` and installs `pynvim yapf ruff pyrefly debugpy cmake-language-server cpplint`.
- node_codex module that installs `n`, stable Node, `@openai/codex`, and optional `@loongphy/codex-auth`.
- obsidian module that checks `gdrive:` and enables the existing user service when possible.
- verify module with actionable pass/warn output.

- [ ] **Step 4: 删除旧入口并清理 dotbot 配置**

Delete `install_packages.sh` and `install_scripts/setup_packages.sh`; remove commented `setup_packages.sh` entry from `install.conf.yaml`. Keep `install_scripts/setup_mirrors.sh` as optional.

- [ ] **Step 5: 运行测试确认通过**

Run: `bash tests/bootstrap_contract_test.sh`

Expected: `bootstrap contract checks passed`

- [ ] **Step 6: 提交**

```bash
git add install_scripts install.conf.yaml tests/bootstrap_contract_test.sh
git rm install_packages.sh install_scripts/setup_packages.sh
git commit -m "feat: implement ubuntu24 bootstrap modules"
```

### Task 3: 纳入 ROS 格式化标准并调整 Neovim Python 工具策略

**Files:**
- Create: `ros2/.style.yapf`
- Create: `ros2/cmake-format.yaml`
- Modify: `lua/plugins/lsp.lua`
- Modify: `lua/plugins/telescope.lua`
- Create: `tests/nvim_config_contract_test.sh`

- [ ] **Step 1: 写失败的 nvim 配置合同测试**

Create `tests/nvim_config_contract_test.sh`:

```bash
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
```

- [ ] **Step 2: 运行测试确认失败**

Run: `bash tests/nvim_config_contract_test.sh`

Expected: FAIL because `ros2/` files are not present and nvim still references `dev_venv`.

- [ ] **Step 3: 复制格式化标准文件**

Copy current standards into dotfiles using patch content from:

- `/home/fei/ros2_ws/.style.yapf`
- `/home/fei/ros2_ws/cmake-format.yaml`

- [ ] **Step 4: 调整 nvim LSP 配置**

Change Python tool env fallback from `~/dev_venv` to `~/dev_env`; add `yapf` resolution; bind Python formatting to yapf for ROS workspace files with `.style.yapf`; keep ruff for lint and pyrefly for typing.

- [ ] **Step 5: 更新 Telescope 忽略目录**

Replace `dev_venv` ignore pattern with `dev_env`.

- [ ] **Step 6: 运行测试确认通过**

Run: `bash tests/nvim_config_contract_test.sh`

Expected: `nvim config contract checks passed`

- [ ] **Step 7: 提交**

```bash
git add ros2 lua/plugins/lsp.lua lua/plugins/telescope.lua tests/nvim_config_contract_test.sh
git commit -m "feat: standardize python formatting tools"
```

### Task 4: 更新恢复文档

**Files:**
- Modify: `README.md`
- Modify: `/home/fei/Documents/Obsidian Vault/40-Resources/开发环境恢复手册.md`

- [ ] **Step 1: 同步 Obsidian Vault**

Run: `obsidian-sync`

Expected: exit 0 and no conflicts.

- [ ] **Step 2: 更新 README 和恢复手册**

README should point to `bash install_scripts/bootstrap_ubuntu24.sh`.

Obsidian manual should describe:

- manual SSH/GitHub setup
- clone dotfiles
- run bootstrap
- complete Codex login
- complete rclone Google Drive auth
- ROS 2 handled separately
- format standards live in dotfiles `ros2/`

- [ ] **Step 3: 运行文档合同检查**

Run:

```bash
grep -Fq "bootstrap_ubuntu24.sh" README.md
grep -Fq "bootstrap_ubuntu24.sh" "/home/fei/Documents/Obsidian Vault/40-Resources/开发环境恢复手册.md"
grep -Fq "ROS 2" "/home/fei/Documents/Obsidian Vault/40-Resources/开发环境恢复手册.md"
```

Expected: exit 0.

- [ ] **Step 4: 再次同步 Obsidian Vault**

Run: `obsidian-sync`

Expected: exit 0 and no conflicts.

- [ ] **Step 5: 提交 dotfiles 文档改动**

```bash
git add README.md
git commit -m "docs: document ubuntu24 bootstrap usage"
```

### Task 5: 最终验证

**Files:**
- No new files.

- [ ] **Step 1: 运行所有合同测试**

Run:

```bash
bash tests/bootstrap_contract_test.sh
bash tests/nvim_config_contract_test.sh
```

Expected: both print `... checks passed`.

- [ ] **Step 2: 运行 Bash 语法检查**

Run:

```bash
find install_scripts -name '*.sh' -print0 | xargs -0 -n1 bash -n
```

Expected: exit 0.

- [ ] **Step 3: 检查 git 状态**

Run: `git status --short`

Expected: clean for the worktree. Obsidian Vault may have its own sync-managed state outside this git repo.
