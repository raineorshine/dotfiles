# macOS text replacements: how they work and how to change them

Findings behind `textreplace` (.zshrc) and `bin/ksreplace.swift`, recorded so the
dead ends are not repeated. Verified on macOS 15/16 (Darwin 25).

## The moving parts

- **Store of truth:** `~/Library/KeyboardServices/TextReplacements.db`, a CoreData
  sqlite store (table `ZTEXTREPLACEMENTENTRY`: `ZSHORTCUT`, `ZPHRASE`, `ZWASDELETED`,
  `ZNEEDSSAVETOCLOUD`, `ZUNIQUENAME`) synced to iCloud via CloudKit. Owned by
  `keyboardservicesd`, an on-demand launchd agent (`/usr/libexec/keyboardservicesd`,
  framework `KeyboardServices.framework`, mach service
  `com.apple.KeyboardServices.TextReplacementService`).
- **Mirror:** `NSUserDictionaryReplacementItems` in `NSGlobalDomain`, an array of
  `{on, replace, with}`. The daemon writes it; nothing reads it back into the store.
- **Apps** read the mirror when they launch (`NSSpellChecker.userReplacementsDictionary`
  reads it live, but the text system caches its own copy). Already-running apps
  reload only on a change signal the daemon sends after a real change.
- **System Settings** is just another client of the daemon over XPC. It does not
  write the mirror or the db itself.

## What works

Go through the daemon with the private client class, which is what the settings
pane does. `bin/ksreplace.swift` does exactly this:

- `Bundle(path: "/System/Library/PrivateFrameworks/KeyboardServices.framework").load()`
- `_KSTextReplacementClientStore.init()`, entries are `_KSTextReplacementEntry`
  with `shortcut`, `phrase`, `timestamp` set through KVC.
- `-addEntries:removeEntries:withCompletionHandler:`; the completion receives an
  `NSError` whose code is 0 on success. Removal matches on shortcut + phrase, so
  `rm` looks the phrase up in the db first. Removed rows are hard-deleted.
- Effects are immediate: db row, mirror rewrite, iCloud push, and running apps
  pick it up without relaunch.
- `-queryTextReplacementsWithCallback:` crashed when handed a two-argument block
  and the `textReplacementEntries` property returned an empty array, so listing
  reads the sqlite store directly instead.

## Dead ends (all tried, none reach running apps)

- `defaults write -g NSUserDictionaryReplacementItems`: apps launched afterwards
  see it, running apps do not, and the daemon's next rewrite drops it because it
  is not in the db.
- Inserting into the sqlite store: persists and syncs once the daemon reloads, but
  the daemon only reads the db when it launches *and* a client asks, so nothing
  happens until then, and running apps still need the change signal.
- `killall keyboardservicesd`: it is on-demand, so it stays dead until a client
  connects, and a dead daemon publishes nothing. `launchctl kickstart -k` is
  refused under SIP; plain `kickstart` starts a daemon that never loads the db.
- Opening the Keyboard settings pane (`open x-apple.systempreferences:com.apple.Keyboard-Settings.extension`)
  does make the daemon load, sync, and republish, but with 5 s to several minutes
  of latency and sometimes not at all. `open -j` (hidden) does not load the pane.
- Posting notifications by hand: not distributed (an observer for all names saw
  nothing during a real republish), not cross-process KVO on the key (fires for
  `defaults write`, which apps ignore), and none of ~1200 Darwin names pulled from
  the AppKit, KeyboardServices, and TextInput framework strings fired
  (`NSSpellServerReplacementsChanged`, `KSTextReplacementDidChangeNotification`,
  `com.apple.keyboard.textReplacement`, ... included). Writing the key in the
  ByHost domain or rewriting the plist file in place did nothing either.
- Tombstoning rows (`ZWASDELETED=1`) as a delete: the daemon does hard deletes;
  tombstones only linger until its next sync.
- `log show` for `keyboardservicesd` and `cfprefsd` returns nothing useful; its
  logging is private.

## Techniques that transferred

- Find the real store with `lsof -p $(pgrep <daemon>)`, not by guessing paths.
- System frameworks are not on disk; their strings are in the dyld shared cache
  (`/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e*`).
  Locate a known string with Python `mmap.find` (seconds; `grep -aob` takes
  minutes), then `/bin/dd` a window around the offset into `strings`. Selector
  names, log format strings, and notification names all sit near each other.
- Enumerate a private framework's classes with `objc_copyClassNamesForImage`
  after loading the bundle; `objc_copyClassList` over every class crashes.
  Dump selectors with `class_copyMethodList` on the class and its metaclass.
- Call a block-taking private selector from Swift by `unsafeBitCast`ing
  `method(for:)` to a `@convention(c)` function type whose last parameter is a
  `@convention(block)` closure.
- Verify text input behaviour with a throwaway AppKit app (one `NSTextView` with
  `isAutomaticTextReplacementEnabled`, writes its text to a file on a timer,
  clears on SIGUSR1) driven by System Events `keystroke`. Before every keystroke
  check that the harness is the frontmost process; when the screen is locked
  (`ioreg -n Root -d1 -a | grep -A1 IOConsoleLocked`) the app gets no window and
  keystrokes land wherever focus was. Use shortcuts autocorrect will not touch
  (letters plus a digit); `zzt` became `zzz`.
- `notifyutil -w` accepts hundreds of `-w NAME` flags in one process, which makes
  sweeping candidate Darwin notification names during an event cheap.
