# Dotfiles Conventions

- Keep aliases and functions in SEPARATE sections in .bashrc — never define functions inside the alias block
- Prefer separate named shortcuts (e.g. lst10/lst20/...) over a single parameterized function, but have them delegate to a shared helper (e.g. `_lst`)
- COPILOT_MODEL_SMALL var holds the cheap copilot model for quick tasks (commit messages); currently "claude-haiku-4.5"
