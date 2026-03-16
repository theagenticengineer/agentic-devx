Synthesize a GitHub issue draft from user-provided context and write it to
`tmp/issues/`. The branch name is embedded in the draft so `/adx:start-issue`
can create the correct worktree without prompting.

## Steps

1. **Context source** — ask the user:
   1. Please provide the context for this issue.
   2. Use the conversation context to draft the issue.

   Wait for the user to answer `1` or `2`. If `1`, wait for the user to provide
   the context before continuing.

2. **Branch name** — ask the user:
   1. Do you want to provide a branch name (to continue work on an existing
      branch)?
   2. Do you want me to suggest a new branch name (`type/N-slugname`)?

   Wait for the user to answer. If `1`, wait for the branch name. If `2`,
   suggest a branch name based on the context and confirm.

3. Derive a slug from the branch name (e.g., `chore/1-bootstrap-choreography` →
   `bootstrap-choreography`).
4. Generate a short hash (first 8 chars of SHA-256 of the slug).
5. Synthesize the issue title and body from the context, following the issue
   template in `.github/ISSUE_TEMPLATE/issue.md`.
6. Set `Branch name: <branch-name>` in the issue body.
7. Write to `tmp/issues/<hash>-<slug>.md` and print the path.

## Output

`tmp/issues/<hash>-<slug>.md`
