if  [ -x "$(command -v brew)" ]; then
  echo 'install package using brew'
  brew install zsh neovim autojump tmux ranger fzf
  exit 0
fi
if  [ -x "$(command -v brew)" ]; then
  echo 'install package using brew'
  sudo apt install zsh neovim autojump tmux ranger fzf
  exit 0
fi
echo 'brew and apt not find'
