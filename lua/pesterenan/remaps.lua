-- My remaps - Pesterenan:

-- On normal mode, when searching for the next word, center the term on the screen:
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Also center when moving half a screen:
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Move selected lines up and down, even inside functions: (from ThePrimeagen)
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
-- While on difftool get changes from either left or right side: (from ThePrimeagen)
vim.keymap.set('n', '<leader>gJ', '<cmd>diffget //2<CR>', { desc = 'Get left side changes on difftool' })
vim.keymap.set('n', '<leader>gL', '<cmd>diffget //3<CR>', { desc = 'Get right side changes on difftool' })

-- Open netrw to explore files: (from ThePrimeagen)
vim.keymap.set('n', '<leader>pv', "<cmd>Ex<CR>", { desc = "Open NetRW" })

-- Navigate through open windows faster: (from NVChad remap)
vim.keymap.set('n', '<C-h>', '<cmd>wincmd h<CR>')
vim.keymap.set('n', '<C-j>', '<cmd>wincmd j<CR>')
vim.keymap.set('n', '<C-k>', '<cmd>wincmd k<CR>')
vim.keymap.set('n', '<C-l>', '<cmd>wincmd l<CR>')

-- Navigate out of Terminal buffers
vim.keymap.set('t', '<C-h>', '<C-\\><C-N><cmd>wincmd h<CR>')
vim.keymap.set('t', '<C-j>', '<C-\\><C-N><cmd>wincmd j<CR>')
vim.keymap.set('t', '<C-k>', '<C-\\><C-N><cmd>wincmd k<CR>')
vim.keymap.set('t', '<C-l>', '<C-\\><C-N><cmd>wincmd l<CR>')

-- Git related keymaps:
vim.keymap.set('n', '<leader>gs', "<cmd>Git<CR>", { desc = "Show [G]it [S]tatus" })
vim.keymap.set('n', '<leader>gp', "<cmd>Git push<CR>", { desc = "[G]it [P]ush" })
vim.keymap.set('n', '<leader>gl', "<cmd>Git log --oneline<CR>", { desc = "[G]it [L]og one line" })
vim.keymap.set('n', '<leader>ph', "<cmd>Gitsigns preview_hunk_inline<CR>",
  { desc = "[G]itsigns [P]review [H]unk inline" })
vim.keymap.set('n', '<leader>gN', "<cmd>Gitsigns next_hunk<CR>", { desc = "[G]itsigns [N]ext [H]unk" })
vim.keymap.set('n', '<leader>gP', "<cmd>Gitsigns prev_hunk<CR>", { desc = "[G]itsigns [P]revious [H]unk" })

-- Stay indenting in visual mode
vim.keymap.set('v', "<", "<gv", { desc = "Less indentation" })
vim.keymap.set('v', ">", ">gv", { desc = "More indentation" })
