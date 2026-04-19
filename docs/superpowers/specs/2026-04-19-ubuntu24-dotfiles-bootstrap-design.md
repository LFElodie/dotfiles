# Ubuntu 24.04 dotfiles 恢复自动化设计

## 目标

在全新安装 Ubuntu 24.04 后，尽量用最少的手动步骤恢复常用开发环境。

手动步骤只保留凭据和外部账号授权相关内容：

- 创建或导入 SSH key。
- 将 SSH 公钥添加到 GitHub。
- 克隆 dotfiles 仓库。
- 交互完成 Codex 登录。
- 交互完成 rclone 的 Google Drive 授权。

除此之外，能由 dotfiles 脚本自动完成的内容都应尽量自动化。

本阶段不包含 ROS 2 安装。shell 配置需要兼容 ROS 2 尚未安装的状态，避免新系统打开终端时报错。

## 范围

本阶段包含：

- Ubuntu 24.04 常用软件包安装。
- zsh 和 Oh My Zsh 设置。
- dotbot 管理的软链接恢复。
- Neovim、tmux、ranger、git、字体和 shell 配置恢复。
- Node/npm 设置。
- Python 开发工具环境 `~/dev_env` 设置。
- Codex CLI 安装和登录提示。
- rclone 安装和 Obsidian 同步入口设置。
- 格式化标准文件纳入 dotfiles 管理。
- 环境验证命令。
- 精简旧安装入口，避免 `install_scripts` 和根目录 `install_packages.sh` 保留重复职责。
- 更新 Obsidian 中的开发环境恢复手册，说明新的恢复流程。

本阶段不包含：

- ROS 2 Jazzy 安装。
- 备份或恢复 SSH 私钥、token、rclone 密钥、Codex 会话文件或任何其他凭据。
- 从 dotbot 迁移到其他 dotfiles 管理工具。

## 入口

新增一个 Ubuntu 24.04 专用 bootstrap 脚本：

```bash
bash install_scripts/bootstrap_ubuntu24.sh
```

新系统恢复流程变成：

```bash
cd ~
git clone git@github.com:LFElodie/dotfiles.git
cd ~/dotfiles
bash install_scripts/bootstrap_ubuntu24.sh
```

现有 `./install` 继续作为 dotbot 的软链接入口，负责链接配置和轻量设置。bootstrap 脚本负责系统级准备，并在合适阶段调用 `./install`。

本次改造后，用户面向的新系统恢复入口只保留一个：

```bash
bash install_scripts/bootstrap_ubuntu24.sh
```

根目录旧入口 `install_packages.sh` 不再保留。`install_scripts` 目录下只保留仍有明确职责的脚本，重复或已被 bootstrap 覆盖的脚本应删除或合并。

bootstrap 是用户入口，但不应成为大而全的实现文件。它只负责顺序编排和统一错误处理，具体能力放到可替换的模块脚本中。

## 脚本结构

`install_scripts/bootstrap_ubuntu24.sh` 应写成可重复执行的 Bash 编排脚本，并启用严格错误处理。

推荐目录结构：

```text
install_scripts/
  bootstrap_ubuntu24.sh
  lib/
    common.sh
  modules/
    preflight_ubuntu24.sh
    apt_packages.sh
    oh_my_zsh.sh
    dotbot.sh
    dev_env.sh
    node_codex.sh
    obsidian_sync.sh
    verify.sh
```

职责划分：

- `bootstrap_ubuntu24.sh`：只负责加载公共函数、按顺序调用模块、汇总结果，不直接写具体安装细节。
- `lib/common.sh`：放日志、错误处理、命令检查、幂等辅助函数。
- `modules/preflight_ubuntu24.sh`：检查系统版本、sudo、网络、GitHub SSH。
- `modules/apt_packages.sh`：安装基础 apt 软件包。
- `modules/oh_my_zsh.sh`：安装或检查 Oh My Zsh。
- `modules/dotbot.sh`：执行 `./install`。
- `modules/dev_env.sh`：创建 `~/dev_env` 并安装 Python 开发工具。
- `modules/node_codex.sh`：安装 Node 稳定版、Codex CLI，并提示登录。
- `modules/obsidian_sync.sh`：安装后的 Obsidian/rclone 检查和服务启用。该模块是当前同步方案的实现，不应被其他模块强依赖。
- `modules/verify.sh`：集中调用各模块的验证函数并输出结果。

