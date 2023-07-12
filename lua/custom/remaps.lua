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
vim.keymap.set('n','<leader>pf', ":Ex<Enter>")
