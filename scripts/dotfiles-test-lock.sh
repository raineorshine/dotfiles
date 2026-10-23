#!/bin/sh
# Mutex for the live dotfiles: the main checkout's working tree.
#
# ~/.zshrc, ~/.bashrc, ~/.bash_profile, ~/.zprofile and the other dotfiles are
# symlinks into the main checkout (/Users/raine/projects/dotfiles), and the
# helpers in bin/ compile from there too, so every new shell reads that working
# tree. Worktrees edit their own copies freely, but demoing a change means
# putting it in that single live slot -- a single-slot resource, so demos are
# serialized through this lock.
#
# The live files are snapshotted inside the lock, so release restores
# byte-exactly whatever was there (committed or not, someone else's uncommitted
# edits included), and a lock left behind by a dead session can still be
# recovered by `break`.
#
# Age is not abandonment. A change installed for the user to try in a new
# terminal, and a user who has stepped away, is the ordinary long hold, so
# nothing here expires: `status` reports the age and draws no conclusion from
# it, and `break` refuses without the user's word however old the lock is.
#
#   acquire [label] [session]
#                     take the lock and snapshot the live files, naming any that
#                     already differ from HEAD; `session` names the Claude session
#                     holding it (falls back to $DOTFILES_SESSION)
#   install [file...] copy this worktree's versions of the live files into the
#                     live slot -- by default every one that differs from it
#   release           restore the snapshot and drop the lock
#                     --keep     drop the lock, leave the live files as they are
#                     --force    restore even if a live file changed
#                     --if-mine  no-op unless this session took the lock
#   status            who holds it and since when -- no verdict on either
#   check             exit 0 if unlocked or held by this worktree; otherwise print
#                     the holder and exit 1 -- for scripts that touch the live slot
#   break --confirmed force-release a lock, only ever after the user has said
#                     nobody is mid-demo -- no age says that on its own
#
# DOTFILES_ROOT points the whole script at another live slot, so it can be
# exercised against a scratch directory without touching the real dotfiles.
set -eu

ROOT=${DOTFILES_ROOT:-$(git worktree list --porcelain | head -1 | sed 's/^worktree //')}
LOCK="$ROOT/.claude/dotfiles-test.lock"
SNAP="$LOCK/snapshot"
INST="$LOCK/installed"

SELF=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
NOW=$(date +%s)
# The worktree identifies the lock's owner, but the user's question when a
# request is denied is "which of my chats is that?" -- so record the session
# too. The id is in the environment; the title is not, so the caller passes it.
SESSION_ID=${CLAUDE_CODE_HOST_SESSION_ID:-${CLAUDE_SESSION_ID:-}}

# What the live slot serves: the files symlinked from ~ and VS Code's user
# directory, and the bin/ helpers that functions compile from $dothome.
# Repo-relative paths, one per line.
live_files() {
  for f in .bash_profile .bashrc .zprofile .zshrc .inputrc .gitconfig .vimrc .gvimrc .hushlogin \
    settings.json keybindings.json; do
    printf '%s\n' "$f"
  done
  # bin/ from both sides, so a helper the branch adds is snapshotted as absent
  # and removed again on release.
  for d in "$ROOT" "$SELF"; do
    [ -d "$d/bin" ] && (cd "$d" && find bin -type f ! -name .DS_Store)
  done | sort -u
}

die() { printf '%s\n' "$*" >&2; exit 1; }
field() { cat "$LOCK/$1" 2>/dev/null || printf '(unknown)'; }
age_words() {
  held=$(cat "$LOCK/acquired" 2>/dev/null || printf '%s' "$NOW")
  secs=$(( NOW - held ))
  if [ "$secs" -ge 3600 ]; then printf '%sh %sm' "$(( secs / 3600 ))" "$(( secs % 3600 / 60 ))"
  else printf '%sm' "$(( secs / 60 ))"; fi
}
taken_at() {
  t=$(cat "$LOCK/acquired" 2>/dev/null || printf '')
  [ -n "$t" ] || { printf '(unknown)'; return 0; }
  date -r "$t" '+%a %H:%M' 2>/dev/null || date -d "@$t" '+%a %H:%M' 2>/dev/null || printf '(unknown)'
}
holder_report() {
  printf 'held by   %s\n' "$(field label)"
  printf 'session   %s\n' "$(field session)"
  if [ -s "$LOCK/session_id" ]; then
    printf 'session id %s\n' "$(field session_id)"
    # A desktop-app session id renders as a clickable session link.
    case $(field session_id) in
      local_*) printf 'link      [%s](#%s)\n' "$(field session)" "$(field session_id)" ;;
    esac
  fi
  printf 'worktree  %s\n' "$(field worktree)"
  printf 'branch    %s\n' "$(field branch)"
  [ -s "$INST/.list" ] && printf 'installed %s\n' "$(tr '\n' ' ' < "$INST/.list")"
  printf 'age       %s (taken %s)\n' "$(age_words)" "$(taken_at)"
}
owned() { [ "$(field worktree)" = "$SELF" ]; }