每个模块应暴露统一入口，例如 `run_<module>` 和 `verify_<module>`。模块之间通过命令、文件路径和环境变量通信，不直接调用彼此的内部函数。这样以后如果不再使用 Obsidian，只需要替换或移除 `modules/obsidian_sync.sh`，不需要重写 bootstrap 主流程。

当前建议模块：

- `require_command`：在模块执行前检查必要命令是否存在。
- `is_ubuntu_24_04`：确认系统是否为 Ubuntu 24.04；不匹配时给出警告或退出。
- `run_apt_packages`：安装常用 apt 软件包。
- `setup_oh_my_zsh`：仅当 `~/.oh-my-zsh` 不存在时安装 Oh My Zsh。
- `run_dotbot_install`：从仓库根目录执行 `./install`。
- `setup_dev_env`：创建或复用 `~/dev_env`，安装 Python 开发工具。
- `setup_node_codex`：安装 Node 稳定版工具链和 Codex CLI。
- `setup_obsidian_sync`：检查 rclone 远端状态，并启用现有 Obsidian 同步服务。
- `verify_environment`：输出已恢复工具的通过/失败状态。

脚本应支持安全重跑。已有目录和已安装工具应尽量复用，避免无意义覆盖。

模块边界约束：

- 主脚本不得直接写 Obsidian、Codex、Neovim、rclone 等具体工具细节。
- 模块可以被单独运行，便于调试和未来重排恢复步骤。
- 可选模块失败时，应明确说明失败影响；不应让无关模块误报。
- 凭据相关模块只能提示交互认证，不保存密钥或 token。
- 新增工具时优先新增模块或扩展对应模块，不把逻辑揉进 bootstrap 主脚本。

## 旧脚本精简

当前 dotfiles 中存在多个安装相关入口：

- `install_packages.sh`
- `install_scripts/setup_packages.sh`
- `install_scripts/setup_mirrors.sh`
- `install_scripts/install_font.sh`

本次改造的目标是减少入口数量和重复逻辑：

- 删除根目录 `install_packages.sh`，其职责由 `install_scripts/bootstrap_ubuntu24.sh` 接管。
- 删除或停用 `install_scripts/setup_packages.sh`，其软件包安装逻辑合并进 bootstrap。
- 保留 `install_scripts/install_font.sh`，因为它是 dotbot 后置的字体缓存刷新步骤，职责独立。
- `install_scripts/setup_mirrors.sh` 暂不接入默认流程；如果保留，应在 README 或手册中明确它是可选脚本，不属于一键恢复主路径。

清理后的主路径应清晰：bootstrap 负责编排，模块负责具体安装和验证，`./install` 负责 dotbot 链接和轻量配置，其他脚本只保留独立、可解释的职责。

## 软件包安装

软件包模块安装当前预期的基础环境：

- shell 和终端：`zsh`、`tmux`、`terminator`
- 编辑器和文件管理：`neovim`、`ranger`
- 构建和开发：`git`、`curl`、`ca-certificates`、`gnupg`、`lsb-release`、`software-properties-common`、`cmake`、`cmake-format`、`clangd`、`clang-format`
- Python：`python3`、`python3-pip`、`python3-venv`、`python3-dev`
- 搜索和效率工具：`ripgrep`、`fd-find`、`fzf`、`autojump`、`htop`
- 桌面辅助工具：`xclip`、`gnome-tweaks`
- Node 和认证工具基础：`nodejs`、`npm`
- 远程访问和同步：`openssh-server`、`rclone`
- Neovim/Mason 构建和下载前置：`build-essential`、`unzip`、`wget`、`fontconfig`

Neovim 可以继续使用 unstable PPA，前提是仍然需要较新的版本。如果 PPA 步骤失败，脚本应明确失败，而不是静默留下旧版编辑器。

## Oh My Zsh

当 `~/.oh-my-zsh` 不存在时，脚本应自动安装 Oh My Zsh。

安装时应避免安装脚本自动切换 shell 造成不可控行为。需要时可单独通过以下命令切换登录 shell，因为该操作通常需要密码，并且不同机器上的行为可能不同：

```bash
chsh -s "$(command -v zsh)"
```

dotfiles 中已经 vendored 的自定义插件继续作为来源：

