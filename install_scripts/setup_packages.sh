#!/bin/bash
set -e

# 安装常用软件包
sudo apt-get update
sudo apt-get install -y \
    zsh autojump tmux ranger curl git cmake python3 python3-pip python3-venv python3-dev fzf ccls \
    clang-format ripgrep fd-find htop terminator xclip nodejs npm \
    gnome-tweaks

# 添加 neovim-ppa 源并安装 nightly 版 neovim
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install -y neovim

# pip 安装 neovim 支持
python3 -m pip install --user --upgrade pip setuptools wheel pynvim

# 使用 npm 安装最新稳定版 node
sudo npm install -g n
sudo n stable
