#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS=(review.md code.md rd.md)

usage() {
  cat <<EOF
Usage: ./install.sh <mode> [options]

Modes:
  global            Install skills to ~/.claude/commands/ (available in all projects)
  project [path]    Install skills to <path>/.claude/commands/ (default: current directory)
  submodule [path]  Add this repo as a git submodule and install to the project

Options:
  --copy            Copy files instead of symlink (default on Windows)
  --link            Force symlink mode
  --remove          Uninstall skills from target directory

Examples:
  ./install.sh global
  ./install.sh project /path/to/myproject
  ./install.sh global --remove
EOF
  exit 1
}

detect_mode() {
  # Default to copy on Windows (MINGW/MSYS), symlink elsewhere
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) echo "copy" ;;
    *) echo "link" ;;
  esac
}

install_skills() {
  local target_dir="$1"
  local method="$2"

  mkdir -p "$target_dir"

  for skill in "${SKILLS[@]}"; do
    local src="$SCRIPT_DIR/$skill"
    local dst="$target_dir/$skill"

    if [ ! -f "$src" ]; then
      echo "  [SKIP] $skill not found"
      continue
    fi

    # Remove existing file/symlink first
    [ -e "$dst" ] || [ -L "$dst" ] && rm -f "$dst"

    if [ "$method" = "link" ]; then
      ln -s "$src" "$dst"
      echo "  [LINK] $skill -> $dst"
    else
      cp "$src" "$dst"
      echo "  [COPY] $skill -> $dst"
    fi
  done
}

remove_skills() {
  local target_dir="$1"

  for skill in "${SKILLS[@]}"; do
    local dst="$target_dir/$skill"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      rm -f "$dst"
      echo "  [REMOVED] $dst"
    fi
  done
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

  # Install from submodule to .claude/commands/
  install_skills "$project_dir/.claude/commands" "copy"
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
    TARGET="$HOME/.claude/commands"
    if $REMOVE; then
      echo "Removing skills from $TARGET ..."
      remove_skills "$TARGET"
    else
      echo "Installing skills to $TARGET ($METHOD) ..."
      install_skills "$TARGET" "$METHOD"
    fi
    ;;
  project)
    TARGET="${TARGET_PATH:-.}/.claude/commands"
    if $REMOVE; then
      echo "Removing skills from $TARGET ..."
      remove_skills "$TARGET"
    else
      echo "Installing skills to $TARGET ($METHOD) ..."
      install_skills "$TARGET" "$METHOD"
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
