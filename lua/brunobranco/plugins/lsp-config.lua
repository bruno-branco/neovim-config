return {
	{
		"mason-org/mason.nvim",
		version = "^1.0.0",
		config = function()
			require("mason").setup({})
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		version = "^1.0.0",
		config = function()
			require("mason-lspconfig").setup({
				auto_install = true,
				ensure_installed = { "lua_ls", "ts_ls", "golangci_lint_ls", "denols", "prismals" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")
			--
			-- List of LSPs to set up
			local servers = {
				"lua_ls",
				"gopls",
				"tailwindcss",
				"pyright",
				"html",
				"tailwindcss",
				"rust_analyzer",
				"prismals",
				"omnisharp",
			}

			-- Set up LSPs with capabilities
			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					capabilities = capabilities,
				})
			end

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
				single_file_support = true,
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
