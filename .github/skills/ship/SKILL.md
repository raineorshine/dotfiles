---
name: ship
description: 'Finish a feature branch in a worktree: release the demo lock, run the shellcheck lint gate, commit, rebase on origin/main, squash, push to origin/main, fast-forward the live main checkout when it is safe, extract the session's learnings, and archive the session. Use when done with a change in this dotfiles repo and want it on main without opening a PR.'
---

# Ship (finish feature → merge to main)

Solo-developer workflow for this dotfiles repo. Take the current feature branch (usually in a worktree), verify it, squash it to a single commit, push it to `origin/main`, and fast-forward the main checkout so it goes live. No PR.

`origin/main` is the source of truth, not the local `main` ref. The main checkout is also the live slot every shell reads (docs/workflow.md), so it can be dirty — another session's demo installed under the lock, or someone's uncommitted edits — exactly when you want to land. Pushing from the worktree keeps shipping independent of that; the main checkout catches up in step 6 when it safely can.

Never ship from the main checkout. A change found there uncommitted belongs to whoever made it (step 6 says how to land it).

## Procedure

### 0. Release the demo lock

```bash
./scripts/dotfiles-test-lock.sh release --if-mine && ./scripts/dotfiles-test-lock.sh status
```

If the `test` skill demoed this branch, its files are still installed in the live slot and the lock is still held; step 6's fast-forward would trip over them, so release first. If the title carries `🔒 `, swap it to `📦 ` before releasing. `--if-mine` is a silent no-op when this session holds no lock. Do not report either.

`status` tells you now what step 6 will face. **Locked by another session** means the ship still lands on `origin/main`, but the main checkout stays behind until that holder releases; say so in the report rather than waiting.

Ship what you demoed — if the branch changed after the last `install`, demo again first.

### 1. Quality gate (must pass before committing)

```bash
npm run lint
```

- `npm run lint` — `shellcheck` on the bash files `.bash_profile`, `.bashrc` and `scripts/*.sh` (config in `.shellcheckrc`), then `zsh -n` on the zsh files `.zshrc` and `.zprofile`.

This covers every shell file in the repo, so it is the whole gate. Fix every finding, then re-run before proceeding. There is no type check or test suite here.

**Never run `shellcheck` on a zsh file.** shellcheck has no zsh dialect (`SC1071`), so it can only be forced into bash mode with `-s bash`, where correct zsh — `$arr[i]` subscripts, `${(f)...}` expansion flags, `${=var}` splitting, `echo` escapes — reports as dozens of errors. Acting on those findings breaks the file. `zsh -n` is the syntax check for those files, and the lint script already runs it.

`zsh -n` only catches parse errors. To check function scoping in zsh, source the file and exercise the function under `setopt warn_create_global`, which reports any variable a function creates globally:

```bash
zsh -c 'source ./.zshrc >/dev/null 2>&1; setopt warn_create_global; <function> <args> >/dev/null'
```

This is runtime-only — it cannot be a lint gate, since it sees just the code paths that actually execute. Run it on functions you touched.

### 2. Commit all staged and unstaged changes

Generate a commit message from the diff. Use an imperative, sentence-case subject (`Add …`, `Fix …`, `Set …`, `Remove …`) to match the repo's history. A `type:` prefix is optional and used only occasionally here — plain imperative subjects are the norm. Follow the conventions in `AGENTS.md`.

### 3. Rebase on origin/main

```bash
git fetch origin && git rebase origin/main
```

Rebase on `origin/main`, not the local `main` ref: the main checkout may have been unable to fast-forward after another ship, so local `main` can be behind what you must land on.

If the rebase hits conflicts: resolve them (prefer the branch changes unless clearly wrong), `git add` the resolved files, `git rebase --continue`, and repeat until it completes.

### 4. Squash all commits into one

```bash
git reset --soft origin/main && git commit -m "subject" -m "body"
```

