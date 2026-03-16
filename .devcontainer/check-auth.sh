#!/usr/bin/env bash
# check-auth.sh
#
# Runs on every container start (postStartCommand) after link-claude-config.sh.
# Checks authentication status for all CLI tools and prints friendly guidance
# for anything that's missing. Never fails — informational only.

set -euo pipefail

# postStartCommand runs in a non-interactive shell — mise isn't activated.
# Export mise-managed tool paths (node, gt, etc.) so checks can find them.
eval "$(~/.local/bin/mise env 2>/dev/null)" || true

echo ""
echo "=== Authentication check ==="
echo ""

ok=true

# --- GitHub CLI ---
if gh auth status &>/dev/null; then
  echo "[ok] gh: authenticated"
else
  ok=false
  echo "[!!] gh: not authenticated"
  echo "     Run on your HOST (not here): gh auth login"
  echo "     Then rebuild the container."
  echo ""
fi

# --- Graphite CLI ---
if gt auth --token &>/dev/null; then
  echo "[ok] gt: authenticated"
else
  ok=false
  echo "[!!] gt: not authenticated"
  echo "     Run on your HOST (not here): gt auth"
  echo "     Then rebuild the container."
  echo ""
fi

# --- Claude Code ---
# Claude Code on macOS stores OAuth tokens in the system Keychain,
# which can't be forwarded to a Linux container. Auth must happen
# inside the container — the token is then stored in the staging
# mount and persists across rebuilds.
claude_json="${HOME}/.claude.json"
claude_creds="${HOME}/.claude/.credentials.json"
claude_ok=false

if [[ -f "$claude_creds" ]] && [[ -s "$claude_creds" ]]; then
  claude_ok=true
elif [[ -f "$claude_json" ]] && grep -q '"oauthAccount"' "$claude_json" 2>/dev/null; then
  claude_ok=true
fi

if $claude_ok; then
  echo "[ok] claude: authenticated"
else
  ok=false
  echo "[!!] claude: not authenticated"
  echo "     Run HERE (inside the container): claude"
  echo "     Complete the OAuth login. Credentials persist across rebuilds."
  echo ""
fi

# --- uv ---
if command -v uv &>/dev/null; then
  echo "[ok] uv: $(uv --version 2>/dev/null || echo 'installed')"
else
  ok=false
  echo "[!!] uv: not found"
  echo "     devcontainer.json should have the jsburckhardt/devcontainer-features/uv feature"
  echo "     Rebuild the container."
  echo ""
fi

# --- PAL MCP Server ---
mcp_json="${HOME}/.claude/.mcp.json"
if [[ -f "$mcp_json" ]] && grep -q '"pal"' "$mcp_json" 2>/dev/null; then
  if ! command -v uvx &>/dev/null; then
    ok=false
    echo "[!!] pal: configured but uvx not installed (required to run PAL)"
    echo ""
  elif [[ -z "${GEMINI_API_KEY:-}" ]]; then
    ok=false
    echo "[!!] pal: configured but GEMINI_API_KEY not set"
    echo "     Set on your HOST: export GEMINI_API_KEY=\"your-key\""
    echo "     Get a key: https://aistudio.google.com/apikey"
    echo "     Then rebuild the container."
    echo ""
  else
    # Live connectivity test: send MCP initialize handshake via stdin
    init_req='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"check-auth","version":"0.1"}}}'
    pal_response=$(printf '%s\n' "$init_req" | timeout 30 uvx --from git+https://github.com/BeehiveInnovations/pal-mcp-server.git pal-mcp-server 2>/dev/null | head -1)
    if echo "$pal_response" | grep -q '"result"' 2>/dev/null; then
      echo "[ok] pal: connected (GEMINI_API_KEY set, MCP handshake passed)"
    else
      ok=false
      echo "[!!] pal: configured but MCP handshake failed"
      echo "     GEMINI_API_KEY is set but the server did not respond."
      echo "     Check your key at: https://aistudio.google.com/apikey"
      echo ""
    fi
  fi
else
  echo "[--] pal: not configured (optional)"
  echo ""
fi

# --- Summary ---
echo ""
if $ok; then
  echo "All tools authenticated. Ready to work!"
else
  echo "Fix the issues above, then you're good to go."
fi
echo ""
