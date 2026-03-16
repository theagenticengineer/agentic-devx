# CLAUDE.md — Agentic DevX

This is the base SDLC constitution. All agents and human contributors must
follow these rules. Project-specific overrides go in workspace CLAUDE.md files.

## Git Workflow

### Branch Naming

All branches use the pattern: `type/N-slug`

- **Allowed types:** feat, fix, chore, docs, refactor, test
- **N** = GitHub issue number
- **slug** = lowercase kebab-case description
- **Examples:** `feat/2-add-logging`, `chore/1-bootstrap-choreography`

Direct branch checkouts are not allowed. All feature branches must be created
as worktrees:

```bash
git worktree add .worktrees/<branch> -b <branch>
```

The worktree path mirrors the branch name exactly.

### Commit Messages

All commits use the format: `type(#N): message`

- **Allowed types:** feat, fix, chore, docs, refactor, test
- **N** = GitHub issue number
- **message** = at least 10 characters, describing the change
- **Examples:** `feat(#2): add structured logging framework`,
  `fix(#3): resolve null pointer in auth middleware`

### Hooks

Git hooks live in `.githooks/` and are configured via `core.hooksPath`.
Run `mise run setup` after cloning or starting the DevContainer to configure
the hooks path.

| Hook | Purpose |
|------|---------|
| `commit-msg` | Validates commit message format |
| `post-checkout` | Enforces worktree-only branch creation and naming |
| `pre-commit` | Runs `mise run lint` before each commit |

### Merging

- Only **squash merge** is allowed on `main`
- Direct pushes to `main` are blocked by branch protection
- All changes go through pull requests

### Pushing

**Never use `git push` directly.** All branch pushes go through Graphite:

- `gt submit` — push the current branch and create/update the PR
- `gt sync` — pull latest from origin and update the stack
- `gt restack` — rebase stacked branches onto their updated parents

The only exception is the initial bootstrap (`git push --force origin
HEAD:main` in S1.2.5) before branch protection is active.

## Task Runner

`mise` is the universal task runner. All CI and local commands use `mise run`:

| Task | Purpose |
|------|---------|
| `mise run lint` | Markdown linting (markdownlint-cli2) |
| `mise run setup` | Configure git hooks path |
| `mise run review` | Run CI review script |
| `mise run test` | Run tests (project-specific) |

## Skills

SDLC skills use the `adx:` prefix. The full workflow:

```text
/adx:draft-issue → /adx:submit-issue → /adx:start-issue N
→ /adx:submit-pr → /adx:review-pr → /adx:post-merge
```

## Quality Gates

- Markdown files must pass `markdownlint-cli2` (100 char line length)
- Commit messages must match `type(#N): message` (>= 10 chars)
- Branches must match `type/N-slug` pattern
- PRs require CI to pass before merge
- Three-layer code review: native `/review`, PAL cross-model, CI review script

## DevContainer

Open the **main repo root** in VS Code, not a worktree directory. The
DevContainer provides: Claude Code, Graphite CLI, gh CLI, mise, and all hooks.

Run `claude` to start. Use `claude!` for permissive mode.
