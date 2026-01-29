#!/bin/bash
# Dotfiles installation script
# Usage: ~/.dotfiles/install.sh

set -e

DOTFILES="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "=== Dotfiles Installation ==="
echo ""

# Check for stow
if ! command -v stow &> /dev/null; then
    echo "Installing GNU Stow..."
    if command -v brew &> /dev/null; then
        brew install stow
    else
        echo "Error: Please install GNU Stow manually"
        exit 1
    fi
fi

# Generate MCP configs from source
echo "Generating MCP configs..."
python3 "$DOTFILES/mcp/generate.py"

# Backup existing configs
echo ""
echo "Backing up existing configs to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

# Claude Code configs
if [ -e "$HOME/.claude" ] && [ ! -L "$HOME/.claude" ]; then
    for file in CLAUDE.md mcp_servers.json settings.json settings.local.json; do
        if [ -e "$HOME/.claude/$file" ] && [ ! -L "$HOME/.claude/$file" ]; then
            mkdir -p "$BACKUP_DIR/.claude"
            cp "$HOME/.claude/$file" "$BACKUP_DIR/.claude/" 2>/dev/null || true
            rm "$HOME/.claude/$file" 2>/dev/null || true
        fi
    done
    if [ -d "$HOME/.claude/hooks" ] && [ ! -L "$HOME/.claude/hooks" ]; then
        cp -r "$HOME/.claude/hooks" "$BACKUP_DIR/.claude/" 2>/dev/null || true
        rm -rf "$HOME/.claude/hooks" 2>/dev/null || true
    fi
fi

# Claude Desktop config
DESKTOP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
if [ -e "$DESKTOP_CONFIG" ] && [ ! -L "$DESKTOP_CONFIG" ]; then
    mkdir -p "$BACKUP_DIR/claude-desktop"
    cp "$DESKTOP_CONFIG" "$BACKUP_DIR/claude-desktop/" 2>/dev/null || true
    rm "$DESKTOP_CONFIG" 2>/dev/null || true
fi

# Ensure target directories exist
mkdir -p "$HOME/.claude"
mkdir -p "$HOME/Library/Application Support/Claude"

# Stow packages
echo ""
echo "Stowing packages..."
cd "$DOTFILES"

# Use --adopt to handle any remaining files, then restore from git
stow -v --target="$HOME" claude 2>/dev/null || stow -v --adopt --target="$HOME" claude
stow -v --target="$HOME" claude-desktop 2>/dev/null || stow -v --adopt --target="$HOME" claude-desktop

# Restore dotfiles versions (in case --adopt pulled in different versions)
git checkout -- . 2>/dev/null || true

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Symlinks created:"
echo "  ~/.claude/CLAUDE.md -> ~/.dotfiles/claude/.claude/CLAUDE.md"
echo "  ~/.claude/mcp_servers.json -> ~/.dotfiles/claude/.claude/mcp_servers.json"
echo "  ~/.claude/settings.json -> ~/.dotfiles/claude/.claude/settings.json"
echo "  ~/.claude/settings.local.json -> ~/.dotfiles/claude/.claude/settings.local.json"
echo "  ~/.claude/hooks/ -> ~/.dotfiles/claude/.claude/hooks/"
echo "  ~/Library/.../claude_desktop_config.json -> ~/.dotfiles/claude-desktop/..."
echo ""
echo "Backup saved to: $BACKUP_DIR"
echo ""
echo "To update MCP servers:"
echo "  1. Edit ~/.dotfiles/mcp/servers.yaml"
echo "  2. Run: python3 ~/.dotfiles/mcp/generate.py"
echo ""
echo "To add changes to git:"
echo "  cd ~/.dotfiles && git add -A && git commit -m 'Update configs'"
