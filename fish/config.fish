zoxide init fish | source
fzf --fish | source
atuin init fish | source

abbr -a '^r' atuin-search-viins  # Ctrl-r starts Atuin in Insert mode
abbr -a lg lazygit               # Writing "lg" is much nicer

# Load local config
test -r ~/.local/env.fish; and source ~/.local/env.fish  # Local files that should never be in git

# Prepended so they override system binaries (e.g. a system rustc).
# fish_add_path skips entries already in PATH, so nested shells don't pile up duplicates.
fish_add_path --global ~/.local/bin ~/.bun/bin ~/.emacs.d/bin ~/.cargo/bin

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
