# Ubuntu 24.04 dotfiles Bootstrap Design

## Goal

After a fresh Ubuntu 24.04 installation, the environment should be restored with the fewest manual steps possible.

Manual work is limited to credentials and external account authorization:

- Create or import an SSH key.
- Add the SSH public key to GitHub.
- Clone the dotfiles repository.
- Complete interactive login for Codex.
- Complete interactive Google Drive authorization for rclone.

Everything else should be handled by dotfiles scripts where practical.

ROS 2 installation is intentionally out of scope for this phase. The shell configuration should still tolerate ROS 2 not being installed yet.

## Scope

This phase covers:

- Ubuntu 24.04 common package installation.
- zsh and Oh My Zsh setup.
- dotbot-managed symlinks.
- Neovim, tmux, ranger, git, fonts, and shell configuration.
- Node/npm setup.
- Codex CLI installation and login prompt.
- rclone installation and Obsidian sync setup.
- Environment verification commands.
- Updating the Obsidian recovery manual to describe the new flow.

This phase does not cover:

- ROS 2 Jazzy installation.
- Backing up or restoring SSH private keys, tokens, rclone secrets, Codex session files, or any other credentials.
- Migrating away from dotbot.

## Entry Point

Add a top-level Ubuntu bootstrap script:

```bash
bash install_scripts/bootstrap_ubuntu24.sh
```

The fresh-system flow becomes:

```bash
cd ~
git clone git@github.com:LFElodie/dotfiles.git
cd ~/dotfiles
bash install_scripts/bootstrap_ubuntu24.sh
```

The existing `./install` remains the dotbot entry point for symlinks and lightweight setup. The bootstrap script orchestrates system preparation and then calls `./install`.

## Script Structure

`install_scripts/bootstrap_ubuntu24.sh` should be written as an idempotent Bash script with strict error handling.

Recommended structure:

- `require_command`: checks required commands before a module runs.
- `is_ubuntu_24_04`: warns or exits if the system is not Ubuntu 24.04.
- `run_apt_packages`: installs common apt packages.
- `setup_oh_my_zsh`: installs Oh My Zsh only if `~/.oh-my-zsh` is missing.
- `run_dotbot_install`: runs `./install` from the repository root.
- `setup_node_codex`: installs Node stable tooling and Codex CLI.
- `setup_obsidian_sync`: checks rclone remote state and enables existing sync service.
- `verify_environment`: prints pass/fail status for the restored tools.

The script should be safe to rerun. Existing directories and installed tools should be reused where possible.

## Package Installation

The package module should install the currently expected baseline:

- Shell and terminal: `zsh`, `tmux`, `terminator`
- Editor and file management: `neovim`, `ranger`
- Build and development: `git`, `curl`, `ca-certificates`, `gnupg`, `lsb-release`, `software-properties-common`, `cmake`, `clang-format`, `ccls`
- Python: `python3`, `python3-pip`, `python3-venv`, `python3-dev`
- Search and productivity: `ripgrep`, `fd-find`, `fzf`, `autojump`, `htop`
- Desktop helpers: `xclip`, `gnome-tweaks`
- Node and auth tooling base: `nodejs`, `npm`
- Remote access and sync: `openssh-server`, `rclone`

Neovim can continue to use the unstable PPA if that remains desired. If the PPA step fails, the script should fail clearly rather than silently leaving an older editor.

## Oh My Zsh

The script should install Oh My Zsh when `~/.oh-my-zsh` is absent.

It should avoid uncontrolled shell switching during installation. The user's login shell can be changed separately with `chsh -s "$(command -v zsh)"` when needed, because that can require a password and may behave differently across machines.

The vendored custom plugins already stored in dotfiles remain the source for:

- `zsh-autosuggestions`
- `zsh-completions`
- `zsh-syntax-highlighting`

## Shell Robustness

`zsh/zshrc` should be changed so ROS-related setup is conditional:

- Source `/opt/ros/jazzy/setup.zsh` only if the file exists.
- Source `~/ros2_ws/install/setup.zsh` only if the file exists.
- Register argcomplete for `ros2` and `colcon` only when those commands are available.

This prevents a newly restored non-ROS system from printing startup errors.

## Node And Codex

The bootstrap script should:

- Install or update `n` with npm.
- Install stable Node through `n`.
- Install `@openai/codex` globally.
- Optionally install `@loongphy/codex-auth` if the current workflow still uses it.
- Print clear next steps for interactive authentication.

The script must not store or commit Codex credentials.

## Obsidian Sync

The existing dotfiles Obsidian assets remain the source of truth:

- `obsidian/bin/obsidian-sync`
- `obsidian/bin/obsidian-sync-init`
- `obsidian/rclone/obsidian-bisync-filter.txt`
- `obsidian/systemd/user/obsidian-sync-on-login.service`
- `obsidian/setup_obsidian_sync.sh`

The bootstrap flow should:

- Ensure `rclone` is installed.
- Check whether the `gdrive:` remote exists.
- If it is missing, print a clear instruction to run `rclone config`.
- Run the existing Obsidian setup script after dotbot creates symlinks.

It should not commit `~/.config/rclone/rclone.conf`, rclone bisync caches, or Vault contents into dotfiles.

## Verification

The final verification output should check:

- `git --version`
- `ssh -T git@github.com`
- `zsh --version`
- `test -d ~/.oh-my-zsh`
- `test -L ~/.zshrc`
- `nvim --version`
- `tmux -V`
- `node --version`
- `npm --version`
- `codex --version`
- `rclone version`
- `rclone listremotes` contains `gdrive:`
- `test -L ~/.local/bin/obsidian-sync`
- `systemctl --user is-enabled obsidian-sync-on-login.service`

Failures should be reported as actionable next steps instead of being hidden.

## Documentation Update

Update `Documents/Obsidian Vault/40-Resources/开发环境恢复手册.md` after implementation.

The manual should be reorganized around:

1. Fresh system baseline.
2. Manual credential setup.
3. Clone dotfiles.
4. Run the bootstrap script.
5. Complete Codex and rclone interactive authorization.
6. Verify the restored environment.
7. ROS 2 installation is handled separately.

Before and after modifying the Vault, run `obsidian-sync` according to the Vault `AGENTS.md` rule.

## Risks

- `sudo` prompts are expected during package installation and shell changes.
- Network failures can interrupt apt, npm, or rclone setup.
- Global npm package installation may depend on the current Node/npm state.
- The existing uncommitted `install_packages.sh` change and untracked `.codex` file in dotfiles must not be overwritten accidentally.

## Acceptance Criteria

- A fresh Ubuntu 24.04 machine can run one bootstrap script after cloning dotfiles.
- The script can be rerun without damaging existing configuration.
- zsh starts cleanly before ROS 2 is installed.
- Codex CLI is installed, and the user receives a clear login instruction.
- rclone and Obsidian sync links are installed, and the user receives a clear Google Drive authorization instruction when needed.
- The recovery manual matches the implemented flow.
