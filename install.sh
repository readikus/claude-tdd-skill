#!/bin/bash
set -euo pipefail

# TDD Skill Installer
# Copies skill files into ~/.claude/ for use with Claude Code

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " TDD Skill — Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check Claude Code directory exists
if [ ! -d "$CLAUDE_DIR" ]; then
  echo "Error: ~/.claude/ directory not found."
  echo "Make sure Claude Code is installed first."
  exit 1
fi

# Create target directories
mkdir -p "${CLAUDE_DIR}/commands/tdd"
mkdir -p "${CLAUDE_DIR}/agents"
mkdir -p "${CLAUDE_DIR}/tdd-skill/workflows"
mkdir -p "${CLAUDE_DIR}/tdd-skill/templates"
mkdir -p "${CLAUDE_DIR}/tdd-skill/references"

# Copy commands (user-facing /tdd:* skills)
echo "Installing commands..."
cp "${SCRIPT_DIR}/commands/tdd/"*.md "${CLAUDE_DIR}/commands/tdd/"

# Copy agents
echo "Installing agents..."
cp "${SCRIPT_DIR}/agents/"*.md "${CLAUDE_DIR}/agents/"

# Copy workflows, templates, references
echo "Installing workflows..."
cp "${SCRIPT_DIR}/workflows/"*.md "${CLAUDE_DIR}/tdd-skill/workflows/"

echo "Installing templates..."
cp "${SCRIPT_DIR}/templates/"*.md "${CLAUDE_DIR}/tdd-skill/templates/"

echo "Installing references..."
cp "${SCRIPT_DIR}/references/"*.md "${CLAUDE_DIR}/tdd-skill/references/"

# Update command files to use installed paths
echo "Updating file paths..."
for f in "${CLAUDE_DIR}/commands/tdd/"*.md; do
  sed -i '' "s|@workflows/|@${CLAUDE_DIR}/tdd-skill/workflows/|g" "$f"
  sed -i '' "s|@references/|@${CLAUDE_DIR}/tdd-skill/references/|g" "$f"
  sed -i '' "s|@templates/|@${CLAUDE_DIR}/tdd-skill/templates/|g" "$f"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " TDD Skill installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Available commands:"
echo "  /tdd:plan [target]    — Create test plan"
echo "  /tdd:execute [phase]  — Execute with TDD enforcement"
echo "  /tdd:review [path]    — Audit existing tests"
echo "  /tdd:help             — Usage guide"
echo ""
echo "For Linear integration, configure the Linear MCP server"
echo "in your Claude Code settings."
echo ""
