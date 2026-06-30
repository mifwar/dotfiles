local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Diff" })
end

local function reset_diff()
  vim.cmd("windo diffoff!")
end

local function start_diff(left_win, right_win)
  reset_diff()
  vim.api.nvim_set_current_win(left_win)
  vim.cmd("diffthis")
  vim.api.nvim_set_current_win(right_win)
  vim.cmd("diffthis")
end

local function diff_saved()
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local filepath = vim.api.nvim_buf_get_name(current_buf)

  if filepath == "" then
    notify("Current buffer has no file on disk", vim.log.levels.WARN)
    return
  end

  if vim.fn.filereadable(filepath) == 0 then
    notify("File is not readable: " .. filepath, vim.log.levels.ERROR)
    return
  end

  vim.cmd("leftabove vert new")
  local saved_win = vim.api.nvim_get_current_win()
  local saved_buf = vim.api.nvim_get_current_buf()

  vim.bo[saved_buf].buftype = "nofile"
  vim.bo[saved_buf].bufhidden = "wipe"
  vim.bo[saved_buf].swapfile = false
  vim.bo[saved_buf].modifiable = true
  vim.bo[saved_buf].readonly = false
  vim.bo[saved_buf].filetype = vim.bo[current_buf].filetype

  vim.cmd("read ++edit " .. vim.fn.fnameescape(filepath))
  vim.cmd("1delete _")

  vim.api.nvim_buf_set_name(saved_buf, filepath .. " [saved]")
  vim.bo[saved_buf].modifiable = false
  vim.bo[saved_buf].readonly = true

  start_diff(saved_win, current_win)
end

local function diff_buffer()
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local choices = {}

  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if buf.bufnr ~= current_buf then
      local name = buf.name ~= "" and vim.fn.fnamemodify(buf.name, ":~:.") or "[No Name]"
      table.insert(choices, {
        bufnr = buf.bufnr,
        label = string.format("%d: %s", buf.bufnr, name),
      })
    end
  end

  if #choices == 0 then
    notify("No other listed buffers to diff against", vim.log.levels.WARN)
    return
  end

  vim.ui.select(choices, {
    prompt = "Diff current buffer with:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end

    local target_win = vim.fn.win_findbuf(choice.bufnr)[1]
    if target_win and vim.api.nvim_win_is_valid(target_win) then
      start_diff(current_win, target_win)
      return
    end

    vim.cmd("rightbelow vert sbuffer " .. choice.bufnr)
    target_win = vim.api.nvim_get_current_win()
    start_diff(current_win, target_win)
  end)
end

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>df", "<cmd>DiffSaved<CR>", desc = "Diff with saved file" },
    { "<leader>db", "<cmd>DiffBuffers<CR>", desc = "Diff with buffer" },
    { "<leader>do", "<cmd>DiffOffAll<CR>", desc = "Diff off" },
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Git diff view" },
    { "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", desc = "Current file history" },
  },
  -- Register user commands inside config so they're created when the plugin
  -- actually loads, not at spec-eval time.
  config = function()
    vim.api.nvim_create_user_command("DiffSaved", diff_saved, {
      desc = "Diff current buffer against the saved file on disk",
    })
    vim.api.nvim_create_user_command("DiffBuffers", diff_buffer, {
      desc = "Diff current buffer against another listed buffer",
    })
    vim.api.nvim_create_user_command("DiffOffAll", reset_diff, {
      desc = "Turn off diff mode in all windows",
    })
  end,
  opts = {
    enhanced_diff_hl = true,
    view = {
      merge_tool = {
        layout = "diff3_mixed",
      },
    },
    file_panel = {
      win_config = {
        position = "left",
        width = 40,
      },
    },
  },
}
