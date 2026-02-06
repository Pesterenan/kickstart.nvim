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

-- Open netrw to explore files: (from ThePrimeagen)
vim.keymap.set('n', '<leader>pv', '<cmd>Ex<CR>', { desc = 'Open NetRW' })

-- Navigate out of Terminal buffers
vim.keymap.set('t', '<C-H>', '<C-\\><C-N><cmd>wincmd h<CR>')
vim.keymap.set('t', '<C-J>', '<C-\\><C-N><cmd>wincmd j<CR>')
vim.keymap.set('t', '<C-K>', '<C-\\><C-N><cmd>wincmd k<CR>')
vim.keymap.set('t', '<C-L>', '<C-\\><C-N><cmd>wincmd l<CR>')

-- Stay indenting in visual mode
vim.keymap.set('v', '<', '<gv', { desc = 'Less indentation' })
vim.keymap.set('v', '>', '>gv', { desc = 'More indentation' })
