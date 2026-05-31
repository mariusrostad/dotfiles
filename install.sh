#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
  local brewfile="$DOTFILES_DIR/Brewfile"
  cat <<EOF
install.sh — set up this machine from dotfiles

Usage:
  install.sh          Run full setup (may prompt for sudo/password)
  install.sh -h       Show this help
  install.sh --help   Same as -h

What runs (in order)
────────────────────

1. Homebrew
   Installs Homebrew if brew is not already on PATH (Apple Silicon or Intel).
   Turns off brew analytics.

2. Dotfiles repository
   Uses this checkout when it is a git repo; otherwise uses ~/dotfiles,
   cloning https://github.com/mariusrostad/dotfiles.git if missing.

3. Homebrew packages (brew bundle)
   Installs everything listed in Brewfile:
EOF

  if [[ -f "$brewfile" ]]; then
    awk '
      /^# / { section = substr($0, 3); next }
      /^brew "/ {
        gsub(/^brew "/, "", $0)
        gsub(/"$/, "", $0)
        if (section != prev) { if (prev != "") print ""; print "   " section ":"; prev = section }
        print "     • " $0
        next
      }
      /^cask "/ {
        gsub(/^cask "/, "", $0)
        gsub(/"$/, "", $0)
        if (section != prev) { if (prev != "") print ""; print "   " section ":"; prev = section }
        print "     • " $0
      }
    ' "$brewfile"
  else
    echo "     (Brewfile not found at $brewfile)"
  fi

  cat <<'EOF'

4. Config symlinks (GNU Stow)
   Links these packages into your home directory:

     starship   →  ~/.config/starship/
     ghostty    →  ~/Library/Application Support/com.mitchellh.ghostty/
     tmux       →  ~/.config/tmux/
     nvim       →  ~/.config/nvim/
     claude     →  ~/.claude/
     codex      →  ~/.codex/
     fish       →  ~/.config/fish/

5. OpenCode (interactive)
   Prompts whether to stow opencode → ~/.config/opencode/ (default: skip).

6. Post-setup reminders (printed, not run automatically)
   May suggest commands you can run yourself when ready:
     • Add fish to /etc/shells (sudo)
     • chsh to fish as your login shell
     • Copy the Node version manager script to /usr/local/bin/n (sudo)

Not installed by this script
────────────────────────────
  • zsh config — optional: stow -t ~ zsh  (links ~/.zshrc)
  • OpenCode — only if you answer yes at the prompt

EOF
}

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Run: install.sh --help" >&2
      exit 1
      ;;
  esac
done

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

POST_INSTALL=()

add_post_install() {
  POST_INSTALL+=("$1")
}

collect_fish_shell_steps() {
  local fish_path
  fish_path="$(command -v fish)" || return 0

  if ! grep -Fxq "$fish_path" /etc/shells 2>/dev/null; then
    add_post_install "echo \"$fish_path\" | sudo tee -a /etc/shells"
  fi

  if [[ "${SHELL:-}" != "$fish_path" ]]; then
    add_post_install "chsh -s \"$fish_path\""
  fi
}

collect_n_steps() {
  mkdir -p "$HOME/.n"
  if [[ ! -f /usr/local/bin/n ]] || ! cmp -s "$DOTFILES_DIR/n/n" /usr/local/bin/n 2>/dev/null; then
    add_post_install "sudo cp \"$DOTFILES_DIR/n/n\" /usr/local/bin/n"
  fi
}

remove_empty_codex_placeholder() {
  local codex_agents="$HOME/.codex/AGENTS.md"

  if [[ -f "$codex_agents" && ! -s "$codex_agents" && ! -L "$codex_agents" ]]; then
    rm "$codex_agents"
  fi
}

print_post_install() {
  if [[ ${#POST_INSTALL[@]} -eq 0 ]]; then
    return
  fi

  echo ""
  echo "Optional commands (run when ready; some need sudo or your password):"
  for cmd in "${POST_INSTALL[@]}"; do
    echo "  $cmd"
  done
}

ensure_homebrew
resolve_dotfiles_dir
cd "$DOTFILES_DIR"

brew analytics off
echo "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

collect_fish_shell_steps
remove_empty_codex_placeholder

echo "Stowing dotfiles..."
stow -t ~ starship ghostty tmux nvim claude codex
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

collect_n_steps

echo "Dotfiles setup complete!"
echo "Optional: stow zsh with: stow -t ~ zsh"
print_post_install
