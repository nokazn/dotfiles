# Agent guidelines

**Always respect the contents of this file.**

- Code should document How, test code should document What, commit logs should document Why, and code comments should document Why not (do not add comments explaining what or how the code does things)

## Communication

- Respond in Japanese.
  - For anything other than session interactions (code, docs, commit messages, etc.), follow the repository/project conventions.
- `?` (question) → Answer the question only. Do not take any action.
- Normal instruction → Evaluate whether the instruction is sound before executing. If there is a concern, confirm with the user first.
- `!!` or `！！` (imperative) → Execute immediately regardless of concerns, but communicate any risks or reservations alongside the action.
- When asking to run a command, briefly explain what it does.
- When additional prompts come in during a session, incorporate the new instructions into the ongoing work without discarding existing progress.

## Solutions

- Prefer **simple** solutions over easy ones.
- Prefer **explicit** over implicit.

## Design Principles

- Keep functions pure by default; isolate side effects where unavoidable.
- Follow Design by Contract: clarify preconditions, postconditions, and invariants before designing interfaces and module boundaries.
  - Infer technical contracts from code, types, and existing patterns autonomously.
  - Ask the user for domain/business constraints that are not derivable from code.

## Workflows

- **Session start**: Before beginning new work, verify current branch (`git branch --show-current`) matches intended work. If on an unexpected branch, report to user and confirm whether to switch or create a new branch.
- **Repo lock**: If editing is blocked by a repo lock (another session is active), create a worktree and continue work there:
  `git worktree add ../<repo>-wt-<branch> -b <branch> && cd ../<repo>-wt-<branch>`
- Before editing a file, **ALWAYS** re-read it to check for user changes since the last read. Incorporate those changes into the next edit. If the changes seem inconsistent or unclear, ask the user before proceeding.
- Keep documentation up to date with code changes
- Use subagents for small-to-medium self-contained tasks
  - Do NOT use subagents for open-ended tasks. Instead, **continue open-ended
    tasks in the main context**
  - Run subagents in parallel when tasks are parallelizable

### Git Workflows

- Only commit or push when explicitly instructed
- When committing, follow the `me-git-commits` skill
- When switching branches or pulling, run `git fetch` first and reference remote branches (origin/upstream) to ensure up-to-date state
- **Worktree safety**:
  - Never stash, checkout, or switch branches in a worktree that has uncommitted changes — always create a new worktree instead. Confirm with user before touching an existing worktree's changes.
  - If a worktree is meant for a specific branch and the current checkout doesn't match, confirm with the user before proceeding.

### Store documents under `~/.agents/` directory

- Under `~/.agents`, use 2 levels of directories based on the working directory path relative to the home directory. File format: `YYYYmmdd_<description>.md`.
  - e.g. When running an agent under `~/private/app` and storing documents, use `~/.agents/private/app/20260101_something.md`.
- If in a git worktree, resolve the main worktree path (`git worktree list | head -1 | awk '{print $1}'`) and use that as the base for the directory structure instead of the current working directory.
- If the project has a designated location, follow that convention instead

## Skills

- When looking for a skill, prefer `me-` prefixed skills first
- If no matching skill is found, use the `find-skills` skill to search
