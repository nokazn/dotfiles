# Coding guideline

**Always respect the contents of this file.**

- Respond in Japanese.
- Code should document How, test code should document What, commit logs should document Why, and code comments should document Why not (do not add comments explaining what or how the code does things)

## Solutions

- Prefer **simple** solutions over easy ones.

## Workflows

- When asking to run a command, briefly explain what it does
- Keep documentation up to date with code changes
- Use subagents for small-to-medium self-contained tasks
  - Do NOT use subagents for open-ended tasks. Instead, **continue open-ended
    tasks in the main context**
  - Run subagents in parallel when tasks are parallelizable

## Store documents under `~/.agents/` directory

- Under `~/.agents`, maintain the directory structure relative to the home directory. Create `researches/` for research and `plans/` for plans. File format: `YYYYmmdd_<description>.md`.
  - e.g. When running an agent under `~/private/app` and storing documents, use `~/.agents/private/app/{researches,plans}/20260101_something.md`.
- If the project has a designated location for research results or plans, follow that convention instead
