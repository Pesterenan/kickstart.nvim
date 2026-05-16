vim.g.format_on_save = false

require('conform').setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    if not vim.g.format_on_save then
      return nil
    end
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    else
      return { timeout_ms = 500 }
    end
  end,
  default_format_opts = {
    lsp_format = 'fallback',
  },
  formatters_by_ft = {
    java = { 'google-java-format' },
    javascript = { 'eslint_d', 'prettierd' },
    javascriptreact = { 'eslint_d', 'prettierd' },
    json = { 'jq' },
    lua = { 'stylua' },
    rust = { 'rustfmt' },
    typescript = { 'eslint_d', 'prettierd' },
    typescriptreact = { 'eslint_d', 'prettierd' },
  },
})

vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format({ async = true }) end, { desc = '[F]ormat buffer' })

local function toggle_format_on_save()
  vim.g.format_on_save = not vim.g.format_on_save
  local state = vim.g.format_on_save and 'ON' or 'OFF'
  vim.notify('Format on save: ' .. state, vim.log.levels.INFO)
  vim.keymap.set('n', '<leader>fs', toggle_format_on_save, { desc = '[F]ormat on Save: ' .. state, })
end

vim.keymap.set('n', '<leader>fs', toggle_format_on_save, { desc = '[F]ormat on Save: OFF', })
