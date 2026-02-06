return {
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
}

