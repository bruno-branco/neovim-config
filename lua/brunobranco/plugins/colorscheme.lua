return {
	"neanias/everforest-nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("everforest").setup({
			transparent_background_level = 0,
			italics = true,
		})
		-- Optionally configure and load the colorscheme
		-- directly inside the plugin declaration.
		vim.cmd.colorscheme("everforest")
	end,
}
