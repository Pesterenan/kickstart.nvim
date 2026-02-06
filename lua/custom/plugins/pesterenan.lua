require 'custom.pesterenan'

return {
  -- Snippets configuration
  {
    name = 'pesterenan-snippets',
    dir = vim.fn.stdpath 'config',
    dependencies = { 'L3MON4D3/LuaSnip' },
    event = 'VimEnter',
    config = function()
      require 'custom.pesterenan.snippets'
    end,
  },
  {
    'williamboman/mason.nvim',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup {
        ensure_installed = { 'lua_ls' },
      }
      require('mason-tool-installer').setup {
        ensure_installed = { 'stylua', 'lua-language-server' },
      }
    end,
  },
}
