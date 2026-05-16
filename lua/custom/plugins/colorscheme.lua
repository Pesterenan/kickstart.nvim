local plugins = {
  'https://github.com/xiyaowong/nvim-transparent',
  'https://github.com/tanvirtin/monokai.nvim',
  'https://github.com/rose-pine/neovim',
  'https://github.com/ellisonleao/gruvbox.nvim',
  'https://github.com/catppuccin/nvim',
}

vim.pack.add(plugins)

-- Colorschemes setup:
require('rose-pine').setup {
  dim_nc_background = true,
  disable_italics = true,
}
require('gruvbox').setup {
  dim_inactive = true,
}
require('catppuccin').setup {
  dim_inactive = {
    enabled = true,
    shade = 'dark',
    percentage = 0.20,
  },
}
