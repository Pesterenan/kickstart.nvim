local plugins = {
  'https://github.com/folke/snacks.nvim',
  'https://github.com/nickjvandyke/opencode.nvim',
}

vim.pack.add(plugins)

-- ─── snacks.nvim: configuração da integração (opções originais) ───
require('snacks').setup {
  input = {}, -- Enhance ask()
  picker = {
    actions = {
      opencode_send = function(...) return require('opencode').snacks_picker_send(...) end,
    },
    win = {
      input = {
        keys = {
          ['<a-a>'] = { 'opencode_send', mode = { 'n', 'i' } },
        },
      },
    },
  },
}

-- ─── opencode.nvim ───
vim.g.opencode_opts = {}

vim.o.autoread = true

-- Atalhos recomendados
vim.keymap.set({ 'n', 'x' }, '<leader>oa', function() require('opencode').ask('@this: ', { submit = true }) end, { desc = 'Ask opencode…' })

vim.keymap.set({ 'n', 'x' }, '<leader>os', function() require('opencode').select() end, { desc = 'Select opencode…' })

vim.keymap.set({ 'n', 't' }, '<leader>ot', function() require('opencode').toggle() end, { desc = 'Toggle opencode' })

-- Operadores que trabalham com range (expr = true)
vim.keymap.set({ 'n', 'x' }, '<leader>or', function() return require('opencode').operator '@this ' end, { desc = 'Add range to opencode', expr = true })

vim.keymap.set('n', '<leader>ol', function() return require('opencode').operator '@this ' .. '_' end, { desc = 'Add line to opencode', expr = true })

-- Scroll da sessão do opencode
vim.keymap.set('n', '<S-C-u>', function() require('opencode').command 'session.half.page.up' end, { desc = 'Scroll opencode up' })

vim.keymap.set('n', '<S-C-d>', function() require('opencode').command 'session.half.page.down' end, { desc = 'Scroll opencode down' })
