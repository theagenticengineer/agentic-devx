#!/usr/bin/env bash
# ci-review.sh
#
# Runs an automated code review using the Gemini API.
# Called by: mise run review → .github/workflows/ci-review.yml
#
# Requires: GEMINI_API_KEY environment variable
# Input: reads the PR diff from stdin or via gh pr diff

set -euo pipefail

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
  echo "WARN: GEMINI_API_KEY not set — skipping CI review"
  exit 0
fi

PR_NUMBER="${1:-}"
if [[ -z "$PR_NUMBER" ]]; then
  # Try to detect PR number from current branch
  BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || true)
  if [[ -n "$BRANCH" ]]; then
    PR_NUMBER=$(gh pr view "$BRANCH" --json number --jq '.number' 2>/dev/null || true)
  fi
fi

if [[ -z "$PR_NUMBER" ]]; then
  echo "WARN: Could not determine PR number — skipping CI review"
  exit 0
fi

DIFF=$(gh pr diff "$PR_NUMBER" 2>/dev/null || true)

if [[ -z "$DIFF" ]]; then
  echo "No diff found for PR #${PR_NUMBER}"
  exit 0
fi

echo "Running Gemini code review for PR #${PR_NUMBER}..."

RESPONSE=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
  -H 'Content-Type: application/json' \
  -d "$(jq -n --arg diff "$DIFF" --arg pr "$PR_NUMBER" '{
    contents: [{
      parts: [{
        text: ("Review this pull request diff for PR #" + $pr + ". Focus on: security issues, bugs, performance problems, and code quality. Be concise. If everything looks good, say so.\n\nDiff:\n" + $diff)
      }]
    }],
    generationConfig: {
      temperature: 0.2,
      maxOutputTokens: 2048
    }
  }')" 2>/dev/null || true)

if [[ -z "$RESPONSE" ]]; then
  echo "WARN: Gemini API call failed — skipping CI review"
  exit 0
fi

REVIEW=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // "No review generated"' 2>/dev/null || echo "Failed to parse response")

echo "## CI Review (Gemini)"
echo ""
echo "$REVIEW"
