# LFElodie's dotfiles

Powered by dotbot.

## Ubuntu 24.04 bootstrap

Fresh system flow:

```bash
cd ~
git clone git@github.com:LFElodie/dotfiles.git
cd ~/dotfiles
bash install_scripts/bootstrap_ubuntu24.sh
```

The bootstrap script installs common packages, Oh My Zsh, Node/Codex, `~/dev_env`,
and Obsidian sync helpers. It does not store credentials. SSH/GitHub, Codex login,
and rclone Google Drive authorization remain interactive steps.

## Dotbot only

```bash
./install
```

Use this when packages and tools are already installed and only dotfile links need
to be refreshed.
