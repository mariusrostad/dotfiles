zoxide init fish | source
fzf --fish | source
atuin init fish | source

abbr -a '^r' atuin-search-viins  # Ctrl-r starts Atuin in Insert mode
abbr -a lg lazygit               # Writing "lg" is much nicer

# Load local config
source ~/.local/env.fish         # Local files that should never be in git

# Add rust to the path if it's not allready setup
if not contains "$HOME/.cargo/bin" $PATH
    # Prepending path in case a system-installed rustc needs to be overridden
    set -x PATH "$HOME/.cargo/bin" $PATH
end

# doom emacs
if not contains "$HOME/.emacs.d/bin" $PATH
    set -x PATH "$HOME/.emacs.d/bin" $PATH
end

set -x PATH "$HOME/.bun/bin" $PATH
set -x PATH "$HOME/.local/bin" $PATH

if command -v eza > /dev/null
	abbr -a l 'eza'
	abbr -a ls 'eza'
	abbr -a ll 'eza -l'
	abbr -a lll 'eza -la'
else
	abbr -a l 'ls'
	abbr -a ll 'ls -l'
	abbr -a lll 'ls -la'
end

## OCaml setup
test -r '~/.opam/opam-init/init.fish' && source '~/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
