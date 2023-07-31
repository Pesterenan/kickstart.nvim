-- Sets colorscheme to rose-pine
return {
	{
		'rose-pine/neovim',
		config = function()
			require('rose-pine').setup({
				dim_nc_background = true,
				disable_italics = true,
			})
		end
	},
	{
		'ellisonleao/gruvbox.nvim',
		config = function()
			require('gruvbox').setup({
				dim_inactive = true,
			})
			-- Auto-sets colorscheme:
			vim.cmd('colorscheme gruvbox')
		end
	},
}
