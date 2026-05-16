local plugins = {
  'https://github.com/Pesterenan/ic10.nvim',
}

vim.pack.add(plugins)

require('ic10').setup {
  debug = true,
}
