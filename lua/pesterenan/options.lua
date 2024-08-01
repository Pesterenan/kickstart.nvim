-- Custom options - Pesterenan

-- Set number lines and relative number lines:
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.magic = true

-- 2 indent spaces, incremental search highlighting, no line wrap:
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.incsearch = true
vim.opt.wrap = false

-- Set "maximum length column", always leave 8 lines on the screen visible top or bottom,
-- show git signs on the left
vim.opt.colorcolumn = "100"
vim.opt.scrolloff = 10
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.termguicolors = true
