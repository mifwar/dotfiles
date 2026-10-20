# bin/

Helper binaries / scripts that don't fit anywhere else in the dotfiles.

## `codex-tmux-limits` — Codex reset countdowns in tmux

Shows `5h ↻4h12m · weekly ↻6d12h` before the existing right-hand status
modules, only while the active pane's command is `codex`. Requires Python 3.
Reads the latest available account limit snapshot from local Codex session
logs and caches it for 60 seconds; no API calls or credentials are needed.
Countdowns use the last recorded reset times, so an expired snapshot shows
`now` until Codex records fresh limits. Uses `CODEX_HOME` or `~/.codex`.

## `codex-sound` — toggle Codex lifecycle sounds

Codex hooks play Glass when a turn completes and Ping when Codex requests
approval. The toggle is immediate and does not invoke a model.

```bash
codex-sound             # toggle
codex-sound on          # enable
codex-sound off         # disable
codex-sound status      # show current state
```

The state is stored in `~/.codex/sound.txt`; missing or `1` means enabled and
`0` means disabled. Hook configuration lives in `../codex/hooks.json`.

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

## `pi` — run pi on a new enough Node

The shell defaults to `node@20`, but pi needs Node >= 22.19. This wrapper
shadows `/opt/homebrew/bin/pi` and runs it with Homebrew's current `node`
first on `PATH`.

## `tm` — tmux sessions grouped by project

One tmux session per repo, one window per checkout/worktree, one pane per
task. Run `tm` from anywhere inside a project:

```bash
tm                  # attach/switch to this repo's session, creating it if needed
tm --print          # show "session:window" without touching tmux
tm --self-test      # assert the name-resolution rules
```

Worktrees of a repo land as windows in that repo's session (the session name
comes from the main repo, not the worktree dir), so `znet-fe` and its
worktrees stay together while `znet-tryout-fe` gets its own session. If a
worktree's git metadata is missing (synced but not yet relinked), the `.git`
file's `gitdir` line is used to find the main repo.
