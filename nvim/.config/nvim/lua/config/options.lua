-- Options on top of LazyVim's defaults: https://www.lazyvim.org/configuration/general
local opt = vim.opt

opt.autoread = true      -- pick up files an agent changed on disk
opt.scrolloff = 8
opt.wrap = false
opt.swapfile = false     -- avoid swap-file prompts when agents edit the same files
opt.undofile = true
