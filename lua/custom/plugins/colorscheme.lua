-- Colorscheme setup:
return {
  {
    -- Plugin to make window's background transparent
    'xiyaowong/nvim-transparent',
  },
  -- Colorschemes:
  {
    'tanvirtin/monokai.nvim',
  },
  {
    'rose-pine/neovim',
    config = function()
      require('rose-pine').setup {
        dim_nc_background = true,
        disable_italics = true,
      }
    end,
  },
  {
    'ellisonleao/gruvbox.nvim',
    config = function()
      require('gruvbox').setup {
        dim_inactive = true,
      }
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        dim_inactive = {
          enabled = true,
          shade = 'dark',
          percentage = 0.20,
        },
      }
    end,
  },
}
