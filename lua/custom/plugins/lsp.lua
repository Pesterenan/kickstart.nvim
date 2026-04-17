return {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Novo padrão Neovim 0.11+ / lspconfig v3
      -- Em vez de require('lspconfig').ts_ls.setup(), usamos a API nativa
      vim.lsp.config('ts_ls', {
        capabilities = capabilities,
      })
      vim.lsp.enable 'ts_ls'

      vim.lsp.config('eslint', {
        capabilities = capabilities,
      })
      vim.lsp.enable 'eslint'

      -- Autoformat on save para ESLint
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = { '*.js', '*.ts', '*.jsx', '*.tsx' },
        callback = function()
          if vim.fn.exists ':EslintFixAll' > 0 then vim.cmd 'EslintFixAll' end
        end,
      })
    end,
  },
}

