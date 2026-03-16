Run a three-layer code review and post each layer's output as a PR comment with
accepted/dismissed reasoning. After all layers pass, verify acceptance criteria.
Hand off to human when complete.

## Layer 1 — Native Claude Code review

1. Run `/review` (built-in Claude Code code review).
2. For each suggestion, either fix it or dismiss it with evidence:
   - Actionable → fix, amend commit, push
   - Dismissed → explain why with reference to authoritative source
3. Post results as a PR comment via `gh pr comment`.

## Layer 2 — PAL cross-model code review

1. Get the full diff: `gh pr diff`
2. Run PAL codereview: `mcp__pal__codereview` with the diff as input.
3. For each suggestion, either fix it or dismiss it with evidence:
   - Actionable → fix, amend commit, push
   - Dismissed → explain why with reference to authoritative source
4. Post results as a PR comment via `gh pr comment`.

## Layer 3 — CI review script

1. Run: `mise run review` (calls `scripts/ci-review.sh`)
2. For each suggestion, either fix it or dismiss it with evidence:
   - Actionable → fix, amend commit, push
   - Dismissed → explain why with reference to authoritative source
3. Post results as a PR comment via `gh pr comment`.

## Acceptance criteria verification

1. Fetch the issue: `gh issue view N` — extract acceptance criteria checklist.
2. Check each criterion against the diff.
3. Post a verification summary as a PR comment (pass/fail per criterion).

## Hand off

Report PR is ready for human merge review once all three layers pass and all
acceptance criteria are verified.
