#!/usr/bin/env bash

run_dotbot() {
  (cd "$DOTFILES_ROOT" && ./install)
}
