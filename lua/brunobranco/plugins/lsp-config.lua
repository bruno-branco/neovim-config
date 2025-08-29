return {
	{
		"seblyng/roslyn.nvim",
		ft = "cs",
		opts = {
			filewatching = "roslyn",
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		version = "^1.0.0",
		config = function()
			require("mason-lspconfig").setup({
				auto_install = true,
				ensure_installed = { "ts_ls", "lua_ls" },
			})
		end,
	},
	{
		"mason-org/mason.nvim",
		version = "^2.0.0",
		config = function()
			require("mason").setup({
				registries = { "github:Crashdummyy/mason-registry", "github:mason-org/mason-registry" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")
			-- List of LSPs to set up
			local servers = {
				-- "lua_ls",
				-- "gopls",
				"tailwindcss",
				-- "pyright",
				"html",
				-- "tailwindcss",
				-- "rust_analyzer",
				"prismals",
				-- "roslyn",
			}

			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					capabilities = capabilities,
				})
			end

			----------

			require("lspconfig").eslint.setup({
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
			})
			-- Set up LSPs with capabilities

			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				root_dir = lspconfig.util.root_pattern("package.json"),
				single_file_support = true,
				handlers = {
					["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
						if result.diagnostics == nil then
							return
						end

						-- ignore some tsserver diagnostics
						local idx = 1
						while idx <= #result.diagnostics do
							local entry = result.diagnostics[idx]

							local formatter = require("format-ts-errors")[entry.code]
							entry.message = formatter and formatter(entry.message) or entry.message

							-- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
							if entry.code == 80001 then
								-- { message = "File is a CommonJS module; it may be converted to an ES module.", }
								table.remove(result.diagnostics, idx)
							else
								idx = idx + 1
							end
						end

						vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
					end,
				},
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

			vim.g.markdown_fenced_languages = {
				"ts=typescript",
			}
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
}
