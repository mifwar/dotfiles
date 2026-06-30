# Neovim config

Personal LazyVim-based Neovim configuration, symlinked to `~/.config/nvim`.

- **Entry**: `init.lua` → bootstraps `lazy.nvim` via `lua/config/lazy.lua`
- **Config**: `lua/config/{options,keymaps,autocmds,terminal_panel,lazy}.lua`
- **Plugins**: `lua/plugins/*.lua` (each file returns a lazy.nvim spec)

See the repo root [`README.md`](../README.md) for the keybinding reference.
