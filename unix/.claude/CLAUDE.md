# Coding guideline

**Always respect the contents of this file.**

- Respond in Japanese.
- Code should document How, test code should document What, commit logs should document Why, and code comments should document Why not (do not add comments explaining what or how the code does things)

## Solutions

- Prefer **simple** solutions over easy ones.
- Prefer **explicit** over implicit.

## Design Principles

- Keep functions pure by default; isolate side effects where unavoidable.
- Follow Design by Contract: clarify preconditions, postconditions, and invariants before designing interfaces and module boundaries.
  - Infer technical contracts from code, types, and existing patterns autonomously.
  - Ask the user for domain/business constraints that are not derivable from code.

## Workflows

- When asking to run a command, briefly explain what it does
- Before editing a file, **ALWAYS** re-read it to check for user changes since the last read. Incorporate those changes into the next edit. If the changes seem inconsistent or unclear, ask the user before proceeding.
- Keep documentation up to date with code changes
- Use subagents for small-to-medium self-contained tasks
  - Do NOT use subagents for open-ended tasks. Instead, **continue open-ended
    tasks in the main context**
  - Run subagents in parallel when tasks are parallelizable

### Git Workflows

- Only commit or push when explicitly instructed
- When committing, follow the `me-git-commits` skill

### Store documents under `~/.agents/` directory

- Under `~/.agents`, use 2 levels of directories based on the working directory path relative to the home directory. File format: `YYYYmmdd_<description>.md`.
  - e.g. When running an agent under `~/private/app` and storing documents, use `~/.agents/private/app/20260101_something.md`.
- If the project has a designated location, follow that convention instead

## Skills

- When looking for a skill, prefer `me-` prefixed skills first
- If no matching skill is found, use the `find-skills` skill to search
