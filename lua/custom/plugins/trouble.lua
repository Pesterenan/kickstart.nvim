return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
	},
	config = function()
		-- Lua
		vim.keymap.set("n", "<leader>T", function() require("trouble").toggle() end, { desc = '[T]oggle Trouble' })
		vim.keymap.set("n", "<leader>tw", function() require("trouble").toggle("workspace_diagnostics") end,
			{ desc = '[T]rouble [W]orkspace diagnostics' })
		vim.keymap.set("n", "<leader>td", function() require("trouble").toggle("document_diagnostics") end,
			{ desc = '[T]rouble [D]ocument diagnostics' })
		vim.keymap.set("n", "<leader>tq", function() require("trouble").toggle("quickfix") end,
			{ desc = '[T]rouble [Q]uickfix' })
		vim.keymap.set("n", "<leader>tl", function() require("trouble").toggle("loclist") end,
			{ desc = '[T]rouble [L]ocation list' })
		vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end, { desc = '[G]et [R]eferences' })
	end
}
