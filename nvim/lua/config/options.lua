-- disable nvim
vim.g.lazyvim_prettier_needs_config = true
vim.opt.clipboard = "unnamedplus"

-- Over SSH the default macOS provider runs the *remote* pbcopy. Send yanks as
-- OSC 52 instead so they land on the clipboard of the machine you're typing
-- on (needs `set -g set-clipboard on` in tmux). Paste stays on pbpaste: tmux
-- does not forward OSC 52 read queries.
local osc52 = require("vim.ui.clipboard.osc52")
local function pbpaste()
  return { vim.fn.systemlist("pbpaste"), "v" }
end
vim.g.clipboard = {
  name = "OSC 52 + pbpaste",
  copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
  paste = { ["+"] = pbpaste, ["*"] = pbpaste },
}
