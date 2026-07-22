# Dotfiles Conventions

- Keep aliases and functions in SEPARATE sections in .bashrc — never define functions inside the alias block
- Prefer separate named shortcuts (e.g. lst10/lst20/...) over a single parameterized function, but have them delegate to a shared helper (e.g. `_lst`)
- zsh does NOT word-split unquoted variable expansions like bash does. To split a string into words, use `${=var}` in zsh (or build an array). Store multi-word commands in an array and invoke with `"${arr[@]}"` so they work in both bash and zsh
