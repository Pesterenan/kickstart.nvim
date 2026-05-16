local plugins = {
  'https://github.com/nvim-lua/plenary.nvim',
  { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },
}

vim.pack.add(plugins)

local harpoon = require 'harpoon'
harpoon:setup {}

vim.keymap.set('n', '<leader>ha', function()
  harpoon:list():add()
end, { desc = '[H]arpoon [A]dd current file to Harpoon' })

vim.keymap.set('n', '<C-e>', function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = 'Toggle Harpoon quick menu' })

vim.keymap.set('n', '<A-h>', function()
  harpoon:list():select(1)
end, { desc = 'Select first file on Harpoon' })
vim.keymap.set('n', '<A-j>', function()
  harpoon:list():select(2)
end, { desc = 'Select second file on Harpoon' })
vim.keymap.set('n', '<A-k>', function()
  harpoon:list():select(3)
end, { desc = 'Select third file on Harpoon' })
vim.keymap.set('n', '<A-l>', function()
  harpoon:list():select(4)
end, { desc = 'Select fourth file on Harpoon' })

vim.keymap.set('n', '<A-S-P>', function()
  harpoon:list():prev()
end, { desc = 'Harpoon previous file' })
vim.keymap.set('n', '<A-S-N>', function()
  harpoon:list():next()
end, { desc = 'Harpoon next file' })
