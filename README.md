# Dotfiles

My personal configuration files for a macOS development environment with an AI-enhanced workflow.

## 📦 What's Included

- **[Neovim](https://neovim.io/)** — LazyVim-based setup with AI integration (Avante + Supermaven)
- **[Tmux](https://github.com/tmux/tmux)** — Terminal multiplexer with Catppuccin Mocha theme and advanced pane management
- **[Yabai](https://github.com/koekeishiya/yabai)** — BSP tiling window manager with 12px padding
- **[SKHD](https://github.com/koekeishiya/skhd)** — Hotkey daemon with vim-style bindings
- **[Starship](https://starship.rs/)** — Custom prompt with language info and memory usage
- **[Ghostty](https://ghostty.org/)** — Terminal emulator (Catppuccin Macchiato/Latte)
- **[`passc` / `tc`](bin/)** — Copy `pass` entries without leaking them into clipboard history
- **[Raycast](https://www.raycast.com/)** scripts — `passc` and clipboard-image helpers
- **`pi`** — Safe config for the `pi` coding agent (auth stays local)
- **`yabai-snapshot`** — TUI to save/restore yabai window layouts

## 🚀 Quick Installation

```bash
# Clone the repository
git clone https://github.com/mifwar/dotfiles.git ~/code/dotfiles

# Run the installation script
cd ~/code/dotfiles
./install.sh
```

`install.sh` installs Homebrew dependencies (preferring a declarative `Brewfile`),
symlinks every config into place, compiles the `tc` Swift helper, and starts the
yabai/skhd services via `brew services`.

## 📁 Structure

```
~/code/dotfiles/
├── README.md            # This file
├── install.sh           # Installation script (interactive TTY required)
├── Brewfile             # Declarative Homebrew dependencies
├── .gitignore
├── nvim/                # → ~/.config/nvim/          (LazyVim + AI tools)
├── tmux/.tmux.conf      # → ~/.tmux.conf             (Catppuccin, vim nav)
├── yabai/yabairc        # → ~/.config/yabai/         (BSP layout, 12px gaps)
├── skhd/skhdrc          # → ~/.config/skhd/          (Custom hotkeys)
├── ghostty/config       # → Ghostty app support       (Catppuccin)
├── starship.toml        # → ~/.config/starship.toml  (Custom prompt)
├── bin/                 # passc + tc (transient pasteboard helper)
├── raycast/scripts/     # Raycast script commands
├── pi/                  # → ~/.pi/agent/             (safe agent config)
└── yabai-snapshot/      # Standalone TUI package (@mifwar/yabai-snapshot)
```

## ⌨️ Key Bindings

### Neovim (Leader: `Space`)

#### Basic Navigation & Editing
- `jk` (Insert mode) — Exit insert mode
- `<leader>nh` — Clear search highlights
- `<leader>z` — Toggle word wrap
- `<leader>n` — Toggle relative line numbers

#### Window Management
- `<leader>s|` / `<leader>s-` — Split vertically/horizontally
- `<leader>nr` / `<leader>nb` — New pane right/bottom
- `<leader>se` / `<leader>we` — Equalize splits
- `<leader>wj/k/h/l` — Resize splits
- `<leader>sr` — Rotate splits
- `<leader>sx` / `<leader>wx` — Close split
- `<leader>wm` — Toggle maximize window

#### File Operations
- `<leader>e` — Toggle file explorer (Snacks explorer)
- `<leader>ft` — Set filetype
- `<leader>sa` — Save unnamed buffer with custom name
- `<leader>yp` — Yank relative file path
- `<leader>fp` — Show full file path (and copy to clipboard)
- `<leader>ya` — Yank entire file to clipboard

#### Snacks Pickers (Fuzzy Finding)
- `<leader>ff` — Find files
- `<leader>fr` — Recent files
- `<leader>fs` — Live grep
- `<leader>fc` — Find word under cursor

#### Tab Management
- `<leader>to` — New tab
- `<leader>tx` — Close tab
- `<leader>tn` / `<leader>tp` — Next/previous tab
- `<leader>tf` — Open buffer in new tab
- `<leader>t1`…`<leader>t9` — Go to tab N

#### Terminal Panels
- `<leader>pt` — Toggle terminal panel
- `<leader>pg` — Open lazygit panel

#### Git / Diff
- `<leader>gg` — Lazygit (Snacks)
- `<leader>gd` — Git diff view (Diffview)
- `<leader>df` — Diff current buffer vs saved file
- `<leader>db` — Diff current buffer vs another buffer
- `<leader>do` — Diff off

#### Development
- `<leader>jq` — Run jq filter on buffer/selection

#### Tmux Navigation (vim-tmux-navigator)
- `Ctrl-h/j/k/l` — Navigate between vim/tmux panes
- `Ctrl-\` — Previous pane

### Tmux (Prefix: `Ctrl-a`)

#### Pane Management
- `Ctrl-a |` — Split horizontally
- `Ctrl-a -` — Split vertically
- `Ctrl-a m` — Maximize/restore pane
- `Ctrl-a r` — Reload config
- `Ctrl-a n` — Rename pane

#### Pane Resizing
- `Ctrl-a h/j/k/l` — Resize (small steps, repeatable)

#### Pane Balancing (Custom)
- `Ctrl-a b` — Balance all panes (tiled)
- `Ctrl-a H` — Balance horizontally (even-horizontal)
- `Ctrl-a V` — Balance vertically (even-vertical)
- `Ctrl-a =` — Balance left vs right (50/50)
- `Ctrl-a +` — Balance height of right-side panes

#### Pane Swapping
- `Ctrl-a Tab` / `Ctrl-a Shift-Tab` — Swap with right/left pane
- `Ctrl-a J` / `Ctrl-a K` — Swap with pane below/above

#### Window Management
- `Ctrl-a <` / `Ctrl-a >` — Move window left/right
- `Ctrl-a p` — Last window
- `Ctrl-a M` — Minimize pane (break into hidden window)
- `Ctrl-a R` — Restore minimized pane

### Yabai / SKHD

#### Window Focus
- `Shift-Ctrl h/j/k/l` — Focus west/south/north/east
- `Alt u` / `Alt n` — Focus display north/south

#### Window Movement
- `Shift-Alt h/j/k/l` — Move floating window (20px)
- `Ctrl-Alt-Cmd h/j/k/l` — Swap windows
- `Ctrl-Alt-Cmd u/n` — Move to display north/south

#### Layout Management
- `Shift-Alt 1/2/3` — BSP / Stack / Float layout
- `Shift-Alt r` — Rotate layout 270°
- `Shift-Alt x/y` — Mirror x/y axis
- `Shift-Alt m` — Toggle zoom-fullscreen
- `Shift-Alt f` — Toggle native fullscreen
- `Shift-Alt e` — Balance tree
- `Shift-Alt 0` — Balance all windows
- `Shift-Alt t` — Toggle float (large)
- `Shift-Ctrl t` — Toggle float (small)
- `Shift-Alt p` — Toggle PiP window (bottom-right)

#### System Control
- `Ctrl-Alt s/r/e` — Stop/start/restart yabai

#### Mouse Control (cliclick)
- `Alt 7/8/9/0` — Move cursor (20px steps)
- `Shift-Alt 7/8/9/0` — Move cursor (100px steps)
- `Alt y` — Click
- `Alt d` — Double click
- `Alt p` — Right click

## 🔧 Configuration Highlights

### Neovim Features
- **LazyVim base** with extensive customizations
- **AI Integration**: Avante (opencode provider) + Supermaven completion
- **Custom Dashboard**: Sableye Pokémon ASCII art
- **File Explorer**: Snacks explorer
- **Themes**: Catppuccin Macchiato with transparency
- **Session Management**: Auto-restore projects
- **Tailwind Tools**: Class folding for cleaner code
- **Time Tracking**: Wakatime integration
- **Diff Tools**: Custom `DiffSaved`/`DiffBuffers` + Diffview

### Tmux Configuration
- **Theme**: Catppuccin Mocha (status indicators)
- **Terminal**: `tmux-256color` with truecolor support
- **Plugin Manager**: TPM with auto-install
- **Key Plugins**: vim-tmux-navigator, resurrect, continuum, yank, tmux-cpu
- **Custom Features**: Advanced pane balancing & swap shortcuts
- **Status Line**: CPU usage, uptime, session info

### Yabai Setup
- **Layout**: BSP (Binary Space Partitioning)
- **Padding**: 12px all around with 12px window gaps
- **Mouse**: Alt + drag/resize, center on focus
- **Excluded Apps**: System Settings, Preview, Finder, Calculator, QuickTime, VLC, Duolingo, Installer, Avatarmu

### Starship Prompt
- **Layout**: Two-line with info on right
- **Features**: Git status, language versions, memory usage, time (UTC+7)
- **Style**: Custom symbols and Catppuccin Macchiato palette
- **Languages**: Node.js, Rust, Go, Python, C/C++, and more

### `passc` / `tc` (bin/)
Copy `pass` entries to the clipboard without leaving a trace in clipboard
managers (Raycast, Maccy, Flycut). `tc` marks the pasteboard entry as
transient (`org.nspasteboard.TransientType`). See [`bin/README.md`](bin/README.md).

## 🛠 Manual Setup Required

### 1. Yabai & SKHD Permissions
```bash
# Add to Accessibility
System Settings → Privacy & Security → Accessibility
# Add: yabai, skhd, Terminal (and your terminal app)

# Add to Screen Recording (for yabai)
System Settings → Privacy & Security → Screen Recording
# Add: yabai
```

### 2. Install Nerd Fonts
```bash
# Fonts now live in the main homebrew/cask tap (no separate tap needed)
brew install --cask font-fira-code-nerd-font
```

### 3. Tmux Plugins
```bash
# Start tmux and install plugins
tmux
# Press: Ctrl-a I
```

## 🔄 Updates

```bash
cd ~/code/dotfiles
git pull origin main
# Configurations update automatically via symlinks.
# Re-run ./install.sh to sync Homebrew dependencies from the Brewfile.
```

## 📋 Dependencies

`install.sh` will automatically install (via the `Brewfile`):
- Homebrew (if not present)
- Neovim, Tmux, Yabai, SKHD, Starship, cliclick, jq
- `pass`, gnupg, pinentry-mac (for `passc`)
- TPM (Tmux Plugin Manager)
- font-fira-code-nerd-font

## 🎯 Features

- **AI-Enhanced Coding**: Avante + Supermaven integration
- **Seamless Navigation**: Vim ↔ Tmux ↔ Yabai integration
- **Session Persistence**: Auto-save/restore work sessions
- **Advanced Layouts**: Custom window and pane management
- **Modern UI**: Transparency, Catppuccin themes, visual enhancements
- **Productivity**: Time tracking, TODO highlighting, Git integration
- **Safe Passwords**: Clipboard-history-proof `pass` copy

---

**Note**: Optimized for macOS development with focus on productivity and modern tooling.
