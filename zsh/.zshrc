# export PATH=$HOME/bin:/usr/local/bin:$PATH
# echo source ~/.bash_profile

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

eval "$(brew shellenv)"
# source .zprofile in all zsh shells (just in case)
# [[ -f "$HOME/.zprofile" ]] && source "$HOME/.zprofile"

# Themes - See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# ---------------------------------------

# brew installations activation
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#
# ---------------------------------------

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Starship
bindkey -v
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# FZF
eval "$(fzf --zsh)"

# Atuin Configs
eval "$(atuin init zsh)"
bindkey '^r' atuin-search-viins  # Ctrl-r starts Atuin in Insert mode

#----- Vim Editing modes & keymaps ------
set -o vi

export EDITOR=nvim
export VISUAL=nvim

# -------------------ALIAS----------------------

# other Aliases shortcuts
alias c="clear"
alias e="exit"
alias vim="nvim"

# zoxide (called from ~/scripts/)
alias nzo="~/scripts/zoxide_openfiles_nvim.sh"

# Next level of an ls
# options :  --no-filesize --no-time --no-permissions
alias ls="eza --no-filesize --long --color=always --icons=always --no-user"

# git aliases
alias gt="git"
alias ga="git add ."
alias gs="git status -s"
alias gc='git commit -m'
alias glog='git log --oneline --graph --all'
alias gclog='git shortlog -sn --no-merges'

# lazygit
alias lg="lazygit"

# kubectl
alias k=kubectl

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.cargo/env"
