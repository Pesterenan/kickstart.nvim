local capabilities = require('blink.cmp').get_lsp_capabilities()

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

vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  settings = {
    ['rust-analyzer'] = {
      check = { command = 'clippy' },
      cargo = { allFeatures = true },
      procMacro = { enable = true },
      inlayHints = { typeHints = { enable = true }, parameterHints = { enable = true }, chainingHints = { enable = true } },
      diagnostics = { enable = true },
      trace = { server = 'verbose' },
    },
  },
})
