return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>gg",
      function()
        require("snacks").lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>gL",
      function()
        require("snacks").lazygit.log()
      end,
      desc = "Lazygit Log",
    },
    {
      "<leader>gf",
      function()
        require("snacks").lazygit.log_file()
      end,
      desc = "Lazygit Current File History",
    },
  },
  opts = {
    lazygit = {
      -- Integrate lazygit's edit action with this Neovim instance.
      configure = true,
      config = {
        os = {
          -- LazyGit's built-in nvim-remote preset uses --remote-tab.
          -- Use --remote instead so pressing `e` opens in the current window.
          edit = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}})',
          editAtLine = '[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}} && nvim --server "$NVIM" --remote-send ":{{line}}<CR>")',
        },
      },
    },
    picker = {
      hidden = true, -- show hidden files (dotfiles like .gitignore)
      ignored = false, -- respect .gitignore (exclude node_modules, etc.)
      sources = {
        lsp_definitions = {
          jump = { reuse_win = true }, -- jump directly if only one result
        },
      },
    },
  },
}
