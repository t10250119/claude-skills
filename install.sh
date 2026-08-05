#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS=(review.md rd.md qa.md)
AGENTS=(code-explorer.md test-auditor.md solution-evaluator.md diff-critic.md security-auditor.md poe-trade-pricer.md)

usage() {
  cat <<EOF
Usage: ./install.sh <mode> [options]

Modes:
  global            Install skills + agents to ~/.claude/ (available in all projects)
  project [path]    Install skills + agents to <path>/.claude/ (default: current directory)
  submodule [path]  Add this repo as a git submodule and install to the project

Options:
  --copy            Copy files instead of symlink (default on Windows)
  --link            Force symlink mode
  --remove          Uninstall skills + agents from target directory

Skills install to .claude/commands/ — invoked as /code, /qa, /rd, /review.
Agents install to .claude/agents/    — invoked by the Agent tool from skills.

Examples:
  ./install.sh global
  ./install.sh project /path/to/myproject
  ./install.sh global --remove
EOF
  exit 1
}

detect_mode() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) echo "copy" ;;
    *) echo "link" ;;
  esac
}

# install_files <src_dir> <target_dir> <method> <file...>
install_files() {
  local src_dir="$1"; shift
  local target_dir="$1"; shift
  local method="$1"; shift

  mkdir -p "$target_dir"

  for file in "$@"; do
    local src="$src_dir/$file"
    local dst="$target_dir/$file"

    if [ ! -f "$src" ]; then
      echo "  [SKIP] $file not found"
      continue
    fi

    [ -e "$dst" ] || [ -L "$dst" ] && rm -f "$dst"

    if [ "$method" = "link" ]; then
      ln -s "$src" "$dst"
      echo "  [LINK] $file -> $dst"
    else
      cp "$src" "$dst"
      echo "  [COPY] $file -> $dst"
    fi
  done
}

remove_files() {
  local target_dir="$1"; shift

  for file in "$@"; do
    local dst="$target_dir/$file"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      rm -f "$dst"
      echo "  [REMOVED] $dst"
    fi
  done
}

install_all() {
  local claude_dir="$1"
  local method="$2"

  echo "Installing skills to $claude_dir/commands ($method) ..."
  install_files "$SCRIPT_DIR"        "$claude_dir/commands" "$method" "${SKILLS[@]}"

  echo "Installing agents to $claude_dir/agents ($method) ..."
  install_files "$SCRIPT_DIR/agents" "$claude_dir/agents"   "$method" "${AGENTS[@]}"
}

remove_all() {
  local claude_dir="$1"

  echo "Removing skills from $claude_dir/commands ..."
  remove_files "$claude_dir/commands" "${SKILLS[@]}"

  echo "Removing agents from $claude_dir/agents ..."
  remove_files "$claude_dir/agents"   "${AGENTS[@]}"
}

setup_submodule() {
  local project_dir="${1:-.}"
  local submodule_path="$project_dir/.claude-skills"

  if [ ! -d "$project_dir/.git" ]; then
    echo "Error: $project_dir is not a git repository"
    exit 1
  fi

  cd "$project_dir"

  if [ -d "$submodule_path" ]; then
    echo "Submodule already exists at $submodule_path"
  else
    echo "Enter the git remote URL for claude-skills repo:"
    read -r remote_url
    git submodule add "$remote_url" .claude-skills
    echo "  [SUBMODULE] Added at .claude-skills"
  fi

  install_all "$project_dir/.claude" "copy"
}

# --- Main ---

[ $# -lt 1 ] && usage

MODE="$1"
shift

METHOD="$(detect_mode)"
REMOVE=false
TARGET_PATH=""

while [ $# -gt 0 ]; do
  case "$1" in
    --copy)   METHOD="copy" ;;
    --link)   METHOD="link" ;;
    --remove) REMOVE=true ;;
    *)        TARGET_PATH="$1" ;;
  esac
  shift
done

case "$MODE" in
  global)
    CLAUDE_DIR="$HOME/.claude"
    if $REMOVE; then remove_all "$CLAUDE_DIR"
    else             install_all "$CLAUDE_DIR" "$METHOD"
    fi
    ;;
  project)
    CLAUDE_DIR="${TARGET_PATH:-.}/.claude"
    if $REMOVE; then remove_all "$CLAUDE_DIR"
    else             install_all "$CLAUDE_DIR" "$METHOD"
    fi
    ;;
  submodule)
    setup_submodule "${TARGET_PATH:-.}"
    ;;
  *)
    usage
    ;;
esac

echo "Done."
