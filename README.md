# Mine dotfiles

:)

## Bootstrap a new Mac

```shell
xcode-select --install   # git + compilers; skip if already installed
git clone https://github.com/mariusrostad/dotfiles.git ~/dotfiles
~/dotfiles/scripts/install.sh
```

`install.sh` installs Homebrew, runs `brew bundle` on the Brewfile, and stows each config folder into place. It is safe to re-run. When an existing file conflicts, it asks before adopting it (`stow --adopt`), so check `git diff` afterwards. Run `scripts/install.sh --help` to see every step.

Afterwards, if you want them:

- Make fish the login shell. `install.sh` prints the exact commands at the end.
- Link zsh config: `stow -t ~ zsh`
- Install agent skills: `scripts/install-skills.sh` (see `--help` for agents and modes)
- Install the [manually installed software](#manually-installed-software)

## Repo layout

| Path | What it is | Stowed to |
| --- | --- | --- |
| `Brewfile` | Homebrew formulae and casks | — |
| `scripts/install.sh` | Machine setup: Homebrew, Brewfile, stow | — |
| `scripts/install-skills.sh` | Installs `skills/` into coding agents | — |
| `fish/` | Fish shell config | `~/.config/fish/` |
| `nvim/` | Neovim config (kickstart-based) | `~/.config/nvim/` |
| `ghostty/` | Ghostty config and themes | `~/.config/ghostty/` |
| `starship/` | Starship prompt | `~/.config/` |
| `gh-dash/` | gh-dash config | `~/.config/gh-dash/` |
| `emacs/` | Emacs config | `~/.emacs.d/` |
| `zsh/` | Zsh config (optional, not stowed by default) | `~/` |
| `skills/` | Agent skills, one folder per skill with a `SKILL.md` | agent skill dirs |

Each config folder mirrors its target directory: files live at the folder's root and are symlinked straight into the target.

## How to add a package

**Homebrew tool or app.** Add a `brew "name"` or `cask "name"` line to `Brewfile` under the matching section, then run `brew bundle --file=~/dotfiles/Brewfile`. The `install.sh --help` output picks it up automatically.

**New config folder (stow package).**

1. Create `<tool>/` at the repo root with the files as they should appear in the target directory.
2. Add `stow_program <tool> "$HOME/.config/<tool>"` (or whatever the target is) to the stow block at the bottom of `scripts/install.sh`.
3. Add a matching line to the stow list in `show_help` in the same script.
4. Run `scripts/install.sh` and check that the symlinks point to the repo.

**Agent skill.** Add `skills/<skill-name>/SKILL.md`, then run `scripts/install-skills.sh`. If you installed with `--mode symlink`, edits to existing skills are picked up without reinstalling, but a new skill still needs a re-run.

## Manually installed software

These are intentionally not installed by `scripts/install.sh` or the Brewfile. Install them by hand.

- **Ghostty**: only the app is installed by hand. Its config is still stowed to `~/.config/ghostty/` by `install.sh`.
- **Node**
- **Java**
- **IntelliJ IDEA**
- **AI harnesses** (Claude Code, Codex, etc.). Agent skills for them can be installed afterwards with `scripts/install-skills.sh`.

## GitHub Review

Dash:

[Docs](https://www.gh-dash.dev/getting-started/)

```shell
gh extension install dlvhdr/gh-dash
```

Delta:

[Docs](https://dandavison.github.io/delta/installation.html) Installeres via Homebrew
