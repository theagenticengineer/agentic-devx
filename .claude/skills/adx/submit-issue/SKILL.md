Read a draft from `tmp/issues/`, show it for human approval, then create or
update the GitHub issue.

## Steps

1. List all files in `tmp/issues/` (excluding `done/`).
   - If no drafts exist, report "No drafts found" and stop.
   - If one draft exists, show its slug (titleized, without the hash prefix) and
     ask for yes/no confirmation.
   - If multiple drafts exist, present a numbered list (titleized slugs, no
     hashes) and ask the user to select one.
2. Display the full content of the selected draft for human review. Wait for
   approval before continuing.
3. Check if the draft's `Branch name:` field contains a known issue number (e.g.,
   `chore/1-bootstrap-choreography` → issue #1). If so, check whether that issue
   already exists on GitHub via `gh issue view N`.
   - If the issue exists, confirm with the user: "Issue #N already exists. Update
     it with this draft? (y/n)"
   - If yes, update: `gh issue edit N --title "<title>" --body-file <path>`
   - If no, create a new issue instead.
4. If no existing issue was detected, create a new one:
   `gh issue create --title "<title>" --body-file <path>`
5. Print the issue URL and number.

## Output

GitHub issue URL + number printed to stdout.
