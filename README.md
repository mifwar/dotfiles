# Dotfiles

My macOS setup, built around tmux and a handful of coding agents running side by side.

The parts you won't find in most dotfiles:

- **Agent-aware tmux bar.** Claude and Codex hooks ring the pane's bell when an agent
  finishes or needs input, so its tab lights up. `prefix + a` jumps to the next one;
  `prefix + A` picks across sessions. A Codex usage countdown shows while Codex is focused.
- **`passc` / `tc`.** Copies a `pass` entry marked as transient, so clipboard managers
  skip it, then clears the pasteboard on a timer.
- **`yabai-snapshot`.** A TUI that saves and restores yabai window layouts.
- **pi extensions.** Usage status, model stars, and a longer default bash timeout for the pi agent.

The rest is yabai + skhd, Ghostty, Starship, and a LazyVim-based Neovim.
The Claude hook lives in `~/.claude/settings.json`, outside this repo.

<!-- screenshot: docs/screenshot.png -->

## What's here

- `bin/` — Password, tmux, yabai, and Codex helper commands.
- `tmux/` — Pane tracking, bell shortcuts, and the Catppuccin status bar.
- `codex/` — Codex completion and permission hooks.
- `yabai/` — BSP layout defaults and window rules.
- `skhd/` — Window focus, movement, layout, and desktop shortcuts.
- `nvim/` — LazyVim base, Lua keymaps, and plugin configuration.
- `pi/` — Pi settings, keybindings, and custom extensions.
- `ghostty/` — Terminal theme and key reporting for tmux.
- `starship.toml` — Prompt layout and Catppuccin palette.
- `yabai-snapshot/` — TUI to save and restore yabai window layouts.
- `raycast/scripts/` — Raycast script commands.

## Install

~~~sh
git clone https://github.com/mifwar/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh
~~~

The installer is interactive and macOS-only. It installs Brewfile dependencies, links
the configs, builds `tc` when needed and Swift is available, and starts yabai/skhd services.

- Give `/opt/homebrew/bin/yabai` and `/opt/homebrew/bin/skhd` Accessibility access in
  System Settings → Privacy & Security, then restart both services.
- Start tmux and press `prefix + I` (`Ctrl-a I`) to install plugins.

## Keys

See [docs/keys.md](docs/keys.md) for the Neovim, tmux, and yabai/skhd keybindings.
