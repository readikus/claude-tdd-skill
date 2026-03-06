#!/bin/bash
set -e

REPO_URL="https://github.com/readikus/claude-tdd-skill.git"
INSTALL_DIR="$HOME/.tdd-skill/repo"
COMMANDS_DIR="$HOME/.claude/commands"

echo "Installing TDD skill for Claude Code..."

# Clone or update the repo
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "Updating existing installation..."
  git -C "$INSTALL_DIR" pull --quiet
else
  echo "Cloning repo..."
  mkdir -p "$(dirname "$INSTALL_DIR")"
  git clone --quiet "$REPO_URL" "$INSTALL_DIR"
fi

# Symlink commands into Claude Code
mkdir -p "$COMMANDS_DIR"
ln -sfn "$INSTALL_DIR/commands/tdd" "$COMMANDS_DIR/tdd"

echo ""
echo "Installed. Commands available:"
echo "  /tdd:plan [target]    — create test plan from requirements"
echo "  /tdd:execute [phase]  — execute GSD phase with TDD enforcement"
echo "  /tdd:review [path]    — audit existing tests for anti-patterns"
echo "  /tdd:help             — usage guide"
echo ""
echo "Restart Claude Code for the commands to be available."
echo "Then run /tdd:help to get started."