- `zsh-autosuggestions`
- `zsh-completions`
- `zsh-syntax-highlighting`

## Shell 健壮性

`zsh/zshrc` 应改成有条件加载 ROS 相关环境：

- 仅当 `/opt/ros/jazzy/setup.zsh` 存在时才 source。
- 仅当 `~/ros2_ws/install/setup.zsh` 存在时才 source。
- 仅当 `ros2` 和 `colcon` 命令存在时才注册 argcomplete。

这样新系统即使还没有安装 ROS 2，也不会在启动 zsh 时打印错误。

## Python 开发工具环境

统一使用 `~/dev_env` 作为个人 Python 开发工具环境，不再使用 `~/dev_venv` 或 `~/lyenv`。

bootstrap 脚本应：

- 当 `~/dev_env/bin/python` 不存在时，通过 `python3 -m venv ~/dev_env` 创建虚拟环境。
- 升级该环境中的 `pip`、`setuptools`、`wheel`。
- 在该环境中安装 Neovim 和 ROS 工作区常用 Python 工具：`pynvim`、`yapf`、`ruff`、`pyrefly`、`debugpy`、`cpplint`。
- 不默认安装 `black` 和 `pyright`；`black` 的格式化职责由 `yapf` 承担，Python 类型检查使用 `pyrefly`。

Neovim 的 Python 工具解析逻辑应同步改为优先识别：

1. 当前激活的 `VIRTUAL_ENV` 或 `CONDA_PREFIX`。
2. 环境变量 `NVIM_PYTHON_VENV` 指向的路径。
3. 默认路径 `~/dev_env`。

## 格式化标准文件

将 ROS 工作区的格式化标准文件纳入 dotfiles 管理：

- `ros2/.style.yapf`：来源为当前 `/home/fei/ros2_ws/.style.yapf`，作为 Python yapf 格式化标准。
- `ros2/.clang-format`：来源为当前 `/home/fei/ros2_ws/.clang-format`，作为 C/C++ clang-format 格式化标准。
- `ros2/cmake-format.yaml`：来源为当前 `/home/fei/ros2_ws/cmake-format.yaml`，作为 CMake 格式化标准。

本阶段只负责把标准文件放入 dotfiles，不在 bootstrap 或 dotbot 中链接到 `~/ros2_ws`。原因是新系统恢复基础环境时，ROS 2 和 ROS 工作区可能尚未安装或恢复。

后续恢复 ROS 工作区时，再由单独步骤将这些标准文件复制或链接到：

- `~/ros2_ws/.style.yapf`
- `~/ros2_ws/.clang-format`
- `~/ros2_ws/cmake-format.yaml`

ROS 2 安装、工作区源码恢复，以及格式化标准文件落地到 `~/ros2_ws` 的动作，均不属于本阶段 bootstrap 主路径。

Neovim 的 Python 格式化默认策略应与 ROS 工作区规则一致：

- 当文件位于 `~/ros2_ws` 下，并且 `~/ros2_ws/.style.yapf` 存在时，默认使用 `~/dev_env/bin/yapf -i --style=~/ros2_ws/.style.yapf`。
- 如果 `~/ros2_ws/.style.yapf` 尚不存在，则不强行创建 ROS 工作区；只提示需要在恢复 ROS 工作区后落地 dotfiles 中的 `ros2/.style.yapf`。
- Python lint 和 import 检查继续使用 `ruff`。
- Python 类型检查使用 `pyrefly`，不再默认使用 `pyright`。
- 不再将 `ruff format` 作为 ROS 工作区 Python 文件的默认格式化器。

## Node 和 Codex

bootstrap 脚本应：

- 通过 npm 安装或更新 `n`。
- 通过 `n` 安装稳定版 Node。
- 全局安装 `@openai/codex`。
- 如果当前工作流仍需要，则可选安装 `@loongphy/codex-auth`。
- 输出清晰的后续交互认证步骤。

脚本不得保存或提交 Codex 凭据。

## Obsidian 同步

现有 dotfiles 中的 Obsidian 资源继续作为唯一来源：

- `obsidian/bin/obsidian-sync`
- `obsidian/bin/obsidian-sync-init`
- `obsidian/rclone/obsidian-bisync-filter.txt`
- `obsidian/systemd/user/obsidian-sync-on-login.service`
- `obsidian/setup_obsidian_sync.sh`

