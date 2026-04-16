#!/usr/bin/env bash

set -e

if  [ -x "$(command -v apt-get)" ]; then
  echo 'install package using apt'
  sudo add-apt-repository ppa:neovim-ppa/unstable
  sudo apt-get update
  sudo apt-get install -y \
    zsh neovim autojump tmux ranger fzf curl git cmake \
    python3 python3-pip python3-venv python3-dev \
    clang-format ripgrep fd-find xclip nodejs npm terminator
  exit 0
fi
echo 'apt not find'
