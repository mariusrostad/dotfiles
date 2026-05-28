#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_DIR"

errors=0

run() {
  echo "==> $*"
  if ! "$@"; then
    echo "FAILED: $*" >&2
    errors=$((errors + 1))
  fi
}

if command -v stow >/dev/null 2>&1; then
  for pkg in starship ghostty tmux nvim claude opencode; do
    if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
      run stow -n -t ~ "$pkg"
    fi
  done
  run stow -n -t ~/.config/fish fish
else
  echo "SKIP: stow not installed" >&2
  errors=$((errors + 1))
fi

if command -v shellcheck >/dev/null 2>&1; then
  run shellcheck install.sh scripts/check.sh
else
  echo "SKIP: shellcheck not installed (brew install shellcheck)" >&2
fi

if command -v stylua >/dev/null 2>&1; then
  run stylua --check nvim/.config/nvim
else
  echo "SKIP: stylua not installed (brew install stylua)" >&2
fi

if [[ $errors -gt 0 ]]; then
  echo "$errors check(s) failed." >&2
  exit 1
fi

echo "All checks passed."
