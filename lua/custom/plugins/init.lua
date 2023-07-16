-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
require('custom.options')
require('custom.remaps')
return {
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		config = function ()
			pcall(require('telescope').load_extension, 'file_browser')
			vim.api.nvim_set_keymap(
				"n",
				"<space>fb",
				":Telescope file_browser path=%:p:h select_buffer=true<CR>",
				{ noremap = true, desc = "[F]ile [B]rowser" })
		end
	},
}
