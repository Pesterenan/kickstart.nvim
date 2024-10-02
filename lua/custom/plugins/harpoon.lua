return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    -- REQUIRED
    harpoon:setup {}
    -- REQUIRED

    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end, { desc = '[A]dd current file to Harpoon' })
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

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", "<A-S-P>", function() harpoon:list():prev() end)
    vim.keymap.set("n", "<A-S-N>", function() harpoon:list():next() end)
  end,
}
