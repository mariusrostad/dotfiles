#!/bin/bash

if [ ! -f /opt/homebrew/bin/brew ]; then
    echo "Installing Brew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Brew already installed :)"
fi

brew analytics off

### Must Have things
brew install atuin
brew install eza # Bedre ls
brew install stow # Linking fra dotfiles til config plasseringer
brew install fzf # Fuzzy find
brew install bat
brew install fd
brew install zoxide
brew install make
brew install ripgrep

### Terminal
brew install git
brew install lazygit
brew install tmux
brew install neovim
brew install tree-sitter
brew install tree

### For historical reasons
# brew install lua
# brew install luajit
# brew install luarocks
# brew install prettier
# brew install starship
# brew install borders
# brew install zsh-autosuggestions
# brew install zsh-syntax-highlighting
# brew install node

## Casks
brew install --cask betterdisplay
brew install --cask linearmouse
brew install --cask font-hack-nerd-font
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-sf-pro

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
stow -t ~ starship ghostty tmux zsh nvim claude
stow -t ~/.config/fish fish

sudo cp ./n/n /usr/local/bin/n && mkdir $HOME/.n/

echo "Dotfiles setup complete!"
