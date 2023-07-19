-- My remaps - Pesterenan:

-- On normal mode, when searching for the next word, center the term on the screen:
vim.keymap.set('n','n', 'nzzzv')
vim.keymap.set('n','N', 'Nzzzv')

-- Also center when moving half a screen:
vim.keymap.set('n','<C-d>', '<C-d>zz')
vim.keymap.set('n','<C-u>', '<C-u>zz')

-- Move selected lines up and down, even inside functions: (from ThePrimeagen)
vim.keymap.set('v','J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v','K', ":m '<-2<CR>gv=gv")

-- Open netrw to explore files: (from ThePrimeagen)
vim.keymap.set('n','<leader>pv', "<cmd>Ex<CR>", { desc = "Open NetRW"})

-- Navigate through open windows faster: (from NVChad remap)
vim.keymap.set('n','<C-h>', '<cmd>wincmd h<CR>')
vim.keymap.set('n','<C-j>', '<cmd>wincmd j<CR>')
vim.keymap.set('n','<C-k>', '<cmd>wincmd k<CR>')
vim.keymap.set('n','<C-l>', '<cmd>wincmd l<CR>')

-- Git related keymaps:
vim.keymap.set('n','<leader>gs', "<cmd>Git<CR>", { desc = "Show [G]it [S]tatus"})
vim.keymap.set('n','<leader>gp', "<cmd>Git push<CR>", { desc = "[G]it [P]ush"})
vim.keymap.set('n','<leader>gl', "<cmd>Git log --oneline<CR>", { desc = "[G]it [L]og one line"})

