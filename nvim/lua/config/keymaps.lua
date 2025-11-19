-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap

-- Track last accessed tab for switching
local last_tab = vim.api.nvim_get_current_tabpage()

vim.api.nvim_create_autocmd("TabLeave", {
  callback = function()
    last_tab = vim.api.nvim_get_current_tabpage()
  end,
})

-- Function to jump to last accessed tab
local function goto_last_tab()
  if last_tab and vim.api.nvim_tabpage_is_valid(last_tab) then
    vim.api.nvim_set_current_tabpage(last_tab)
  end
end

-- Function to set filetype with user input
local function set_filetype()
  vim.ui.input({ prompt = "Enter filetype: " }, function(input)
    if input and input ~= "" then
      vim.cmd("set filetype=" .. input)
    end
  end)
end

-- Function to save unnamed buffer with user input
local function save_as()
  vim.ui.input({ prompt = "Save as: " }, function(input)
    if input and input ~= "" then
      vim.cmd("write " .. input)
    end
  end)
end

-- General Keymaps

-- exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- set filetype
keymap.set("n", "<leader>ft", set_filetype, { desc = "Set filetype" })

-- save unnamed buffer
keymap.set("n", "<leader>sa", save_as, { desc = "Save unnamed buffer as..." })

-- new buffer
keymap.set("n", "<leader>be", "<cmd>enew<CR>", { desc = "Create new buffer (empty)" })
keymap.set("n", "<leader>bs", "<cmd>new<CR>", { desc = "Create new buffer (split)" })

-- split window
keymap.set("n", "<leader>s|", "<C-w>v", { desc = "Split the window vertically." })
keymap.set("n", "<leader>s-", "<C-w>s", { desc = "Split the window horizontally." })

-- new panes
keymap.set("n", "<leader>nr", "<cmd>rightbelow vnew<CR>", { desc = "New pane on right" })
keymap.set("n", "<leader>nb", "<cmd>rightbelow new<CR>", { desc = "New pane on bottom" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make all splits equal in size." })
keymap.set("n", "<leader>we", "<C-w>=", { desc = "Make all splits equal in size." })
keymap.set("n", "<leader>wj", "5<C-w>+", { desc = "Increase the current split window's height." })
keymap.set("n", "<leader>wk", "5<C-w>-", { desc = "Decrease the current split window's height." })
keymap.set("n", "<leader>wh", "5<C-w><", { desc = "Increase the current split window's width." })
keymap.set("n", "<leader>wl", "5<C-w>>", { desc = "Decrease the current split window's width." })
keymap.set("n", "<leader>sr", "<C-w>r", { desc = "Rotate split windows." })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close the current split." })
keymap.set("n", "<leader>wx", "<cmd>close<CR>", { desc = "Close the current split." })

-- word wrap
keymap.set("n", "<leader>z", "<cmd>set wrap!<CR>", { desc = "toggle word wrap" })

-- toggle relative number
keymap.set("n", "<leader>n", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })

-- toggle tailwind-fold
keymap.set("n", "<leader>t", "<cmd>TailwindFoldToggle<CR>", { desc = "toggle tailwind fold" })

-- new tab
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })
keymap.set("n", "<leader>tl", goto_last_tab, { desc = "Go to last accessed tab" })

-- jump to specific tabs
keymap.set("n", "<leader>t1", "<cmd>1tabn<CR>", { desc = "Go to tab 1" })
keymap.set("n", "<leader>t2", "<cmd>2tabn<CR>", { desc = "Go to tab 2" })
keymap.set("n", "<leader>t3", "<cmd>3tabn<CR>", { desc = "Go to tab 3" })
keymap.set("n", "<leader>t4", "<cmd>4tabn<CR>", { desc = "Go to tab 4" })
keymap.set("n", "<leader>t5", "<cmd>5tabn<CR>", { desc = "Go to tab 5" })
keymap.set("n", "<leader>t6", "<cmd>6tabn<CR>", { desc = "Go to tab 6" })
keymap.set("n", "<leader>t7", "<cmd>7tabn<CR>", { desc = "Go to tab 7" })
keymap.set("n", "<leader>t8", "<cmd>8tabn<CR>", { desc = "Go to tab 8" })
keymap.set("n", "<leader>t9", "<cmd>9tabn<CR>", { desc = "Go to tab 9" })

-- keymap for `%!jq`
keymap.set("n", "<leader>jq", "<cmd>%!jq '.'<CR>", { desc = "Run jq filter" })

-- yank relative file path to clipboard
keymap.set("n", "<leader>yp", function()
  local filepath = vim.fn.expand("%")

  -- if path contains "src/" but doesn't start with it, remove everything before "src/"
  if filepath:find("src/") and not filepath:match("^src/") then
    filepath = filepath:match("src/.*")
  end

  vim.fn.setreg("+", filepath)
  print("Yanked relative path: " .. filepath)
end, { desc = "Yank relative file path to clipboard" })

-- show full absolute file path
keymap.set("n", "<leader>fp", function()
  local filepath = vim.fn.expand("%:p")

  -- Copy to clipboard
  vim.fn.setreg("+", filepath)

  -- Create a floating window to display the full path
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.min(vim.o.columns - 4, #filepath + 4)
  local height = math.ceil(#filepath / width) + 2

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " Full Path (copied to clipboard) ",
    title_pos = "center",
  }

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { filepath })
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Close on any key press
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, nowait = true })
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, nowait = true })
  vim.keymap.set("n", "<CR>", "<cmd>close<CR>", { buffer = buf, nowait = true })

  -- Auto-close after 3 seconds
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, 3000)
end, { desc = "Show full file path (and copy to clipboard)" })

-- Custom Snacks picker keybindings
-- Note: <leader>ff and <leader>fr are provided by LazyVim by default
-- Adding <leader>fs for grep (not provided by default)
keymap.set("n", "<leader>fs", function()
  require("snacks").picker.grep()
end, { desc = "Find String (Grep)" })
keymap.set("n", "<leader>fc", function()
  require("snacks").picker.grep_word()
end, { desc = "Find word under Cursor" })

keymap.set("i", "<CR>", "<CR>", { noremap = true, desc = "Normal enter behavior" })

-- Wrap selected text
keymap.set("v", '<leader>w"', 'c"<C-r>""<ESC>', { desc = "Wrap selection with double quotes" })
keymap.set("v", "<leader>w'", "c'<C-r>\"'<ESC>", { desc = "Wrap selection with single quotes" })
keymap.set("v", "<leader>w(", 'c(<C-r>")<ESC>', { desc = "Wrap selection with parentheses" })
keymap.set("v", "<leader>w[", 'c[<C-r>"]<ESC>', { desc = "Wrap selection with brackets" })
keymap.set("v", "<leader>w{", 'c{<C-r>"}<ESC>', { desc = "Wrap selection with braces" })
keymap.set("v", "<leader>w`", 'c`<C-r>"`<ESC>', { desc = "Wrap selection with backticks" })
