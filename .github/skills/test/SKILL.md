---
name: test
description: "Demo a dotfiles change from a worktree by installing it into the live main checkout under a mutex, so parallel sessions do not clobber each other. Use when trying out, verifying, or showing the user a shell alias, function, export, or bin/ helper before shipping it — 'does this alias work', 'try this function', 'demo the change', 'test it in a new shell'."
---

# Test (demo a change in the live dotfiles)

`~/.zshrc`, `~/.bashrc`, `~/.bash_profile`, `~/.zprofile` and the other dotfiles are symlinks into
the main checkout, `/Users/raine/projects/dotfiles`, and the `bin/*.swift` helpers compile from
there. Every new shell reads that working tree. Worktrees keep their own copies, but no shell ever
reads those — so **editing is parallel, demoing is serial**.

`scripts/dotfiles-test-lock.sh` is the mutex over that live slot. It snapshots the live files
*inside the lock* before overwriting any, so release puts back byte-exactly whatever was there —
committed or not, another session's uncommitted edits included — and a lock abandoned by a dead
session is still recoverable.

## Division of labor

| Where | What it holds | Rule |
|---|---|---|
| `/Users/raine/projects/dotfiles` (main checkout) | the live files every shell reads; `main` | Never edit here, nor `~/.zshrc` and the other symlinks, which *are* this checkout. |
| `.claude/worktrees/*` | one branch each, own copies | All editing happens here, in parallel, lock-free. |
| `/Users/raine/projects/dotfiles/.claude/dotfiles-test.lock/` | the mutex + the pre-demo snapshot | Held only while demoing. A worktree's copy of this directory is stale; ask `status`, never `ls` it. |

**Acquire late, release fast.** Editing, `npm run lint`, and a check that sources the worktree's own
file (`zsh -c 'source ./.zshrc; <function> <args>'`) need no lock. Take it only to show the change
in a real new shell.

## Procedure

Run every command from this worktree (an explicit `cd` into it): the script names the lock's owner
by the shell's working directory.

### 1. Check the lock

```bash
./scripts/dotfiles-test-lock.sh status
```

If another session holds it, **do not wait in a loop.** Tell the user which chat holds it and for
how long, then continue with lock-free work or ask them — they know whether that demo is in flight.

**Link the holding session.** `status`, a denied `acquire` and the other refusals print a `link`
line — `[title](#local_…)` — whenever the holder recorded a desktop session id. Paste it verbatim
into the message; never build one from an id you did not read there.

### 2. Acquire

Prefix this session's title with `🔓 ` first (`set_session_title`, replacing any existing lifecycle
prefix — docs/workflow.md "Session titles"). If the acquire is denied, keep `🔓 ` only while queued
for it. Do not report this.

```bash
./scripts/dotfiles-test-lock.sh acquire "what you are demoing" "<this session's title>"
```

Pass this session's title without its lifecycle prefix (read it from `get_session` with `"self"`),
since the prefix changes while the lock is held. The host session id is
recorded from the environment. Re-running from the same worktree is a no-op and does not
re-snapshot, so an interrupted session can resume.

A `note:` listing uncommitted edits means the live slot already carries someone else's work; it is
in the snapshot and comes back on release.

Once the acquire succeeds, swap the prefix to `🔒 `. Do not report this.

### 3. Install this branch's files

```bash
./scripts/dotfiles-test-lock.sh install
```

With no arguments, installs the live files this branch changed since it left `main` — committed or
not, new `bin/` helpers included — each written atomically so a shell starting mid-install never
sources half a file. Name files to install only those (`install .bashrc`). A live file with
someone else's uncommitted edits that the branch also changes is reported: the branch's copy hides
that edit until release.

A changed `bin/*.swift` helper recompiles on its next use, because the installed source is newer
than the cached binary; release makes the restored source newer again, so it rebuilds back.

### 4. Demo

Check it yourself first, in a fresh login shell — the agent shell does not load `.bash_profile`:

```bash
zsh -lic 'type <function>; echo "$VAR"'
```

When the user should see it, open a new iTerm2 tab for them, which reads the live files:

```bash
osascript -e 'tell application "iTerm2" to tell current window to create tab with default profile'
```

Say what to type and what it should print. Already-open shells keep the old definitions; only a new
shell (or `source ~/.zshrc`) picks the change up.

### 5. Iterate without releasing

Edit in the worktree and re-run `install`. The lock stays held.

### 6. Release

Swap the prefix to `🔓 ` before releasing. Do not report this.

```bash
./scripts/dotfiles-test-lock.sh release
```

Restores the snapshot and drops the lock. Do this as soon as the demo is done — not after writing up
results. Then retitle: `📦 ` if the change passed and is worth shipping without re-demoing, `🚙 ` if
it waits on the user. Do not report this.

If a live file changed underneath you — a hand edit, VS Code saving `settings.json` — release
refuses and offers `--keep` (drop the lock, leave the live files alone) or `--force` (restore
anyway). Look at what changed before choosing; the snapshot path is printed either way.

### 7. Ship

Release first, then follow the `ship` skill. It pushes to `origin/main` from the worktree and then
fast-forwards the main checkout, which is what makes the change live for good.

### Leaving without a ship

A session that stops short of shipping releases first and reads `status` afterwards; `🪦 ` goes on
only once `status` names another holder or none. The lock belongs to the worktree's path, so release
before the worktree is removed.

## Hazards

- **Never commit in the main checkout while a lock is held.** Its dirty files are a demo's installed
  copies, and committing them would land another branch's work on `main`.
- **Do not change VS Code settings while a lock is held** — `settings.json` and `keybindings.json`
  are live files too, and an edit there is caught as drift on release.

## A lock held for hours

**Age is not abandonment.** `status` prints the age and the time the lock was taken and stops there:
a change installed for the user to try, and a user who stepped away, is the ordinary long hold.
`break` needs the user's word that nobody is mid-demo, and restores the snapshot first:

```bash
./scripts/dotfiles-test-lock.sh break --confirmed
```

Ask before running it. If everything is wedged, the snapshot is plain files under
`/Users/raine/projects/dotfiles/.claude/dotfiles-test.lock/snapshot/`.
