vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

--keeping cursor on the middle while jumpping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

--keeping cursor on the middle while searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

--find word under cursos inside document
vim.keymap.set("n", "<leader>sw", "yiw/<C-r>0<CR>")

--open lazy git
-- vim.keymap.set("n", "<leader>gc", ":Gvdiffsplit!<CR>")
vim.keymap.set("n", "<leader>lg", ":Lazygit<CR>")

--best remap ever
vim.keymap.set("x", "<leader>p", '"_dP')

--open and close terminal
vim.keymap.set("n", "<leader>ot", "<C-w><C-v>:terminal<CR>")

--let it snow!!
vim.keymap.set("n", "<leader>lis", ":LetItSnow<CR>")
vim.keymap.set("n", "<leader>sts", ":EndHygge<CR>")
vim.keymap.set("n", "<C-b>", ":b#<CR>")

--open error window lsp
vim.keymap.set("n", "<leader>le", ":LspDiagnosticsError<CR>")
vim.keymap.set("n", "<leader>lw", ":LspDiagnosticsWarning<CR>")
vim.keymap.set("n", "<leader>li", ":LspDiagnosticsInformation<CR>")
vim.keymap.set("n", "<leader>lc", ":LspDiagnosticsHint<CR>")
vim.keymap.set("n", "<leader>la", ":LspDiagnosticsToggle<CR>")

--copy current buffer dir
vim.keymap.set(
	"n",
	"<leader>yd",
	[[:let @+ = expand('%:h')<CR>]],
	{ noremap = true, silent = true, desc = "Copy file directory" }
)

-- open lsp message in buffer
vim.keymap.set("n", "<space>le", function()
	local bufnr = vim.api.nvim_get_current_buf() -- Get current buffer number
	vim.diagnostic.open_float(nil, { buf = bufnr + 1 }) -- Open diagnostics for that buffer
end, { noremap = true, silent = true })
