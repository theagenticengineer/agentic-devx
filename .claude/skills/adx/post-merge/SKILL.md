Clean up after a PR is merged. Remove the local worktree, delete the branch,
and update the Graphite stack state.

## Steps

1. Identify the current branch from `git symbolic-ref --short HEAD`.
2. `gt sync` — pull the merge commit and update the stack.
3. `git worktree remove .worktrees/<branch>` — remove the linked worktree.
4. `git branch -d <branch>` — delete the local branch. If this fails,
   troubleshoot: the branch content was merged, so `-d` should succeed. Do not
   use `-D` to force-delete.
5. Delete the issue draft from `tmp/issues/` (already on GitHub).
6. Report completion: branch deleted, worktree removed, stack updated.
