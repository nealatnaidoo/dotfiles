# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
# Clone
git clone https://github.com/nealatnaidoo/dotfiles.git ~/.dotfiles

# Install
~/.dotfiles/install.sh
```

## Structure

```
~/.dotfiles/
├── install.sh              # Bootstrap script
├── mcp/
│   ├── servers.yaml        # MCP config source of truth
│   └── generate.py         # Generates JSON configs
├── claude/                  # Claude Code configs
│   └── .claude/
│       ├── CLAUDE.md
│       ├── mcp_servers.json (generated)
│       ├── settings.json
│       ├── settings.local.json
│       └── hooks/
├── claude-desktop/          # Claude Desktop configs
│   └── Library/Application Support/Claude/
│       └── claude_desktop_config.json (generated)
├── git/                     # Git configs (future)
└── zsh/                     # Zsh configs (future)
```

## Usage

### Update MCP Servers

1. Edit `~/.dotfiles/mcp/servers.yaml`
2. Run `python3 ~/.dotfiles/mcp/generate.py`
3. Restart Claude Code / Claude Desktop

### Add New Package

1. Create directory: `mkdir -p ~/.dotfiles/newpkg/.config/app/`
2. Add config files
3. Stow: `cd ~/.dotfiles && stow newpkg`

### Manual Stow Commands

```bash
cd ~/.dotfiles

# Install a package
stow claude

# Uninstall a package
stow -D claude

# Reinstall (uninstall + install)
stow -R claude
```

## Related Repos

- [claude-prompts](https://github.com/nealatnaidoo/claude-prompts) - Development prompts, lessons, and agent configurations
