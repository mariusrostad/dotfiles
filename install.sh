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
   Links each package individually. Each package is checked with a dry run
   first; when Stow reports a conflict, you can skip it or override it with
   --adopt. Adopting may update files in this dotfiles repository.

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
     • Install the Node version manager script to /usr/local/bin/n (sudo)

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
      echo "Run: ./install.sh --help" >&2
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

target_display_path() {
  local path="$1"

  if [[ "$path" == "$HOME" ]]; then
    printf "%s" "~"
  elif [[ "$path" == "$HOME/"* ]]; then
    printf "%s/%s" "~" "${path#"$HOME/"}"
  else
    printf "%s" "$path"
  fi
}

stow_program() {
  local package="$1"
  local target_dir="$2"
  local dry_run_output
  local answer
  local target_label

  target_label="$(target_display_path "$target_dir")"
  mkdir -p "$target_dir"

  if dry_run_output="$(stow -n -d "$DOTFILES_DIR" -t "$target_dir" "$package" 2>&1)"; then
    stow -d "$DOTFILES_DIR" -t "$target_dir" "$package"
    echo "Stowed $package -> $target_label."
    return
  fi

  echo ""
  echo "Stow reported conflicts for $package -> $target_label:"
  printf '%s\n' "$dry_run_output"
  read -r -p "Override conflicts for $package with stow --adopt? [y/N] " answer

  case "$answer" in
    y|Y|yes|YES)
      stow --adopt -d "$DOTFILES_DIR" -t "$target_dir" "$package"
      echo "Adopted and stowed $package -> $target_label."
      echo "Review adopted changes with: git diff"
      ;;
    *)
      echo "Skipped stow of $package; existing files were left untouched."
      ;;
  esac
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
add_post_install "sudo cp \"$DOTFILES_DIR/n/n\" /usr/local/bin/n"

echo "Stowing dotfiles..."
stow_program starship "$HOME"
stow_program ghostty "$HOME"
stow_program tmux "$HOME"
stow_program nvim "$HOME"
stow_program claude "$HOME"
stow_program codex "$HOME"
stow_program fish "$HOME/.config/fish"

read -r -p "Install OpenCode config (~/.config/opencode)? [y/N] " INSTALL_OPENCODE
case "${INSTALL_OPENCODE}" in
  y|Y|yes|YES)
    stow_program opencode "$HOME"
    ;;
  *)
    echo "Skipping OpenCode config."
    ;;
esac

echo "Dotfiles setup complete!"
echo "Optional: stow zsh with: stow -t ~ zsh"
print_post_install
