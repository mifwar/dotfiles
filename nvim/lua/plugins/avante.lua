return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  build = "make",
  -- Guard: skip setup entirely if the opencode binary is missing on a fresh
  -- machine, instead of erroring during plugin load.
  cond = function()
    return vim.fn.executable(os.getenv("HOME") .. "/.opencode/bin/opencode") == 1
  end,
  opts = {
    provider = "opencode",
    acp_providers = {
      ["opencode"] = {
        command = os.getenv("HOME") .. "/.opencode/bin/opencode",
        args = { "acp" },
        env = {
          OPENCODE_API_KEY = os.getenv("OPENCODE_API_KEY"),
        },
      },
    },
    behaviour = {
      auto_suggestions = false,
      auto_set_keymaps = true,
      support_paste_from_clipboard = true,
    },
    windows = {
      position = "right",
      width = 30,
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    "hrsh7th/nvim-cmp",
    "stevearc/dressing.nvim",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
