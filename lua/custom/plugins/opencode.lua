local plugins = {
  'https://github.com/folke/snacks.nvim',
  {
    src = 'https://github.com/nickjvandyke/opencode.nvim',
    -- Defaults to "main", supporting OpenCode v2.
    -- Uncomment to pull the latest stable release, supporting OpenCode v1.
    -- version = vim.version.range("*"),
  },
}

vim.pack.add(plugins)

require('snacks').setup {
  input = {
    enabled = true, -- Enhances ask
  },
  picker = {
    enabled = true, -- Enhances Select
    actions = {
      opencode_send = function(picker) ---@param picker snacks.Picker
        local items = vim.tbl_map(function(item) ---@param  item snacks.picker.Item
          return item.file and require('opencode').format { path = item.file, from = item.pos, to = item.end_pos } or item.text
        end, picker:selected { fallback = true })
        require('opencode').prompt(table.concat(items, ', ') .. ' ')
      end,
    },
    win = {
      input = {
        keys = {
          ['<a-o>'] = { 'opencode_send', mode = { 'n', 'i' } },
        },
      },
    },
  },
}

local opencode_cmd = 'opencode'
---@type snacks.terminal.Opts
local snacks_terminal_opts = {
  win = {
    position = 'right',
    enter = false,
  },
}

---@type opencode.Opts
vim.g.opencode_opts = {
  server = {
    start = function() require('snacks.terminal').open(opencode_cmd, snacks_terminal_opts) end,
  },
}

vim.o.autoread = true

-- Recommended shortcuts
vim.keymap.set({ 'n', 'x' }, '<leader>oa', function() require('opencode').ask '@this: ' end, { desc = 'Ask OpenCode…' })
vim.keymap.set({ 'n', 'x' }, '<leader>os', function() require('opencode').select() end, { desc = 'Select opencode…' })
vim.keymap.set({ 'n' }, '<leader>ot', function() require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts) end, { desc = 'Toggle OpenCode' })
vim.api.nvim_create_autocmd('User', {
  pattern = { 'OpencodeEvent:session.execution.started' },
  callback = function()
    local win = require('snacks.terminal').get(opencode_cmd, { create = false })
    if win then win:show() end
  end,
})
vim.keymap.set({ 'n', 'x' }, '<leader>or', function() return require('opencode').operator '@this ' end, { desc = 'Send range to OpenCode', expr = true })
vim.keymap.set('n', '<leader>ol', function() return require('opencode').operator '@this ' .. '_' end, { desc = 'Send line to opencode', expr = true })
