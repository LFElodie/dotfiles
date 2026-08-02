# LFElodie 的 dotfiles

使用 Dotbot 管理，面向 Ubuntu 24.04、ROS 2 Jazzy 和多台个人工作站。

## 安装或更新完整环境

全新系统执行：

```bash
cd ~
git clone git@github.com:LFElodie/dotfiles.git
cd ~/dotfiles
./install
```

已有仓库更新后同样执行：

```bash
cd ~/dotfiles
git pull --ff-only
./install
```

`./install` 是统一的幂等入口，会安装或更新系统软件、Kitty、Oh My Zsh、
Starship、Zsh 插件、git-delta、Node/Codex、开发工具和字体，然后部署配置并
执行严格的环境验收。运行期间需要网络和 `sudo` 权限。

只刷新 Dotbot 管理的配置，不安装或更新软件：

```bash
./install --links-only
```

`install_scripts/bootstrap_ubuntu24.sh` 保留为兼容入口，作用与直接执行
`./install` 相同。

## Kitty

安装脚本使用 [Kitty 官方二进制安装器](https://sw.kovidgoyal.net/kitty/binary/)
的默认稳定通道，不固定版本。每次完整安装都会检查官方当前稳定版并安装到
`~/.local/kitty.app`，同时完成以下集成：

- 创建 `~/.local/bin/kitty` 和 `~/.local/bin/kitten`；
- 安装并修正桌面菜单文件；
- 通过 `~/.config/xdg-terminals.list` 声明默认终端；
- 通过 `update-alternatives` 设置 `x-terminal-emulator`；
- 链接仓库中的字体、主题和 Kitty 配置。

## 中文输入法

Fcitx5 环境同时部署到 `~/.pam_environment` 和
`~/.config/environment.d/im.conf`。其中
`GLFW_IM_MODULE=ibus` 用于 Kitty 在 X11 会话下接入输入法；Wayland 会话走
原生输入法路径，但保留该变量不会改变其工作方式。

安装脚本还会通过 `im-config` 选择 Fcitx5。`~/.xinputrc` 是工具生成的运行时
文件，不纳入版本控制。Fcitx5 会自行重写 `~/.config/fcitx5/profile`，因此
该文件从仓库模板复制，而不是长期保持符号链接。环境变量变更后需要退出并
重新登录图形会话。

个人词库、账号、令牌和输入历史不纳入仓库。需要维护个人 Rime 词条时，应先
确认仓库可见范围是否适合保存这些内容。

## Shell 与 Git

Starship 负责提示符，Oh My Zsh 负责插件和补全。若 Starship、git-delta 或
其他关键程序缺失，完整安装最后的验收会返回失败，不再仅输出警告。

Git 默认使用 delta 作为 pager，`git log` 会进入可翻页、可退出的终端界面；
配置由 `set_git.sh` 统一写入全局 Git 配置。

可以单独执行环境验收：

```bash
bash install_scripts/modules/verify.sh
```

## ROS 2 环境

每个交互式 Zsh 启动时都会自动加载 ROS 2：优先加载
`~/ros2_ws/install/setup.zsh` 工作空间 overlay；若工作空间尚未构建，则
回退到 `/opt/ros/jazzy/setup.zsh` underlay。

工作空间的 `.envrc` 用于进入目录时刷新 overlay。首次部署或内容变化后执行：

```bash
direnv allow ~/ros2_ws
```

需要重新加载或临时切换工作空间时执行：

```zsh
ros2_on
ros2_on ~/other_ws
```

## 不纳入仓库的内容

- SSH、GitHub、Codex 和 rclone 的登录凭据；
- rclone Google Drive 授权；
- Obsidian 本地数据和个人 Rime 词库；
- Fcitx5、Zsh、Python 等程序生成的缓存和运行时状态。
