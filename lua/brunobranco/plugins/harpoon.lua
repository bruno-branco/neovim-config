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

		vim.keymap.set("n", "<leader>9", function()
			local harpoon = require("harpoon")
			local item = harpoon:list():get(9)
			if not item or not item.value then
				vim.notify("No terminal registered in slot 9, created a new one", vim.log.levels.WARN)
				vim.cmd("vsplit | terminal")
				harpoon:list():replace_at(9) --for list id 9
				vim.cmd("startinsert")
				return
			end

			-- Try to find the buffer by name
			local bufnr = vim.fn.bufnr(item.value)
			if bufnr == -1 then
				-- Buffer doesn't exist, spawn a new terminal
				vim.cmd("vsplit | terminal")
				-- Update Harpoon slot 9 with the new buffer name
				local new_bufname = vim.api.nvim_buf_get_name(0)
				harpoon:list():replace_at(9, { value = new_bufname, context = {} })
				vim.cmd("startinsert")
			else
				-- Buffer exists, open it in a vsplit
				vim.cmd("vsplit")
				vim.api.nvim_set_current_buf(bufnr)
				vim.cmd("startinsert")
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
