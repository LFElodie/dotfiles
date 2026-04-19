#!/usr/bin/env bash

run_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log_info "Oh My Zsh already exists: $HOME/.oh-my-zsh"
    return 0
  fi

  require_command curl
  require_command sh

  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  log_info "Oh My Zsh installed. Change login shell manually if needed: chsh -s \"$(command -v zsh)\""
}
