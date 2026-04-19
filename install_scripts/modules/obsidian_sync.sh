#!/usr/bin/env bash

run_obsidian_sync() {
  require_command rclone

  if rclone listremotes | grep -Fxq "gdrive:"; then
    log_info "rclone remote exists: gdrive:"
  else
    log_warn "rclone remote gdrive: is missing. Run 'rclone config' and create a Google Drive remote named gdrive."
  fi

  if command_exists systemctl; then
    systemctl --user daemon-reload || log_warn "systemd user daemon-reload failed"
    systemctl --user enable obsidian-sync-on-login.service || log_warn "failed to enable obsidian sync user service"
  else
    log_warn "systemctl not found; skip Obsidian user service setup"
  fi
}
