require("brunobranco.settings")
require("brunobranco.remap")

require("brunobranco.lazy")
vim.g.markdown_fenced_languages = {
	"ts=typescript",
}

vim.o.winborder = "rounded"

vim.lsp.enable({ "lua_ls" })
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})
