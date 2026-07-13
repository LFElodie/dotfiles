# LFElodie 的 dotfiles

使用 Dotbot 管理，面向 Ubuntu 24.04 与 ROS 2 Jazzy 开发环境。

## Ubuntu 24.04 初始化

全新系统执行：

```bash
cd ~
git clone git@github.com:LFElodie/dotfiles.git
cd ~/dotfiles
bash install_scripts/bootstrap_ubuntu24.sh
```

初始化脚本会安装常用软件、Oh My Zsh、Starship、zoxide、fzf-tab、direnv、
git-delta、Node/Codex、`~/dev_env` 与 Obsidian 同步工具。仓库不保存凭据，
SSH/GitHub、Codex 登录和 rclone Google Drive 授权仍需交互完成。

## Shell 与 ROS 2 环境

Starship 只负责提示符，Oh My Zsh 继续负责插件和补全。每个交互式 Zsh
启动时都会自动加载 ROS 2：优先加载 `~/ros2_ws/install/setup.zsh` 工作空间
overlay，如果工作空间尚未构建，则回退到 `/opt/ros/jazzy/setup.zsh` underlay。
因此无需先进入 `~/ros2_ws`，也无需手动执行 `ros2_on`。

工作空间的 `.envrc` 仍保留，用于进入目录时刷新 overlay。首次部署或
`.envrc` 内容变更后执行：

```bash
direnv allow ~/ros2_ws
```

需要重新加载默认工作空间，或临时切换到其他工作空间时，可执行：

```zsh
ros2_on
ros2_on ~/other_ws
```

## 仅刷新 Dotbot 链接

```bash
./install
```

适用于软件已经安装、只需要刷新配置链接的情况。
