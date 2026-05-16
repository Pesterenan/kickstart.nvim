local plugins = {
  'https://github.com/tpope/vim-rhubarb',
  'https://github.com/tpope/vim-fugitive',
}

vim.pack.add(plugins)

-- Git related keymaps:
vim.keymap.set('n', '<leader>gs', '<cmd>Git<CR>', { desc = 'Show [G]it [S]tatus' })
vim.keymap.set('n', '<leader>gp', '<cmd>Git push<CR>', { desc = '[G]it [P]ush' })
vim.keymap.set('n', '<leader>gl', '<cmd>Git log --oneline<CR>', { desc = '[G]it [L]og one line' })
vim.keymap.set('n', '<leader>gf', '<cmd>Git fetch -p<CR>', { desc = '[G]it [F]etch and prune' })

-- While on difftool get changes from either left or right side: (from ThePrimeagen)
vim.keymap.set('n', '<leader>gH', '<cmd>diffget //2<CR>', { desc = 'Get left side changes on difftool' })
vim.keymap.set('n', '<leader>gL', '<cmd>diffget //3<CR>', { desc = 'Get right side changes on difftool' })
