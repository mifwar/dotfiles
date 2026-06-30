local M = {}

local PANEL_WIDTH = 80

local state = {
  shell = { buf = nil, win = nil },
  lazygit = { buf = nil, win = nil },
}

local function is_valid_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function is_valid_win(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function terminal_running(buf)
  if not is_valid_buf(buf) then
    return false
  end

  local ok, job_id = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
  if not ok or type(job_id) ~= "number" then
    return false
  end

  return vim.fn.jobwait({ job_id }, 0)[1] == -1
end

local function reset_panel(panel)
  if is_valid_win(panel.win) then
    pcall(vim.api.nvim_win_close, panel.win, true)
  end

  if is_valid_buf(panel.buf) then
    pcall(vim.api.nvim_buf_delete, panel.buf, { force = true })
  end

  panel.win = nil
  panel.buf = nil
end

local function close_panel(panel)
  if is_valid_win(panel.win) then
    pcall(vim.api.nvim_win_close, panel.win, true)
  end

  panel.win = nil
end

local function configure_window(win)
  local wo = vim.wo[win]
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.statuscolumn = ""
  wo.winfixwidth = true
end

local function set_terminal_keymaps(buf)
  vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], {
    buffer = buf,
    desc = "Exit terminal mode",
  })

  vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], {
    buffer = buf,
    desc = "Move to left window",
  })
  vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], {
    buffer = buf,
    desc = "Move to lower window",
  })
  vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], {
    buffer = buf,
    desc = "Move to upper window",
  })
  vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], {
    buffer = buf,
    desc = "Move to right window",
  })
end

local function open_panel_window(buf)
  vim.cmd("botright vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.cmd("vertical resize " .. PANEL_WIDTH)

  if is_valid_buf(buf) then
    vim.api.nvim_win_set_buf(win, buf)
  end

  configure_window(win)
  return win
end

local function ensure_panel(panel, cmd, opts)
  if is_valid_win(panel.win) then
    vim.api.nvim_set_current_win(panel.win)
    vim.cmd("startinsert")
    return
  end

  if is_valid_buf(panel.buf) and not terminal_running(panel.buf) then
    reset_panel(panel)
  end

  panel.win = open_panel_window(panel.buf)

  if not is_valid_buf(panel.buf) then
    vim.cmd("enew")
    panel.buf = vim.api.nvim_get_current_buf()
    vim.bo[panel.buf].buflisted = false
    vim.bo[panel.buf].bufhidden = "hide"
    set_terminal_keymaps(panel.buf)

    vim.fn.termopen(cmd, {
      on_exit = function()
        if opts.close_on_exit then
          vim.schedule(function()
            reset_panel(panel)
          end)
        end
      end,
    })
  else
    vim.api.nvim_win_set_buf(panel.win, panel.buf)
  end

  vim.cmd("startinsert")
end

function M.toggle_shell()
  local panel = state.shell

  if is_valid_win(panel.win) then
    close_panel(panel)
    return
  end

  ensure_panel(panel, vim.o.shell, { close_on_exit = false })
end

function M.toggle_lazygit()
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("lazygit is not available in PATH", vim.log.levels.ERROR)
    return
  end

  local panel = state.lazygit

  if is_valid_win(panel.win) then
    close_panel(panel)
    return
  end

  ensure_panel(panel, "lazygit", { close_on_exit = true })
end

function M.setup()
  vim.api.nvim_create_user_command("TermPanel", function()
    M.toggle_shell()
  end, { desc = "Toggle terminal panel" })

  vim.api.nvim_create_user_command("LazyGitPanel", function()
    M.toggle_lazygit()
  end, { desc = "Open lazygit in terminal panel" })
end

return M
