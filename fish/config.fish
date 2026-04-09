zoxide init fish | source
fzf --fish | source
atuin init fish | source

abbr -a '^r' atuin-search-viins  # Ctrl-r starts Atuin in Insert mode
abbr -a lg lazygit

# Load local config
# if test -f ~/.local/env.fish
# end
source ~/.local/env.fish

# rustup shell setup
if not contains "$HOME/.cargo/bin" $PATH
    # Prepending path in case a system-installed rustc needs to be overridden
    set -x PATH "$HOME/.cargo/bin" $PATH
end

set -x PATH "$HOME/.bun/bin" $PATH

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

## OCaml setup
#
# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '~/.opam/opam-init/init.fish' && source '~/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
# END opam configuration
