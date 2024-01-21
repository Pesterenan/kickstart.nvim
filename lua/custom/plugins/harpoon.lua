return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		-- REQUIRED
		harpoon:setup({})
		-- REQUIRED

		vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end,
			{ desc = '[A]ppend current file to Harpoon' })
		vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
			{ desc = 'Toggle Harpoon quick menu' })

		vim.keymap.set("n", "<C-j>", function() harpoon:list():select(1) end,
			{ desc = 'Select first file on harpoon' })
		vim.keymap.set("n", "<C-k>", function() harpoon:list():select(2) end,
			{ desc = 'Select second file on harpoon' })
		vim.keymap.set("n", "<C-l>", function() harpoon:list():select(3) end,
			{ desc = 'Select third file on harpoon' })
		vim.keymap.set("n", "<C-;>", function() harpoon:list():select(4) end,
			{ desc = 'Select fourth file on harpoon' })

		-- Toggle previous & next buffers stored within Harpoon list
		-- vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
		-- vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
	end
}
