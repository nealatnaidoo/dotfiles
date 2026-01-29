#!/usr/bin/env python3
"""Generate MCP config files from single YAML source.

Usage:
    python ~/.dotfiles/mcp/generate.py

Generates:
    - ~/.dotfiles/claude/.claude/mcp_servers.json (Claude Code format)
    - ~/.dotfiles/claude-desktop/Library/Application Support/Claude/claude_desktop_config.json
"""

import json
from pathlib import Path

import yaml

DOTFILES = Path.home() / ".dotfiles"
SOURCE = DOTFILES / "mcp" / "servers.yaml"

TARGETS = {
    "claude_code": DOTFILES / "claude" / ".claude" / "mcp_servers.json",
    "claude_desktop": DOTFILES / "claude-desktop" / "Library" / "Application Support" / "Claude" / "claude_desktop_config.json",
}


def load_source() -> dict:
    """Load the YAML source file."""
    with open(SOURCE) as f:
        return yaml.safe_load(f)


def generate_claude_code(config: dict) -> dict:
    """Generate Claude Code format (flat servers object)."""
    servers = {}
    for name, server in config["servers"].items():
        # Flatten args if it's a multiline string
        args = server["args"]
        if isinstance(args, list) and len(args) == 2 and args[0] == "-c":
            # Clean up multiline string
            cmd = args[1].replace("\n", " ").strip()
            # Remove extra spaces
            while "  " in cmd:
                cmd = cmd.replace("  ", " ")
            args = ["-c", cmd]

        servers[name] = {
            "command": server["command"],
            "args": args,
            "env": server.get("env", {}),
        }
    return servers


def generate_claude_desktop(config: dict) -> dict:
    """Generate Claude Desktop format (wrapped in mcpServers)."""
    return {"mcpServers": generate_claude_code(config)}


def main():
    print(f"Loading source: {SOURCE}")
    config = load_source()

    # Generate Claude Code config
    claude_code = generate_claude_code(config)
    TARGETS["claude_code"].parent.mkdir(parents=True, exist_ok=True)
    with open(TARGETS["claude_code"], "w") as f:
        json.dump(claude_code, f, indent=2)
    print(f"Generated: {TARGETS['claude_code']}")

    # Generate Claude Desktop config
    claude_desktop = generate_claude_desktop(config)
    TARGETS["claude_desktop"].parent.mkdir(parents=True, exist_ok=True)
    with open(TARGETS["claude_desktop"], "w") as f:
        json.dump(claude_desktop, f, indent=2)
    print(f"Generated: {TARGETS['claude_desktop']}")

    print("\nDone! Run 'stow claude claude-desktop' to update symlinks.")


if __name__ == "__main__":
    main()
