local plugins = {
  'https://github.com/mbbill/undotree',
}

vim.pack.add(plugins)

vim.keymap.set('n', '<leader>u', '<cmd>UndotreeToggle<CR>', { desc = 'Toggle [U]ndotree' })
