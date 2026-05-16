local plugins = {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-file-browser.nvim',
}

vim.pack.add(plugins)

pcall(require('telescope').load_extension, 'file_browser')
vim.keymap.set('n', '<leader>fb', ':Telescope file_browser path=%:p:h select_buffer=true<CR>', { noremap = true, desc = '[F]ile [B]rowser' })
