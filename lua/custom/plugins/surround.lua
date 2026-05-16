local plugins = {
  'https://github.com/folke/which-key.nvim',
  'https://github.com/kylechui/nvim-surround',
  'https://github.com/roobert/surround-ui.nvim',
}

vim.pack.add(plugins)

require('nvim-surround').setup {}

require('surround-ui').setup {
  root_key = 'S',
}
