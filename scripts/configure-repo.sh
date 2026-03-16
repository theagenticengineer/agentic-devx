#!/usr/bin/env bash
# configure-repo.sh
#
# Configures GitHub repository settings:
# - Squash-only merge (no merge commits, no rebase)
# - Delete branch on merge
# - Branch protection on main (require PRs, require CI status check)
#
# Requires: gh CLI authenticated with admin access

set -euo pipefail

REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
echo "Configuring repository: ${REPO}"

# --- Merge settings: squash only ---
gh api -X PATCH "repos/${REPO}" \
  -f allow_squash_merge=true \
  -f allow_merge_commit=false \
  -f allow_rebase_merge=false \
  -f delete_branch_on_merge=true \
  --silent

echo "[ok] Merge settings: squash-only, delete branch on merge"

# --- Branch protection on main ---
gh api -X PUT "repos/${REPO}/branches/main/protection" \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["ci"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0
  },
  "restrictions": null
}
EOF

echo "[ok] Branch protection: require PRs, require CI check, enforce admins"
echo ""
echo "Repository configured successfully."