bootstrap 流程应：

- 确保已安装 `rclone`。
- 检查是否存在 `gdrive:` 远端。
- 如果缺少远端，提示用户运行 `rclone config` 完成 Google Drive 授权。
- 在 dotbot 创建软链接后，运行现有 Obsidian 设置脚本。

不得将 `~/.config/rclone/rclone.conf`、rclone bisync 缓存或 Vault 内容提交进 dotfiles。

## 验证

最终验证输出应检查：

- `git --version`
- `ssh -T git@github.com`
- `zsh --version`
- `test -d ~/.oh-my-zsh`
- `test -L ~/.zshrc`
- `test -x ~/dev_env/bin/yapf`
- `test -x ~/dev_env/bin/pyrefly`
- `test -x ~/dev_env/bin/ruff`
- `nvim --version`
- `tmux -V`
- `node --version`
- `npm --version`
- `codex --version`
- `rclone version`
- `rclone listremotes` 中包含 `gdrive:`
- `test -L ~/.local/bin/obsidian-sync`
- `test -f ~/dotfiles/ros2/.style.yapf`
- `test -f ~/dotfiles/ros2/.clang-format`
- `test -f ~/dotfiles/ros2/cmake-format.yaml`
- `systemctl --user is-enabled obsidian-sync-on-login.service`

验证失败时，应输出可操作的后续步骤，而不是隐藏失败。

## 文档更新

实现后更新 `Documents/Obsidian Vault/40-Resources/开发环境恢复手册.md`。

手册应围绕以下流程重组：

1. 新系统基础准备。
2. 手动配置凭据。
3. 克隆 dotfiles。
4. 运行 bootstrap 脚本。
5. 完成 Codex 和 rclone 交互授权。
6. 验证恢复后的环境。
7. ROS 2 安装单独处理。

修改 Vault 前后都必须按照 Vault 根目录 `AGENTS.md` 的规则运行 `obsidian-sync`。

## 风险

- 安装软件包和切换 shell 时预期会出现 `sudo` 密码提示。
- 网络问题可能中断 apt、npm 或 rclone 设置。
- 全局 npm 包安装依赖当前 Node/npm 状态。
- `~/ros2_ws` 可能尚未恢复源码；本阶段只负责把格式化标准文件纳入 dotfiles，不负责链接到 ROS 工作区，也不负责 ROS 2 或工作区源码安装。
- 如果模块边界设计不清，bootstrap 可能重新退化成大而全脚本；实施时需要保持主脚本只编排、模块承载具体逻辑。
- dotfiles 中已有未提交的 `install_packages.sh` 修改和未跟踪 `.codex` 文件。由于 `install_packages.sh` 将在本次改造中删除，实施前需要确认其唯一新增内容 `openssh-server` 已合并进 bootstrap；`.codex` 仍不得意外纳入无关提交。

## 验收标准

- 全新 Ubuntu 24.04 机器在克隆 dotfiles 后，可以通过一个 bootstrap 脚本恢复基础环境。
- 脚本可重复执行，不破坏已有配置。
- ROS 2 尚未安装时，zsh 仍能干净启动。
- `~/dev_env` 已创建，且包含 `yapf`、`ruff`、`pyrefly` 等 Neovim/ROS Python 开发工具。
- `ros2/.style.yapf`、`ros2/.clang-format` 和 `ros2/cmake-format.yaml` 的标准内容由 dotfiles 管理，但 bootstrap 不要求 `~/ros2_ws` 存在。
- Neovim 在 ROS 工作区 Python 文件中默认使用 yapf 格式化，lint/type check 使用 `ruff + pyrefly`。
- Codex CLI 已安装，并向用户输出明确的登录说明。
- rclone 和 Obsidian 同步链接已安装；缺少 Google Drive 授权时，向用户输出明确配置说明。
- `install_packages.sh` 已删除，`install_scripts/setup_packages.sh` 的重复职责已被合并或移除。
- `install_scripts` 目录只保留 bootstrap、公共库、可编排模块和职责清晰的辅助脚本。
- bootstrap 主脚本只负责编排；Obsidian/Codex/dev_env/apt 等具体逻辑位于独立模块中。
- 开发环境恢复手册与实际实现流程一致。