Use a single message that describes the overall diff. The repo is public: read the squashed diff for secrets before pushing.

### 5. Push to origin/main

```bash
git push origin HEAD:main
```

This is the ship. It runs from the worktree and touches no other working tree, so a dirty main checkout cannot block it.

**If the push is rejected as non-fast-forward:** someone else landed first. Nothing was lost. Go back to **step 3**, redo **step 4** to re-squash onto the new base, and push again. Because `origin/main` only advances by fast-forward, at most one branch wins each round and the others rebase and retry — no merge commits, no clobbering.

Once the push succeeds, and not before, set the title's prefix to `🚀 ` (`get_session` with `"self"`, then `set_session_title`, replacing the previous prefix). Do not report this.

### 6. Fast-forward the main checkout (go live)

```bash
MAIN=$(git worktree list --porcelain | head -1 | sed 's/^worktree //') && if ! ./scripts/dotfiles-test-lock.sh check; then echo "main checkout left behind: another session holds the demo lock"; else git -C "$MAIN" fetch origin && git -C "$MAIN" merge --ff-only origin/main; fi
```

This is what makes the change live: the main checkout's working tree *is* `~/.zshrc` and the rest.

- **Lock held by another session:** the script prints the holder (with a `link` line) and skips. Its dirty files are that demo's installed copies — never commit, check out, or stash them. One line in the report, with the link: the change is on `origin/main` and goes live when that holder releases and anyone's next ship fast-forwards.
- **Unlocked, and the merge refuses because local changes would be overwritten:** someone's uncommitted edits, already live, overlap the shipped files. Do not stop, and never `checkout --` them away. Follow AGENTS.md: find the session that made them, read the diff for secrets, commit each change separately in the main checkout, then `git -C "$MAIN" rebase origin/main`, run `npm run lint` there, and `git -C "$MAIN" push origin main`. Dirty files that do not overlap the shipped ones do not block the fast-forward; leave those for their owner.
- **"Not possible to fast-forward":** local `main` has commits `origin` lacks (a session committed in the main checkout). Rebase it onto `origin/main` and push, as above.

Then verify in a fresh login shell (`zsh -lic '…'`) that the shipped change is live. If `package.json` or `yarn.lock` changed, run `yarn install` in the main checkout.

### 7. Extract the learnings

Invoke the `learn` skill. A shipped change is the moment its lessons are worth writing down: the branch is landed, nothing is pending, and whatever the session learned about the shell config, the tree or the workflow is still in context — an hour later it is in nobody's. This is not optional and the user does not have to ask for it; it is the last stage of shipping.

Skip it only when `learn` or `learn-organize` is what invoked this ship — their own procedures end in one, and landing those learnings is that ship's whole job. Otherwise the two call each other forever.

If `learn` finds nothing worth recording, that is a normal outcome — say so in one line and move on.

### 8. Print the completion message

Print `🚀 Shipped` as the last line of the response, after the learn report.

### 9. Archive the session

Last of all, after `learn` has finished, archive this session: `mcp__ccd_session_mgmt__archive_session` with `"self"`
and a reason naming the ship. It is the final tool call of the ship, made in the same response as the completion message and after it — nothing after the
archive reaches the user. Asking to ship is the agreement to archive; do not ask again.

Skip it when `learn` or `learn-organize` invoked this ship: the session goes on after that ship. A
ship that never reached `origin/main` is still work in progress and keeps its session.

**The archive refuses while anything of this session is still pending** — a background task, an armed
waiter, a scheduled wakeup left as a fallback. Stop each one first (a pending wakeup is cancelled with
`ScheduleWakeup` and `stop: true`); if it still refuses, the user archives from the sidebar.

Archiving removes the session's worktree, if it has one, and the demo lock belongs to that worktree's path: if anything took the lock again since step 0, release it first. The branch outlives it, and the session is
reopened from the Archived list if it is ever needed again.
