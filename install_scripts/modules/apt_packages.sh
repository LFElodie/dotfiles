#!/usr/bin/env bash

run_apt_packages() {
  local packages=(
    zsh
    tmux
    terminator
    neovim
    ranger
    git
    curl
    ca-certificates
    gnupg
    lsb-release
    software-properties-common
    cmake
    clang-format
    ccls
    python3
    python3-pip
    python3-venv
    python3-dev
    ripgrep
    fd-find
    fzf
    autojump
    htop
    xclip
    gnome-tweaks
    nodejs
    npm
    openssh-server
    rclone
    build-essential
    unzip
    wget
  )

  ensure_sudo
  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  sudo apt-get update
  sudo apt-get install -y "${packages[@]}"
}
