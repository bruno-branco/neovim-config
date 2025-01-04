return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				auto_install = true,
				ensure_installed = { "lua_ls", "ts_ls", "golangci_lint_ls", "denols" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.denols.setup({
				capabilities = capabilities,
				root_dir = lspconfig.util.root_pattern("deno.json", "import_map.json"),
				single_file_support = false,
				init_options = {
					lint = true,
					unstable = true,
				},
				filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
				settings = {
					deno = {
						enable = true,
						lint = true,
						unstable = true,
						suggest = {
							imports = {
								hosts = {
									["https://deno.land"] = true,
								},
							},
						},
					},
				},
				cmd = { "deno", "lsp" },
				cmd_env = {
					NO_COLOR = true,
				},
			})
			lspconfig.golangci_lint_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				root_dir = lspconfig.util.root_pattern("package.json"),
				single_file_support = false,
			})
			lspconfig.golangci_lint_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.html.setup({
				capabilities = capabilities,
			})

			vim.g.markdown_fenced_languages = {
				"ts=typescript",
			}
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
}
