# Keys

## Neovim (Leader: `Space`)

### Basic Navigation & Editing
- `jk` (Insert mode) — Exit insert mode
- `<leader>nh` — Clear search highlights
- `<leader>z` — Toggle word wrap
- `<leader>n` — Toggle relative line numbers

### Window Management
- `<leader>s|` / `<leader>s-` — Split vertically/horizontally
- `<leader>nr` / `<leader>nb` — New pane right/bottom
- `<leader>se` / `<leader>we` — Equalize splits
- `<leader>wj/k/h/l` — Resize splits
- `<leader>sr` — Rotate splits
- `<leader>sx` / `<leader>wx` — Close split
- `<leader>wm` — Toggle maximize window

### File Operations
- `<leader>e` — Toggle file explorer (Snacks explorer)
- `<leader>ft` — Set filetype
- `<leader>sa` — Save unnamed buffer with custom name
- `<leader>yp` — Yank relative file path
- `<leader>fp` — Show full file path (and copy to clipboard)
- `<leader>ya` — Yank entire file to clipboard

### Snacks Pickers (Fuzzy Finding)
- `<leader>ff` — Find files
- `<leader>fr` — Recent files
- `<leader>fs` — Live grep
- `<leader>fc` — Find word under cursor

### Tab Management
- `<leader>to` — New tab
- `<leader>tx` — Close tab
- `<leader>tn` / `<leader>tp` — Next/previous tab
- `<leader>tf` — Open buffer in new tab
- `<leader>t1`…`<leader>t9` — Go to tab N

### Terminal Panels
- `<leader>pt` — Toggle terminal panel
- `<leader>pg` — Open lazygit panel

### Git / Diff
- `<leader>gg` — Lazygit (Snacks)
- `<leader>gd` — Git diff view (Diffview)
- `<leader>df` — Diff current buffer vs saved file
- `<leader>db` — Diff current buffer vs another buffer
- `<leader>do` — Diff off

### Development
- `<leader>jq` — Run jq filter on buffer/selection

### Tmux Navigation (vim-tmux-navigator)
- `Ctrl-h/j/k/l` — Navigate between vim/tmux panes
- `Ctrl-\` — Previous pane

## Tmux (Prefix: `Ctrl-a`)

### Pane Management
- `Ctrl-a |` — Split left/right
- `Ctrl-a -` — Split top/bottom
- `Ctrl-a m` — Maximize/restore pane
- `Ctrl-a N` / `Ctrl-a P` — Next/previous pane by number, always maximized
- `Ctrl-a ;` — Jump to the previously active pane, always maximized
- `Ctrl-a X` — Close unused tracked zsh panes in this window after confirmation; keeps the active and untracked panes.
- `Ctrl-a r` — Reload config
- `Ctrl-a n` — Rename pane
- `Ctrl-a y` — Copy the picked pane's address (`session:window.pane`), for handing to another agent

### Pane Resizing
- `Ctrl-a h/j/k/l` — Resize (small steps, repeatable)

### Pane Balancing (Custom)
- `Ctrl-a b` — Balance all panes (tiled)
- `Ctrl-a H` — Balance horizontally (even-horizontal)
- `Ctrl-a V` — Balance vertically (even-vertical)
- `Ctrl-a =` — Balance left vs right (50/50)
- `Ctrl-a +` — Balance height of right-side panes

### Pane Swapping
- `Ctrl-a Tab` / `Ctrl-a Shift-Tab` — Swap with right/left pane
- `Ctrl-a J` / `Ctrl-a K` — Swap with pane below/above

### Window Management
- `Ctrl-a <` / `Ctrl-a >` — Move window left/right
- `Ctrl-a p` — Last window
- `Ctrl-a a` — Next waiting window with a bell, in this session
- `Ctrl-a A` — Pick a belled window across sessions
- `Ctrl-a M` — Minimize pane (break into hidden window)
- `Ctrl-a R` — Restore minimized pane

## Yabai / SKHD

### Window Focus
- `Shift-Ctrl h/j/k/l` — Focus west/south/north/east
- `Alt u` / `Alt n` — Focus display north/south

### Window Movement
- `Shift-Alt h/j/k/l` — Move floating window (20px)
- `Ctrl-Alt-Cmd h/j/k/l` — Swap windows
- `Ctrl-Alt-Cmd u/n` — Move to display north/south
- `Alt 1/2/3` — Jump to desktop
- `Ctrl-Alt 1/2/3` — Move window to desktop and follow it

### Layout Management
- `Shift-Alt 1/2/3` — BSP / Stack / Float layout
- `Shift-Alt r` — Rotate layout 270°
- `Shift-Alt x/y` — Mirror x/y axis
- `Shift-Alt m` — Toggle zoom-fullscreen
- `Shift-Alt f` — Toggle native fullscreen
- `Shift-Alt e` — Balance tree
- `Shift-Alt t` — Toggle float (large)
- `Shift-Ctrl t` — Toggle float (small)
- `Shift-Alt p` — Toggle small floating window (bottom-right)

### System Control
- `Ctrl-Alt s/r/e` — Stop/start/restart yabai

### Mouse Control (cliclick)
- `Alt 7/8/9/0` — Move cursor (20px steps)
- `Shift-Alt 7/8/9/0` — Move cursor (100px steps)
- `Alt y` — Click
- `Alt d` — Double click
- `Alt p` — Right click

