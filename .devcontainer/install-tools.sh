#!/usr/bin/env bash
# install-tools.sh
#
# Runs once via postCreateCommand when the container is first created (or rebuilt).
# Installs mise, Claude Code, Graphite CLI. Sets claude! alias.
# Ends with `mise run setup` to write absolute core.hooksPath into .git/config.

set -euo pipefail

# --- mise ---
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
# mise trust MUST run before activation — activation reads .mise.toml and aborts
# with set -euo pipefail if the config is not yet trusted.
mise trust
eval "$(mise activate bash)"
grep -q 'mise activate' ~/.bashrc 2>/dev/null || \
  echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc

# --- Project tools from .mise.toml (markdownlint-cli2, etc.) ---
mise install

# --- Claude Code ---
# ~/.claude/projects is bind-mounted, which causes Docker to create ~/.claude as root.
# Fix ownership before the installer writes to it.
sudo chown "$(id -u):$(id -g)" "$HOME/.claude"
curl -fsSL https://claude.ai/install.sh | bash

# --- Graphite CLI (requires node — installed by mise or system) ---
npm i -g @withgraphite/graphite-cli@latest

# --- Shell aliases (bash and zsh) ---
for rc in ~/.bashrc ~/.zshrc; do
  touch "$rc"
  grep -q 'alias claude!' "$rc" 2>/dev/null || \
    echo "alias claude!='claude --dangerously-skip-permissions'" >> "$rc"
  grep -q '.local/bin' "$rc" 2>/dev/null || \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
done

# --- Configure git hooks path (absolute path, works from any worktree) ---
mise run setup
