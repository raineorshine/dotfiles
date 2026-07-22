---
name: ship
description: 'Finish a feature branch in a worktree: run the shellcheck lint gate, commit, rebase on master, squash, fast-forward merge into master, and push. Use when done with a change in this dotfiles repo and want it on master without opening a PR.'
---

# Ship (finish feature → merge to master)

Solo-developer workflow for this dotfiles repo. Take the current feature branch (usually in a worktree), verify it, land it on `master` as a single commit via fast-forward merge, and push to `origin`. No PR.

## Procedure

### 1. Quality gate (must pass before committing)

```bash
npm run lint
```

- `npm run lint` — runs `shellcheck` on `.bash_profile` and `.bashrc` (config in `.shellcheckrc`).

If you changed a shell file that isn't covered by the lint script (e.g. `.zshrc`, `.bash_profile`), run `shellcheck` on it as well. Fix every finding, then re-run before proceeding. There is no type check or test suite in this repo.

### 2. Commit all staged and unstaged changes

Generate a commit message from the diff. Use an imperative, sentence-case subject (`Add …`, `Fix …`, `Set …`, `Remove …`) to match the repo's history. A `type:` prefix is optional and used only occasionally here — plain imperative subjects are the norm. Follow the conventions in `AGENTS.md`.

### 3. Rebase on master

```bash
git rebase master
```

If the rebase hits conflicts: resolve them (prefer the branch changes unless clearly wrong), `git add` the resolved files, `git rebase --continue`, and repeat until it completes.

### 4. Squash all commits into one

```bash
git reset --soft master && git commit -m "subject" -m "body"
```

Use a single message that describes the overall diff.

### 5. Fast-forward merge into master

Use this exactly — it resolves the branch and main-worktree paths, so nothing is hardcoded:

```bash
BRANCH=$(git branch --show-current) && MAIN=$(git worktree list | head -1 | awk '{print $1}') && git -C "$MAIN" merge --ff-only "$BRANCH"
```

**If `--ff-only` fails with "Not possible to fast-forward":** another worktree merged into `master` in the meantime, so this branch is no longer a direct descendant. This is expected when running parallel agent sessions and is safe — nothing was merged or lost. Recover by re-integrating on the new `master`:

1. Go back to **step 3** (`git rebase master`) — this replays this branch's single squashed commit onto the updated `master`, surfacing any genuine conflict with the work that landed first. Resolve conflicts the same way.
2. Redo **step 4** (`git reset --soft master && git commit`) to re-squash onto the new base.
3. Retry **step 5**.

Repeat until the fast-forward succeeds. Because `master`'s ref only advances via this atomic `--ff-only` step, at most one worktree wins each round and the others simply rebase and retry — no merge commits, no clobbering.

### 6. Push and post-merge

```bash
MAIN=$(git worktree list | head -1 | awk '{print $1}') && git -C "$MAIN" push origin master
```

- Push `master` to `origin` from the main worktree.
- If `package.json` or `yarn.lock` changed, run `yarn install` in the main worktree so its dependencies match.
- The branch is now merged into `master`. If this worktree is finished with, it and the branch can be cleaned up from the main checkout:

  ```bash
  BRANCH=$(git branch --show-current) && MAIN=$(git worktree list | head -1 | awk '{print $1}') && git -C "$MAIN" worktree remove <this-worktree-path> && git -C "$MAIN" branch -d "$BRANCH"
  ```

  Only do this when the user confirms the worktree is no longer needed.
