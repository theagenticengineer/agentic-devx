Fetch the GitHub issue, create the worktree, generate an implementation plan,
and post it as a GitHub issue comment.

**Trigger:** `/adx:start-issue <N>` where N is the GitHub issue number.

## Steps

1. `gh issue view N` — extract the `Branch name:` field from the issue body.
2. Suggest `/clear` (full context clear, not compact) before continuing.
3. Check if the worktree already exists at `.worktrees/<branch>` (via
   `git worktree list`).
4. If it does not exist, create it:

   ```bash
   git worktree add .worktrees/<branch> -b <branch>
   ```

5. `gt track` — register the branch with Graphite.
6. Generate an implementation plan from the issue title, body, and acceptance
   criteria. Present the plan to the user for review.
7. Iterate with the user until the plan is approved. Do not proceed until the
   user explicitly approves.
8. Post the approved plan as a GitHub issue comment:

   ```bash
   gh issue comment N --body "..."
   ```

9. **STOP GATE:** verify the plan comment was posted by running
   `gh issue view N --comments` and confirming the plan text appears. Do not
   proceed until verified.
10. Ask the user: "Ready to implement the plan?" If yes, execute the plan.
11. Verify completion:
    - All quality gates pass (commit messages, lints, tests)
    - All deliverables are verified
    - All acceptance criteria are satisfied
12. Run `/adx:submit-pr`.

## Output

- Worktree at `.worktrees/<branch>`
- Plan posted as issue comment
- Implementation complete and verified
- PR submitted via `/adx:submit-pr`
