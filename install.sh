#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ensure_homebrew() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return
  fi
  if [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    return
  fi

  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "Homebrew install finished but brew was not found." >&2
    exit 1
  fi
}

resolve_dotfiles_dir() {
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    return
  fi

  if [[ -d "$HOME/dotfiles/.git" ]]; then
    DOTFILES_DIR="$HOME/dotfiles"
    return
  fi

  if [[ ! -d "$HOME/dotfiles" ]]; then
    echo "Cloning dotfiles repository to $HOME/dotfiles..."
    git clone https://github.com/mariusrostad/dotfiles.git "$HOME/dotfiles"
  fi
  DOTFILES_DIR="$HOME/dotfiles"
}

setup_fish_shell() {
  local fish_path
  fish_path="$(command -v fish)"

  if ! grep -Fxq "$fish_path" /etc/shells 2>/dev/null; then
    echo "Adding $fish_path to /etc/shells (sudo required)..."
    echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
  fi

  if [[ "${SHELL:-}" != "$fish_path" ]]; then
    echo "Setting login shell to fish (you may be prompted for your password)..."
    chsh -s "$fish_path"
  else
    echo "Login shell is already fish."
  fi
}

ensure_homebrew
resolve_dotfiles_dir
cd "$DOTFILES_DIR"

brew analytics off
echo "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

setup_fish_shell

echo "Stowing dotfiles..."
stow -t ~ starship ghostty tmux nvim claude
stow -t ~/.config/fish fish

read -r -p "Install OpenCode config (~/.config/opencode)? [y/N] " INSTALL_OPENCODE
case "${INSTALL_OPENCODE}" in
  y|Y|yes|YES)
    stow -t ~ opencode
    echo "OpenCode config stowed."
    ;;
  *)
    echo "Skipping OpenCode config."
    ;;
esac

echo "Installing n (Node version manager)..."
sudo cp "$DOTFILES_DIR/n/n" /usr/local/bin/n
mkdir -p "$HOME/.n"

echo "Dotfiles setup complete!"
echo "Optional: stow zsh with: stow -t ~ zsh"
