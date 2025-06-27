#!/bin/bash

# Install xCode cli tools
if [[ "$(uname)" == "Darwin" ]]; then
    echo "macOS deteted..."

    if xcode-select -p &>/dev/null; then
        echo "Xcode already installed"
    else
        echo "Installing commandline tools..."
        xcode-select --install
    fi
fi

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Installing Brew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

## Taps
echo "Tapping Brew..."
brew tap FelixKratz/formulae

### Must Have things
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting

### Terminal
brew install git
brew install lazygit
brew install tmux
brew install neovim
brew install starship
brew install tree-sitter
brew install tree
brew install borders

### dev things
brew install node
brew install nvm

## Casks
brew install --cask betterdisplay
brew install --cask linearmouse
brew install --cask font-hack-nerd-font
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-sf-pro

## Rust
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

## MacOS settings
# echo "Changing macOS defaults..."
# defaults write com.apple.Dock autohide -bool TRUE
# defaults write NSGlobalDomain KeyRepeat -int 2
# defaults write InitialKeyRepeat -int 15
# csrutil status

echo "Installation complete..."

# Clone dotfiles repository
if [ ! -d "$HOME/dotfiles" ]; then
  echo "Cloning dotfiles repository..."
  git clone https://github.com/mariusrostad/dotfiles.git $HOME/dotfiles
fi

# Navigate to dotfiles directory
cd $HOME/dotfiles || exit

# Stow dotfiles packages
echo "Stowing dotfiles..."
stow -t ~ aerospace karabiner neovim starship wezterm tmux zsh

echo "Dotfiles setup complete!"
