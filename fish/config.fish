zoxide init fish | source
fzf --fish | source
atuin init fish | source

abbr -a '^r' atuin-search-viins  # Ctrl-r starts Atuin in Insert mode
abbr -a lg lazygit

# rustup shell setup
if not contains "$HOME/.cargo/bin" $PATH
    # Prepending path in case a system-installed rustc needs to be overridden
    set -x PATH "$HOME/.cargo/bin" $PATH
end

if status is-interactive
# Commands to run in interactive sessions can go here
	switch $TERM
		case 'linux'
			:
		case '*'
			if ! set -q TMUX
				# ensure that the new tmux _also_ starts fish
				exec tmux set-option -g default-shell (which fish) ';' new-session
			end
	end
end

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
