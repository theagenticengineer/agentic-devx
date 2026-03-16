Encapsulate the Graphite PR submission workflow. Handle sync and restack
automatically.

## Steps

1. `gt sync` — pull latest from origin and update the stack.
2. If the branch is stacked, `gt restack` to rebase onto the updated parent.
3. `gt submit` — push the branch and create/update the PR on GitHub. The branch
   is already tracked (done in `/adx:start-issue`).
4. Update the PR title:

   ```bash
   gh pr edit --title "Closes #N: <short description>"
   ```

   Extract `N` from the branch name (`type/N-desc`) or commit message
   (`type(#N):`).

5. Update the PR body with Summary and Test plan sections:

   ```bash
   gh pr edit --body "..."
   ```

6. Run `/adx:review-pr`.

## Output

PR URL printed to stdout, then review started.
