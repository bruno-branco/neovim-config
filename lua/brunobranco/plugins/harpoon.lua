return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local harpoon = require("harpoon")
		harpoon.setup()

		--open terminal
		-- vim.keymap.set("n", "<leader>ot", "<C-w><C-v>:terminal<CR>")

		vim.keymap.set("n", "<leader>ot", function()
			vim.cmd("vsplit | terminal")
			harpoon:list():replace_at(9) --for list id 9
			vim.cmd("startinsert")
		end)

		vim.api.nvim_create_user_command("KT", function()
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				local name = vim.api.nvim_buf_get_name(buf)
				if name:match("^term://") then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
			end
		end, {})

		vim.api.nvim_create_user_command("KB", function()
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end, {})

		harpoon:extend({
			UI_CREATE = function(cx)
				vim.keymap.set("n", "<C-v>", function()
					harpoon.ui:select_menu_item({ vsplit = true })
				end, { buffer = cx.bufnr })

				vim.keymap.set("n", "<C-x>", function()
					harpoon.ui:select_menu_item({ split = true })
				end, { buffer = cx.bufnr })

				vim.keymap.set("n", "<C-t>", function()
					harpoon.ui:select_menu_item({ tabedit = true })
				end, { buffer = cx.bufnr })
			end,
		})

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end)

		vim.keymap.set("n", "<leader>c", function()
			harpoon:list():clear()
		end)

		vim.keymap.set("n", "<leader>h", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)

		vim.keymap.set("n", "<leader>1", function()
			harpoon:list():select(1)
		end)
		vim.keymap.set("n", "<leader>2", function()
			harpoon:list():select(2)
		end)
		vim.keymap.set("n", "<leader>3", function()
			harpoon:list():select(3)
		end)
		vim.keymap.set("n", "<leader>4", function()
			harpoon:list():select(4)
		end)

		local spawnFloatingTerm = function(buf)
			-- window geometry
			local width = math.floor(vim.o.columns * 0.8)
			local height = math.floor(vim.o.lines * 0.8)
			local row = math.floor((vim.o.lines - height) / 2)
			local col = math.floor((vim.o.columns - width) / 2)

			-- open float window with that buffer
			local win = vim.api.nvim_open_win(buf, true, {
				relative = "editor",
				row = row,
				col = col,
				width = width,
				height = height,
				style = "minimal",
				border = "rounded",
			})

			-- spawn a terminal inside this buffer
			vim.fn.termopen(vim.o.shell, {
				on_exit = function(_, _, _)
					-- optionally close the floating window on terminal exit
					if vim.api.nvim_win_is_valid(win) then
						vim.api.nvim_win_close(win, true)
					end
				end,
			})

			-- mark the buffer in Harpoon
			local new_bufname = vim.api.nvim_buf_get_name(buf)
			harpoon:list():replace_at(9, { value = new_bufname, context = {} })
			vim.cmd("startinsert")
		end

		vim.keymap.set("n", "<leader>9", function()
			local harpoon = require("harpoon")
			local item = harpoon:list():get(9)
			if not item or not item.value then
				vim.notify("No terminal registered in slot 9, created a new one", vim.log.levels.WARN)

				-- create an empty buffer
				local buf = vim.api.nvim_create_buf(true, true)
				spawnFloatingTerm(buf)

				return
			end

			-- Try to find the buffer by name
			local bufnr = vim.fn.bufnr(item.value)
			if bufnr == -1 then
				local buf = vim.api.nvim_create_buf(true, true)
				spawnFloatingTerm(buf)
			else
				local width = math.floor(vim.o.columns * 0.8)
				local height = math.floor(vim.o.lines * 0.8)
				local row = math.floor((vim.o.lines - height) / 2)
				local col = math.floor((vim.o.columns - width) / 2)

				-- open float window with that buffer
				local win = vim.api.nvim_open_win(bufnr, true, {
					relative = "editor",
					row = row,
					col = col,
					width = width,
					height = height,
					style = "minimal",
					border = "rounded",
				})
				vim.cmd("startinsert")
			end
		end)

		--fixed terminal
		vim.keymap.set("n", "<leader>0", function()
			local harpoon = require("harpoon")
			local item = harpoon:list():get(10)
			if not item or not item.value then
				vim.notify("No terminal registered in slot 10, created a new one", vim.log.levels.WARN)

				-- create an empty buffer
				vim.cmd("terminal")
				harpoon:list():replace_at(10)
				vim.cmd("startinsert")

				return
			end

			-- Try to find the buffer by name
			local bufnr = vim.fn.bufnr(item.value)
			if bufnr == -1 then
				vim.cmd("terminal")
				harpoon:list():replace_at(10)
				vim.cmd("startinsert")
			--buffer exists
			else
				harpoon:list():select(10)
			end
		end)

		-- Toggle previous & next buffers stored within Harpoon list
		vim.keymap.set("n", "<C-S-P>", function()
			harpoon:list():prev()
		end)
		vim.keymap.set("n", "<C-S-N>", function()
			harpoon:list():next()
		end)
	end,
}
