#!/usr/bin/env bash
set -euo pipefail

git config --global core.excludesfile ~/.gitignore_global
git config --global core.editor nvim
git config --global core.pager delta
git config --global pager.log delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.light true
git config --global delta.line-numbers true
git config --global merge.conflictStyle zdiff3
git config core.filemode false
