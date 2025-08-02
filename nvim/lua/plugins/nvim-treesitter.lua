return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = { "go", "lua", "vim", "javascript", "html" }, -- Add 'go' for Golang support
    highlight = {
      enable = true, -- Enables syntax highlighting
      additional_vim_regex_highlighting = false, -- Disable legacy regex-based highlighting
    },
    indent = {
      enable = true, -- Enables improved indentation handling
    },
  },
  build = ":TSUpdate", -- Automatically update parsers
}
