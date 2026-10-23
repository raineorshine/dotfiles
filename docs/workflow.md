# Workflow: editing, demoing, shipping

## The main checkout is the live slot

`~/.zshrc`, `~/.bashrc`, `~/.bash_profile`, `~/.zprofile`, `~/.inputrc`, `~/.gitconfig`, `~/.vimrc`,
`~/.gvimrc`, `~/.hushlogin` and VS Code's `settings.json` / `keybindings.json` are symlinks into
`/Users/raine/projects/dotfiles`, and the `bin/*.swift` helpers compile from `$dothome/bin` there.
So that working tree is not a place to develop: an edit to it is live in the next shell, and an edit
left uncommitted there blocks every other session's landing.

- **Develop in `.claude/worktrees/`.** A session that finds itself editing `~/.zshrc` or the main
  checkout directly stops and moves the change into a worktree.
- **Demo under the lock.** The `test` skill (`.github/skills/test/SKILL.md`) installs the
  worktree's files into the live slot under `scripts/dotfiles-test-lock.sh`, which snapshots the
  live files first and restores them byte-exactly on release.
- **Land with `ship`.** It pushes the squashed branch to `origin/main` from the worktree, then
  fast-forwards the main checkout. Only then is the change live for good; check with a fresh login
  shell (`zsh -lic '…'`).

## What the lock covers

- **The lock is the main checkout's; ask `status`, never `ls`.** The desktop app copies the main
  checkout's ignored `.claude/` contents into a new worktree, so a worktree's own
  `.claude/dotfiles-test.lock/` is a stale copy.
- **Run the lock script from the worktree.** It names the owner by the shell's working directory.
- **The live set is fixed in the script** (`live_files`): the symlinked dotfiles plus `bin/`. A new
  file that something in `~` links to belongs in that list.
- **`install` defaults to the files the branch changed**, not every file that differs from the live
  slot, so another session's uncommitted edit in a file the branch does not touch stays live
  during the demo.
- **Testing the script never touches the real dotfiles:** point `DOTFILES_ROOT` at a scratch git
  repo with a `git worktree add` beside it and run the commands from that worktree.

## Landing while the main checkout is dirty

`origin/main` is the source of truth, so a dirty main checkout never stops a ship: the push runs from
the worktree. What can lag is the main checkout's fast-forward, and the ship decides it by `status`:

- **Locked by another session:** its dirty files are that demo's installed copies. Leave the main
  checkout alone — no commit, no fast-forward — and say the change goes live when that holder
  releases and the next ship fast-forwards.
- **Unlocked:** the dirty files are someone's uncommitted edits, already live. `merge --ff-only`
  succeeds when they do not overlap the shipped files. When it refuses, commit those edits in the
  main checkout (AGENTS.md says how to find their session), rebase that checkout onto
  `origin/main`, lint, and push.

## Session titles

The lifecycle prefixes apply as the global glossary defines them. What they mean here:

- 🔓 / 🔒 track `scripts/dotfiles-test-lock.sh`; the `test` skill sets them: 🔓 before acquiring,
  while queued, and just after releasing; 🔒 while the lock is held.
- 💾 is inert: installing into the live slot happens only under the lock, which 🔒 already names.
- 📦 means linted (and demoed, if the change is visible in a shell) and shippable.
- 🚀 means the push to `origin/main` landed; `ship` sets it after the push, never before.
