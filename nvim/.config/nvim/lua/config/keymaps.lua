-- Keymaps on top of LazyVim's defaults (press <space> and wait to see them all).
-- Handy built-ins: <leader><space> find files, <leader>/ live grep (rg),
-- <leader>gg lazygit, <leader>e file explorer.
local map = vim.keymap.set

map("n", "<leader>sw", function()
  require("fzf-lua").grep_cword()
end, { desc = "Grep word under cursor (rg)" })