# Put $1's bytes at $ROOT/$2 atomically, so a shell starting mid-install never
# sources half a file. Not `cp -p`: a bin/ helper rebuilds only when its source
# is newer than the compiled binary, so a restored source must look new too.
put() {
  dst="$ROOT/$2"
  mkdir -p "$(dirname "$dst")"
  tmp="$dst.tmp.$$"
  cp "$1" "$tmp"
  mv "$tmp" "$dst"
}
# The file a live path should match right now: what was last installed there,
# or the snapshot. A path absent at snapshot has a marker under .absent/.
expected() {
  if [ -f "$INST/$1" ]; then printf '%s' "$INST/$1"
  elif [ -f "$SNAP/$1" ]; then printf '%s' "$SNAP/$1"
  fi
}
matches() {
  exp=$(expected "$1")
  if [ -n "$exp" ]; then cmp -s "$exp" "$ROOT/$1"
  else [ ! -e "$ROOT/$1" ]
  fi
}

# Live files already differing from HEAD go into the snapshot as they are, and
# come back on release -- that is the point of it. Say so at acquire, so the
# caller knows the demo runs on top of someone's uncommitted edits.
dirty_note() {
  dirty=$(git -C "$ROOT" status --porcelain --untracked-files=no 2>/dev/null | sed 's/^...//') || return 0
  [ -n "$dirty" ] || return 0
  printf 'note: the live slot has uncommitted edits, kept in the snapshot and restored on release:\n'
  printf '%s\n' "$dirty" | sed 's/^/  /'
}

