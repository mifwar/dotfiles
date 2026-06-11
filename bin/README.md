# bin/

Helper binaries / scripts that don't fit anywhere else in the dotfiles.

## `passc` — copy `pass` entries without clipboard-history leak

The standard `pass -c <entry>` writes the password to the system pasteboard
via `pbcopy`. Any clipboard manager hooked into `NSPasteboard` change
notifications (Raycast, Maccy, Flycut, …) will record it.

`passc` is a thin wrapper around `pass -c` that swaps the clipboard backend
for `tc` (a tiny Swift binary in this directory). `tc` writes to the
pasteboard with `NSPasteboardItem.setAccessBehavior(.transient)`, which
well-behaved clipboard managers honor by skipping the entry.

`pass` still calls `tc` twice — once with the password, then again with
empty stdin after the clipboard TTL — so auto-clear continues to work.

### Build

```bash
cd bin
swiftc tc.swift -o tc
chmod +x passc
```

`install.sh` does this automatically on a fresh install.

### Manual usage

```bash
passc email/gmail           # copies, auto-clears in 45s, NOT stored in Raycast
```

The matching Raycast script command lives in
[`../raycast/scripts/passc.sh`](../raycast/scripts/passc.sh).
