#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SOURCE_DIR="$DOTFILES_DIR/skills"

SUPPORTED_AGENTS=(claude pi copilot codex opencode)
SUPPORTED_INSTALL_MODES=(symlink replace missing)

# Editor backup files that live next to skills locally but are gitignored.
COPY_EXCLUDE_PATTERNS=('*~' '#*#' '.#*')

show_help() {
  cat <<'EOF'
install-skills.sh — install the skills/ folder into one or more coding agents

Usage:
  scripts/install-skills.sh [--agent <name>]... [--mode <mode>]
  scripts/install-skills.sh -h | --help

Without --agent or --mode you are prompted for them interactively.

Agents (--agent is repeatable, or pass "all"):
  claude     →  ~/.claude/skills/
  pi         →  ~/.pi/agent/skills/
  copilot    →  ~/.copilot/skills/          (GitHub Copilot CLI)
  codex      →  ~/.codex/skills/
  opencode   →  ~/.config/opencode/skills/

Modes (--mode), applied per skill directory:
  symlink    Link <agent skills dir>/<skill> → this repo's skills/<skill>.
             Edits in the repo are picked up immediately. An existing real
             directory with the same name is left alone (reported as skipped).
  replace    Delete <agent skills dir>/<skill> and copy the skill fresh.
             Local changes in the installed copy are lost.
  missing    Copy only files that do not exist yet; existing files are kept
             untouched.

Examples:
  scripts/install-skills.sh --agent claude --mode symlink
  scripts/install-skills.sh --agent codex --agent pi --mode missing
  scripts/install-skills.sh --agent all --mode replace
EOF
}

fail() {
  echo "Error: $1" >&2
  exit 1
}

contains_value() {
  local needle="$1"
  shift
  local candidate
  for candidate in "$@"; do
    [[ "$candidate" == "$needle" ]] && return 0
  done
  return 1
}

agent_skills_dir() {
  case "$1" in
    claude) printf "%s" "$HOME/.claude/skills" ;;
    pi) printf "%s" "$HOME/.pi/agent/skills" ;;
    copilot) printf "%s" "$HOME/.copilot/skills" ;;
    codex) printf "%s" "$HOME/.codex/skills" ;;
    opencode) printf "%s" "$HOME/.config/opencode/skills" ;;
    *) fail "unknown agent: $1" ;;
  esac
}

display_path() {
  local path="$1"
  if [[ "$path" == "$HOME/"* ]]; then
    printf "%s/%s" "~" "${path#"$HOME/"}"
  else
    printf "%s" "$path"
  fi
}