cmd=${1:-status}
case "$cmd" in

  acquire)
    mkdir -p "$ROOT/.claude"
    if mkdir "$LOCK" 2>/dev/null; then
      mkdir -p "$SNAP" "$INST"
      : > "$INST/.list"
      live_files | while IFS= read -r f; do
        [ -f "$ROOT/$f" ] || continue
        mkdir -p "$(dirname "$SNAP/$f")"
        cp -p "$ROOT/$f" "$SNAP/$f"
      done
      printf '%s\n' "$SELF" > "$LOCK/worktree"
      printf '%s\n' "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '(detached)')" > "$LOCK/branch"
      printf '%s\n' "${2:-$(basename "$SELF")}" > "$LOCK/label"
      printf '%s\n' "${3:-${DOTFILES_SESSION:-(unnamed session)}}" > "$LOCK/session"
      printf '%s\n' "$SESSION_ID" > "$LOCK/session_id"
      printf '%s\n' "$NOW" > "$LOCK/acquired"
      printf 'acquired -- live files snapshotted\n'
      dirty_note
    elif owned; then
      # Re-acquiring must not re-snapshot: the snapshot would capture the
      # installed change and the real pre-demo state would be lost.
      printf 'already held by this worktree (snapshot preserved)\n'
    else
      printf 'LOCKED -- the session "%s" is demoing.\n' "$(field session)" >&2
      holder_report >&2
      exit 1
    fi
    ;;

  install)
    [ -d "$LOCK" ] || die 'no lock held -- run acquire first'
    owned || { printf 'lock held by another session:\n' >&2; holder_report >&2; exit 1; }
    [ "$SELF" != "$ROOT" ] || die 'this is the live slot itself -- nothing to install; hold the lock and demo'
    shift
    # By default, the live files this branch changes since it left the live
    # slot's HEAD, committed or not. Not every file that differs: a live file
    # with someone else's uncommitted edit differs too, and installing the
    # branch's copy would hide that edit for the whole demo.
    if [ $# -gt 0 ]; then files=$(printf '%s\n' "$@")
    elif base=$(git merge-base HEAD "$(git -C "$ROOT" rev-parse HEAD)" 2>/dev/null); then
      changed=$(git diff --name-only "$base"; git ls-files --others --exclude-standard)
      files=$(live_files | while IFS= read -r f; do
        printf '%s\n' "$changed" | /usr/bin/grep -qxF "$f" && printf '%s\n' "$f"
      done || :)
    else files=$(live_files)
    fi
    # A file the worktree lacks is not installed: removing a live dotfile would
    # break every new shell, and that is never what a demo means.
    n=0
    for f in $files; do
      live_files | /usr/bin/grep -qxF "$f" || die "not a live file: $f"
      [ -f "$SELF/$f" ] || continue
      cmp -s "$SELF/$f" "$ROOT/$f" && continue
      if [ -n "$(git -C "$ROOT" status --porcelain --untracked-files=no -- "$f" 2>/dev/null)" ]; then
        printf 'note: %s had uncommitted edits in the live slot; hidden for the demo, restored on release\n' "$f"
      fi
      mkdir -p "$(dirname "$INST/$f")"
      cp "$SELF/$f" "$INST/$f"
      /usr/bin/grep -qxF "$f" "$INST/.list" || printf '%s\n' "$f" >> "$INST/.list"
      put "$SELF/$f" "$f"
      printf 'installed %s\n' "$f"
      n=$(( n + 1 ))
    done
    [ "$n" -gt 0 ] || printf 'live slot already matches this worktree -- nothing to install\n'
    ;;

  release)
    mode=${2:-}
    # `ship` releases only a lock this session took; both other cases are
    # quiet no-ops.
    if [ "$mode" = "--if-mine" ]; then
      [ -n "$SESSION_ID" ] && [ -d "$LOCK" ] && [ "$(field session_id)" = "$SESSION_ID" ] || exit 0
      mode=
    fi
    [ -d "$LOCK" ] || { printf 'no lock held\n'; exit 0; }
    owned || { printf 'lock held by another session; refusing to release:\n' >&2; holder_report >&2; exit 1; }
    [ -d "$SNAP" ] || die 'snapshot missing -- refusing to release; restore the live files by hand'

    if [ "$mode" = "--keep" ]; then
      rm -rf "$LOCK"
      printf 'lock dropped; live files left as they are\n'
      exit 0
    fi

    # A live file that matches neither what was installed nor the snapshot
    # changed underneath the lock -- a hand edit, or VS Code saving its
    # settings -- and blindly restoring would destroy that change.
    drift=$(live_files | while IFS= read -r f; do matches "$f" || printf '%s\n' "$f"; done)
    if [ "$mode" != "--force" ] && [ -n "$drift" ]; then
      printf 'These live files changed since this lock was taken:\n' >&2
      printf '%s\n' "$drift" | sed 's/^/  /' >&2
      printf 'Restoring the snapshot would discard that change.\n\n' >&2
      printf '  keep the current live files:  %s release --keep\n' "$0" >&2
      printf '  restore anyway:               %s release --force\n' "$0" >&2
      printf '\nSnapshot of the pre-demo files: %s\n' "$SNAP" >&2
      exit 1
    fi

    live_files | while IFS= read -r f; do
      if [ -f "$SNAP/$f" ]; then
        cmp -s "$SNAP/$f" "$ROOT/$f" || { put "$SNAP/$f" "$f"; printf 'restored %s\n' "$f"; }
      elif [ -e "$ROOT/$f" ]; then
        rm -f "$ROOT/$f"; printf 'removed %s\n' "$f"
      fi
    done
    rm -rf "$LOCK"
    printf 'released\n'
    ;;

  status)
    [ -d "$LOCK" ] || { printf 'unlocked\n'; exit 0; }
    owned && printf 'LOCKED by this worktree\n' || printf 'LOCKED by another session\n'
    holder_report
    printf 'age is not abandonment -- the holder may be waiting on the user\n'
    exit 0
    ;;

  check)
    [ -d "$LOCK" ] || exit 0
    owned && exit 0
    holder_report >&2
    exit 1
    ;;

  break)
    [ -d "$LOCK" ] || { printf 'no lock held\n'; exit 0; }
    if [ "${2:-}" != --confirmed ]; then
      printf 'REFUSED -- "%s" holds the live dotfiles, and no age says otherwise:\n' "$(field session)" >&2
      holder_report >&2
      printf '\nAsk the user whether that demo is still theirs to finish. If they say\n' >&2
      printf 'to take it:\n' >&2
      printf '  %s break --confirmed\n' "$0" >&2
      exit 1
    fi
    if [ -d "$SNAP" ]; then
      live_files | while IFS= read -r f; do
        if [ -f "$SNAP/$f" ]; then
          cmp -s "$SNAP/$f" "$ROOT/$f" || put "$SNAP/$f" "$f"
        elif [ -f "$INST/$f" ]; then
          rm -f "$ROOT/$f"
        fi
      done
      printf 'restored the snapshot the lock recorded\n'
    fi
    rm -rf "$LOCK"
    printf 'lock broken\n'
    ;;

  *) die "unknown command: $cmd (acquire|install|release|status|check|break)" ;;
esac
