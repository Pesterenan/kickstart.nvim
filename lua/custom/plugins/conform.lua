return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = function()
      vim.g.format_on_save = false

      local function toggle_format_on_save()
        vim.g.format_on_save = not vim.g.format_on_save
        local state = vim.g.format_on_save and 'ON' or 'OFF'
        vim.notify('Format on save: ' .. state, vim.log.levels.INFO)

        vim.keymap.set('n', '<leader>fs', toggle_format_on_save, {
          desc = '[F]ormat on Save: ' .. state,
        })
      end

      return {
        {
          '<leader>f',
          function() require('conform').format { async = true, lsp_format = 'fallback' } end,
          mode = 'n',
          desc = '[F]ormat buffer',
        },
        {
          '<leader>fs',
          toggle_format_on_save,
          mode = 'n',
          desc = '[F]ormat on Save: OFF', -- inicial
        },
      }
    end,
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        if not vim.g.format_on_save then return nil end

        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'eslint_d', 'prettierd' },
        javascriptreact = { 'eslint_d', 'prettierd' },
        typescript = { 'eslint_d', 'prettierd' },
        typescriptreact = { 'eslint_d', 'prettierd' },
        java = { 'google-java-format' },
        json = { 'jq' },
      },
    },
  },
}