add_selected_agent() {
  local agent="$1"
  if [[ "$agent" == "all" ]]; then
    SELECTED_AGENTS=("${SUPPORTED_AGENTS[@]}")
    return
  fi
  contains_value "$agent" "${SUPPORTED_AGENTS[@]}" ||
    fail "unknown agent '$agent' (choose from: ${SUPPORTED_AGENTS[*]} all)"
  if [[ ${#SELECTED_AGENTS[@]} -eq 0 ]] || ! contains_value "$agent" "${SELECTED_AGENTS[@]}"; then
    SELECTED_AGENTS+=("$agent")
  fi
}

prompt_for_agents() {
  local answer agent
  echo "Which agents should get the skills?"
  echo "  Options: ${SUPPORTED_AGENTS[*]} all"
  read -r -p "Agents (space separated): " answer
  for agent in $answer; do
    add_selected_agent "$agent"
  done
  [[ ${#SELECTED_AGENTS[@]} -gt 0 ]] || fail "no agents selected"
}

prompt_for_install_mode() {
  local answer
  echo "How should the skills be installed?"
  echo "  1) symlink  — link to this repo (edits are live)"
  echo "  2) replace  — copy, overwriting existing installed skills"
  echo "  3) missing  — copy only files that are not there yet"
  read -r -p "Mode [1-3 or name]: " answer
  case "$answer" in
    1) INSTALL_MODE=symlink ;;
    2) INSTALL_MODE=replace ;;
    3) INSTALL_MODE=missing ;;
    *) INSTALL_MODE="$answer" ;;
  esac
}

copy_skill_directory() {
  local source_dir="$1"
  local destination_dir="$2"
  local only_copy_missing_files="$3"
  local relative_path pattern skip_file

  mkdir -p "$destination_dir"
  while IFS= read -r -d '' relative_path; do
    relative_path="${relative_path#./}"
    skip_file=false
    for pattern in "${COPY_EXCLUDE_PATTERNS[@]}"; do
      # shellcheck disable=SC2053 # intentional glob match
      [[ "$(basename "$relative_path")" == $pattern ]] && skip_file=true
    done
    $skip_file && continue
    if [[ "$only_copy_missing_files" == true && -e "$destination_dir/$relative_path" ]]; then
      continue
    fi
    mkdir -p "$destination_dir/$(dirname "$relative_path")"
    cp -p "$source_dir/$relative_path" "$destination_dir/$relative_path"
  done < <(cd "$source_dir" && find . -type f -print0)
}

install_skill() {
  local skill_name="$1"
  local agent_dir="$2"
  local source_dir="$SKILLS_SOURCE_DIR/$skill_name"
  local destination="$agent_dir/$skill_name"
  local destination_label
  destination_label="$(display_path "$destination")"

  case "$INSTALL_MODE" in
    symlink)
      if [[ -L "$destination" && "$(readlink "$destination")" == "$source_dir" ]]; then
        echo "  = $skill_name (already linked)"
      elif [[ -e "$destination" && ! -L "$destination" ]]; then
        echo "  ! $skill_name skipped: $destination_label exists and is not a symlink (use --mode replace)"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
      else
        ln -sfn "$source_dir" "$destination"
        echo "  → $skill_name linked"
      fi
      ;;
    replace)
      # rm on a symlink removes the link only, never the repo directory it points to.
      rm -rf "$destination"
      copy_skill_directory "$source_dir" "$destination" false
      echo "  ↻ $skill_name replaced"
      ;;
    missing)
      if [[ -L "$destination" ]]; then
        echo "  = $skill_name skipped: $destination_label is a symlink"
      else
        copy_skill_directory "$source_dir" "$destination" true
        echo "  + $skill_name missing files copied"
      fi
      ;;
  esac
}

SELECTED_AGENTS=()
INSTALL_MODE=""
SKIPPED_COUNT=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) show_help; exit 0 ;;
    --agent) [[ $# -ge 2 ]] || fail "--agent needs a value"; add_selected_agent "$2"; shift 2 ;;
    --agent=*) add_selected_agent "${1#--agent=}"; shift ;;
    --mode) [[ $# -ge 2 ]] || fail "--mode needs a value"; INSTALL_MODE="$2"; shift 2 ;;
    --mode=*) INSTALL_MODE="${1#--mode=}"; shift ;;
    *) fail "unknown option '$1' (see --help)" ;;
  esac
done

if [[ ${#SELECTED_AGENTS[@]} -eq 0 || -z "$INSTALL_MODE" ]] && [[ ! -t 0 ]]; then
  fail "--agent and --mode are required when not running interactively"
fi
[[ ${#SELECTED_AGENTS[@]} -gt 0 ]] || prompt_for_agents
[[ -n "$INSTALL_MODE" ]] || prompt_for_install_mode
contains_value "$INSTALL_MODE" "${SUPPORTED_INSTALL_MODES[@]}" ||
  fail "unknown mode '$INSTALL_MODE' (choose from: ${SUPPORTED_INSTALL_MODES[*]})"

SKILL_NAMES=()
for skill_file in "$SKILLS_SOURCE_DIR"/*/SKILL.md; do
  [[ -f "$skill_file" ]] || continue
  SKILL_NAMES+=("$(basename "$(dirname "$skill_file")")")
done
[[ ${#SKILL_NAMES[@]} -gt 0 ]] || fail "no skills found in $SKILLS_SOURCE_DIR"

for agent in "${SELECTED_AGENTS[@]}"; do
  agent_dir="$(agent_skills_dir "$agent")"
  echo "Installing ${#SKILL_NAMES[@]} skills for $agent → $(display_path "$agent_dir") ($INSTALL_MODE)"
  mkdir -p "$agent_dir"
  for skill_name in "${SKILL_NAMES[@]}"; do
    install_skill "$skill_name" "$agent_dir"
  done
done

if [[ $SKIPPED_COUNT -gt 0 ]]; then
  echo ""
  echo "$SKIPPED_COUNT skill(s) were skipped because of conflicts; see '!' lines above."
fi
echo "Done."
