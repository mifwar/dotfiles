# bin/

Helper binaries / scripts that don't fit anywhere else in the dotfiles.

## `passc` — copy `pass` entries without clipboard-history leak

The standard `pass -c <entry>` writes the password to the system pasteboard
via `pbcopy`. Any clipboard manager hooked into `NSPasteboard` change
notifications (Raycast, Maccy, Flycut, …) will record it.

`passc` decrypts with `pass show`, then copies only the first password line
without a trailing newline through `tc` (a tiny Swift binary in this
directory). `tc` marks the pasteboard with `org.nspasteboard.TransientType`,
which well-behaved clipboard managers honor by skipping the entry.

`passc` calls `tc` twice — once with the password, then again with empty
stdin after the clipboard TTL. Failed decryption leaves the clipboard
untouched.

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
