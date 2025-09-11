-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap

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

-- copilot
-- keymap.set("i", "<C-l>", "copilot#AcceptLine()", { desc = "Accept Copilot suggestion" })
-- keymap.set("i", "<space><tab>", "copilot#AcceptLine()", { desc = "Accept Copilot suggestion" })
--
-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- set filetype
keymap.set("n", "<leader>ft", set_filetype, { desc = "Set filetype" })

-- save unnamed buffer
keymap.set("n", "<leader>sa", save_as, { desc = "Save unnamed buffer as..." })

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
keymap.set("n", "<leader>wm", "<cmd>MaximizerToggle<CR>", { desc = "Toggle maximizing/minimizing the current split." })

-- word wrap
keymap.set("n", "<leader>z", "<cmd>set wrap!<CR>", { desc = "toggle word wrap" })

-- new tab
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- move line up and down
-- keymap.set("n", "<M-j>", ":m +1<CR>==", { noremap = true, silent = true }) -- Move the current line down with Alt+j
-- keymap.set("n", "<M-k>", ":m -2<CR>==", { noremap = true, silent = true }) -- Move the current line up with Alt+k
-- toggle line number
keymap.set("n", "<leader>n", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })

-- toggle tailwind-fold
keymap.set("n", "<leader>t", "<cmd>TailwindFoldToggle<CR>", { desc = "toggle tailwind fold" })

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

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })

keymap.set("i", "<CR>", "<CR>", { noremap = true, desc = "Normal enter behavior" })

-- Wrap selected text
keymap.set("v", '<leader>w"', 'c"<C-r>""<ESC>', { desc = "Wrap selection with double quotes" })
keymap.set("v", "<leader>w'", "c'<C-r>\"'<ESC>", { desc = "Wrap selection with single quotes" })
keymap.set("v", "<leader>w(", 'c(<C-r>")<ESC>', { desc = "Wrap selection with parentheses" })
keymap.set("v", "<leader>w[", 'c[<C-r>"]<ESC>', { desc = "Wrap selection with brackets" })
keymap.set("v", "<leader>w{", 'c{<C-r>"}<ESC>', { desc = "Wrap selection with braces" })
keymap.set("v", "<leader>w`", 'c`<C-r>"`<ESC>', { desc = "Wrap selection with backticks" })
