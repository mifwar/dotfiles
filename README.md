# Dotfiles

My personal configuration files for macOS development environment with AI-enhanced workflow.

## 📦 What's Included

- **[Neovim](https://neovim.io/)** - LazyVim-based setup with AI integration (Claude 3.5 Sonnet)  
- **[Tmux](https://github.com/tmux/tmux)** - Terminal multiplexer with Catppuccin theme and advanced pane management
- **[Yabai](https://github.com/koekeishiya/yabai)** - BSP tiling window manager with 12px padding
- **[SKHD](https://github.com/koekeishiya/skhd)** - Hotkey daemon with vim-style bindings
- **[Starship](https://starship.rs/)** - Custom prompt with language info and memory usage

## 🚀 Quick Installation

```bash
# Clone the repository
git clone https://github.com/mifwar/dotfiles.git ~/code/dotfiles

# Run the installation script
cd ~/code/dotfiles
./install.sh
```

## 📁 Structure

```
~/code/dotfiles/
├── README.md           # This file
├── install.sh          # Installation script
├── nvim/              # → ~/.config/nvim/ (LazyVim + AI tools)
├── tmux/              # Contains .tmux.conf → ~/.tmux.conf
├── yabai/             # → ~/.config/yabai/ (BSP layout, 12px gaps)
├── skhd/              # → ~/.config/skhd/ (Custom hotkeys)
└── starship.toml      # → ~/.config/starship.toml (Custom prompt)
```

## ⌨️ Key Bindings

### Neovim (Leader: `Space`)

#### Basic Navigation & Editing
- `jk` (Insert mode) - Exit insert mode
- `<leader>nh` - Clear search highlights
- `<leader>z` - Toggle word wrap
- `<leader>n` - Toggle relative line numbers

#### Window Management
- `<leader>s|` / `<leader>s-` - Split vertically/horizontally
- `<leader>nr` / `<leader>nb` - New pane right/bottom
- `<leader>se` / `<leader>we` - Equalize splits
- `<leader>wj/k/h/l` - Resize splits
- `<leader>sr` - Rotate splits
- `<leader>sx` / `<leader>wx` - Close split
- `<leader>wm` - Toggle maximize window

#### File Operations
- `<leader>e` - Toggle file explorer (nvim-tree)
- `<leader>c` - Collapse file explorer
- `<leader>r` - Refresh file explorer
- `<leader>sa` - Save unnamed buffer with custom name
- `<leader>yp` - Yank relative file path
- `<leader>ft` - Set filetype

#### Telescope (Fuzzy Finding)
- `<leader>ff` - Find files
- `<leader>fr` - Recent files  
- `<leader>fs` - Live grep
- `<leader>fc` - Find string under cursor

#### Tab Management
- `<leader>to` - New tab
- `<leader>tx` - Close tab
- `<leader>tn` / `<leader>tp` - Next/previous tab
- `<leader>tf` - Open buffer in new tab

#### Development
- `<leader>t` - Toggle Tailwind fold
- `<leader>jq` - Run jq filter on buffer

#### Tmux Navigation (vim-tmux-navigator)
- `Ctrl-h/j/k/l` - Navigate between vim/tmux panes
- `Ctrl-\` - Previous pane

### Tmux (Prefix: `Ctrl-a`)

#### Pane Management
- `Ctrl-a |` - Split horizontally
- `Ctrl-a -` - Split vertically
- `Ctrl-a m` - Maximize/restore pane
- `Ctrl-a r` - Reload config
- `Ctrl-a n` - Rename pane

#### Pane Resizing
- `Ctrl-a h/j/k/l` - Resize (small steps)

#### Pane Balancing (Custom)
- `Ctrl-a b` - Balance all panes (tiled)
- `Ctrl-a H` - Balance horizontally (even-horizontal)
- `Ctrl-a V` - Balance vertically (even-vertical)
- `Ctrl-a =` - Balance left vs right (50/50)
- `Ctrl-a +` - Balance height of right-side panes

#### Window Management
- `Ctrl-a <` / `Ctrl-a >` - Move window left/right
- `Ctrl-a p` - Last window

### Yabai & SKHD

#### Window Focus
- `Shift-Ctrl h/j/k/l` - Focus window in direction
- `Alt u/n` - Focus display north/south

#### Window Resizing
- `Shift-Alt-Cmd h/j/k/l` - Resize window (20px)
- `Cmd-Alt h/j/k/l` - Resize window (100px)

#### Window Management
- `Shift-Alt m` - Toggle fullscreen
- `Shift-Alt e` / `Shift-Alt 0` - Balance all windows
- `Shift-Alt t` - Toggle float (large)
- `Shift-Ctrl t` - Toggle float (small)
- `Shift-Alt p` - Toggle PiP window (bottom-right)

#### Window Movement  
- `Shift-Alt h/j/k/l` - Move floating window (20px)
- `Ctrl-Alt-Cmd h/j/k/l` - Swap windows
- `Ctrl-Alt-Cmd u/n` - Move to display north/south

#### Layout Management
- `Shift-Alt 1` - BSP layout
- `Shift-Alt 2` - Stack layout
- `Shift-Alt 3` - Float layout
- `Shift-Alt r` - Rotate layout 270°
- `Shift-Alt x/y` - Mirror x/y axis

#### System Control
- `Ctrl-Alt s/r/e` - Stop/start/restart yabai

#### Mouse Control (cliclick)
- `Alt 7/8/9/0` - Move cursor (20px steps)
- `Shift-Alt 7/8/9/0` - Move cursor (100px steps)
- `Alt y` - Click
- `Alt d` - Double click
- `Alt p` - Right click

## 🔧 Configuration Highlights

### Neovim Features
- **LazyVim base** with extensive customizations
- **AI Integration**: Claude 3.5 Sonnet (Avante), Supermaven completion
- **Custom Dashboard**: Sableye Pokemon ASCII art
- **File Explorer**: nvim-tree with custom icons and colors
- **Themes**: Tokyo Night with transparency
- **Languages**: Go, Lua, JavaScript, HTML support
- **Session Management**: Auto-restore projects
- **Tailwind Tools**: Class folding for cleaner code
- **Time Tracking**: Wakatime integration

### Tmux Configuration
- **Theme**: Catppuccin Mocha
- **Plugin Manager**: TPM with auto-install
- **Key Plugins**: vim-tmux-navigator, resurrect, continuum, yank
- **Custom Features**: Advanced pane balancing shortcuts
- **Status Line**: CPU usage, uptime, session info

### Yabai Setup
- **Layout**: BSP (Binary Space Partitioning)
- **Padding**: 12px all around with 12px window gaps
- **Mouse**: Alt + drag/resize, center on focus
- **Excluded Apps**: System Settings, Preview, Finder, Calculator, VLC, etc.

### Starship Prompt
- **Layout**: Two-line with info on right
- **Features**: Git status, language versions, memory usage, time (UTC+7)
- **Style**: Custom symbols and colors
- **Languages**: Node.js, Rust, Go, Python, C/C++, and more

## 🛠 Manual Setup Required

### 1. Yabai & SKHD Permissions
```bash
# Add to Accessibility
System Preferences → Security & Privacy → Privacy → Accessibility
# Add: yabai, skhd, Terminal

# Add to Screen Recording (for yabai)
System Preferences → Security & Privacy → Privacy → Screen Recording  
# Add: yabai
```

### 2. Install Nerd Fonts
```bash
brew tap homebrew/cask-fonts
brew install font-fira-code-nerd-font
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
# Configurations update automatically via symlinks
```

## 📋 Dependencies

The install script will automatically install:
- Homebrew (if not present)
- Neovim, Tmux, Yabai, SKHD, Starship
- TPM (Tmux Plugin Manager)

## 🎯 Features

- **AI-Enhanced Coding**: Claude integration for assistance
- **Seamless Navigation**: Vim ↔ Tmux ↔ Yabai integration
- **Session Persistence**: Auto-save/restore work sessions
- **Advanced Layouts**: Custom window and pane management
- **Modern UI**: Transparency, themes, and visual enhancements
- **Productivity**: Time tracking, TODO highlighting, Git integration

---

**Note**: Optimized for macOS development with focus on productivity and modern tooling.