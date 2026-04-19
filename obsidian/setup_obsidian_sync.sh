#!/usr/bin/env bash
set -euo pipefail

systemctl --user daemon-reload
systemctl --user enable obsidian-sync-on-login.service

cat <<'MSG'
Obsidian sync user service has been enabled.
MSG
