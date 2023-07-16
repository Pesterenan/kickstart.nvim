-- Sets colorscheme to rose-pine
return {
	'rose-pine/neovim',
	config = function()
		vim.cmd('colorscheme rose-pine')
		vim.api.nvim_set_hl(0,"Normal", { bg = 'none'})
		vim.api.nvim_set_hl(0,"NormalFloat", { bg = 'none'})
	end
}
