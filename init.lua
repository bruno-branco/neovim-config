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

-- Manage env files
vim.keymap.set("n", "<leader>oe", function()
	local cwd = vim.fn.getcwd()
	local env = cwd .. "/.env"
	local envlocal = cwd .. "/.env.local"

	local target
	if vim.fn.filereadable(env) == 1 then
		vim.cmd("vnew .env")
	elseif vim.fn.filereadable(envlocal) == 1 then
		vim.cmd("vnew .env.local")
	else
		vim.cmd("!touch .env")
		vim.notify("Env file does not exist, press enter to create one")
		vim.cmd("vnew .env")
	end
end, {})
