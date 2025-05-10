require("brunobranco.settings")
require("brunobranco.remap")
require("brunobranco.lazy")
vim.g.markdown_fenced_languages = {
	"ts=typescript",
}

-- interactive_regex_search.lua
-- Interactive regex search with real-time highlighting and yank functionality
-- Fixed version with better performance and error handling

local M = {}

-- Create a namespace for our highlights
local ns_id = vim.api.nvim_create_namespace("interactive_regex_search")

-- Function to clear all highlights in our namespace for a specific buffer
local function clear_highlights(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

-- Debounce function to prevent too frequent updates
local function debounce(func, timeout)
	local timer = vim.loop.new_timer()
	return function(...)
		local args = { ... }
		timer:stop()
		timer:start(timeout, 0, function()
			vim.schedule(function()
				func(unpack(args))
			end)
		end)
	end
end

-- Function to highlight matches based on pattern in a specific buffer
local function highlight_matches(bufnr, pattern, start_line, end_line)
	-- Protect against invalid buffer
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return 0
	end

	clear_highlights(bufnr)

	-- Validate pattern
	if pattern == "" then
		return 0
	end

	-- Remove leading and trailing slashes if present (for Vim regex format)
	local vim_pattern = pattern
	if vim_pattern:sub(1, 1) == "/" and vim_pattern:sub(-1) == "/" then
		vim_pattern = vim_pattern:sub(2, -2)
	end

	local count = 0

	-- Use pcall to catch errors in pattern matching
	local successful, err = pcall(function()
		-- Limit the number of lines processed per run to prevent freezing
		local max_lines_per_run = 1000
		local adjusted_end_line = math.min(end_line, start_line + max_lines_per_run - 1)

		-- Check if pattern is valid before proceeding
		vim.fn.matchstr("test", vim_pattern)

		for i = start_line, adjusted_end_line do
			-- Ensure line exists
			if i > vim.api.nvim_buf_line_count(bufnr) then
				break
			end

			local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
			if not line then
				break
			end

			-- Find matches using Vim's search function
			local col = 0
			local match_limit = 100 -- Limit matches per line to prevent infinite loops
			local match_count = 0

			while col < #line and match_count < match_limit do
				local match_pos = vim.fn.match(line, vim_pattern, col)
				if match_pos == -1 then
					break
				end

				local match_end = vim.fn.matchend(line, vim_pattern, col)

				-- Protect against infinite loop where match position doesn't advance
				if match_end <= col then
					col = col + 1
				else
					col = match_end
				end

				-- Add highlight
				vim.api.nvim_buf_add_highlight(bufnr, ns_id, "Search", i - 1, match_pos, match_end)

				count = count + 1
				match_count = match_count + 1
			end
		end

		-- If we didn't process all lines, add a notification
		if adjusted_end_line < end_line then
			vim.schedule(function()
				vim.notify(
					"Only showing first " .. max_lines_per_run .. " lines of matches to prevent freezing",
					vim.log.levels.INFO
				)
			end)
		end
	end)

	if not successful then
		vim.schedule(function()
			vim.notify("Invalid pattern: " .. (err or "unknown error"), vim.log.levels.WARN)
		end)
		return 0
	end

	return count
end

-- Function to yank all matches to a register from a specific buffer
local function yank_matches(bufnr, pattern, start_line, end_line, register)
	if pattern == "" then
		return 0
	end

	-- Remove leading and trailing slashes if present (for Vim regex format)
	local vim_pattern = pattern
	if vim_pattern:sub(1, 1) == "/" and vim_pattern:sub(-1) == "/" then
		vim_pattern = vim_pattern:sub(2, -2)
	end

	local matches = {}
	local count = 0

	-- Use pcall to catch errors in pattern matching
	local successful, err = pcall(function()
		-- Limit the number of lines processed to prevent freezing
		local max_lines = 10000
		local adjusted_end_line = math.min(end_line, start_line + max_lines - 1)

		for i = start_line, adjusted_end_line do
			-- Ensure line exists
			if i > vim.api.nvim_buf_line_count(bufnr) then
				break
			end

			local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
			if not line then
				break
			end

			-- Find matches using Vim's search function
			local col = 0
			local match_limit = 100 -- Limit matches per line to prevent infinite loops
			local match_count = 0

			while col < #line and match_count < match_limit do
				local match_pos = vim.fn.match(line, vim_pattern, col)
				if match_pos == -1 then
					break
				end

				local match_end = vim.fn.matchend(line, vim_pattern, col)

				-- Protect against infinite loop
				if match_end <= col then
					col = col + 1
				else
					-- Get match text
					local match_text = string.sub(line, match_pos + 1, match_end)

					-- Add to matches
					if match_text ~= "" then
						table.insert(matches, match_text)
						count = count + 1
					end

					col = match_end
				end

				match_count = match_count + 1
			end
		end
	end)

	if not successful then
		vim.schedule(function()
			vim.notify("Invalid pattern for yanking: " .. (err or "unknown error"), vim.log.levels.WARN)
		end)
		return 0
	end

	-- Join matches with newlines and store in the register
	if count > 0 then
		vim.fn.setreg(register, table.concat(matches, "\n"))
	end

	return count
end

-- Variables to track timeout
local last_update_time = 0
local update_delay = 300 -- milliseconds

-- Main interactive regex search function
function M.interactive_regex_search()
	-- Store the current buffer (this is the user's buffer that we'll search in)
	local target_bufnr = vim.api.nvim_get_current_buf()

	-- Get current visual selection or use the entire buffer
	local start_line, end_line
	local mode = vim.api.nvim_get_mode().mode

	if mode == "v" or mode == "V" or mode == "\22" then
		-- Get visual selection
		vim.cmd("normal! \\<Esc>")
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")
		start_line = start_pos[2]
		end_line = end_pos[2]
	else
		-- Use entire buffer
		start_line = 1
		end_line = vim.api.nvim_buf_line_count(target_bufnr)
	end

	-- Register for storing matches (default to 'a')
	local register = "a"

	-- Create a temporary buffer for input that won't interfere with the main editor
	local input_bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(input_bufnr, "buftype", "nofile")

	-- Set up a temporary autocmd to process input changes
	local augroup = vim.api.nvim_create_augroup("InteractiveRegexGroup", { clear = true })

	-- Variable to track current input
	local current_pattern = ""
	local match_count = 0

	-- Function to process the pattern with rate limiting
	local function process_pattern()
		local current_time = vim.loop.now()

		-- Only update if enough time has passed since last update
		if (current_time - last_update_time) < update_delay then
			return
		end

		last_update_time = current_time

		local current_lines = vim.api.nvim_buf_get_lines(input_bufnr, 0, -1, false)
		local pattern = current_lines[1] or ""

		if pattern ~= current_pattern then
			current_pattern = pattern
			match_count = highlight_matches(target_bufnr, pattern, start_line, end_line)

			-- Update title with match count
			if match_count > 0 then
				vim.api.nvim_win_set_option(0, "title", true)
				vim.api.nvim_win_set_option(
					0,
					"titlestring",
					match_count .. " match" .. (match_count == 1 and "" or "es")
				)
			else
				vim.api.nvim_win_set_option(0, "title", true)
				vim.api.nvim_win_set_option(0, "titlestring", "No matches")
			end
		end
	end

	-- Debounced version of process_pattern
	local debounced_process = debounce(process_pattern, 150)

	-- Set up autocmds to update highlighting as user types
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		group = augroup,
		buffer = input_bufnr,
		callback = function()
			debounced_process()
		end,
	})

	-- Create a temporary window
	local win_height = 1
	local input_win = vim.api.nvim_open_win(input_bufnr, true, {
		relative = "editor",
		width = math.min(60, vim.o.columns - 4),
		height = win_height,
		row = vim.o.lines - win_height - 2,
		col = 2,
		style = "minimal",
		border = "rounded",
		title = "Vim regex pattern (press Enter to yank to reg '" .. register .. "', Esc to cancel)",
		title_pos = "center",
	})

	-- Prepopulate with forward slashes as a hint it's a vim pattern
	vim.api.nvim_buf_set_lines(input_bufnr, 0, -1, false, { "//" })

	-- Place cursor between the slashes
	vim.api.nvim_win_set_cursor(input_win, { 1, 1 })

	-- Enter insert mode
	vim.cmd("startinsert")

	-- Set up keymappings for the input buffer
	vim.keymap.set("i", "<CR>", function()
		-- Get the final pattern
		local lines = vim.api.nvim_buf_get_lines(input_bufnr, 0, -1, false)
		local pattern = lines[1] or ""

		-- Yank matches from the target buffer
		local yanked = yank_matches(target_bufnr, pattern, start_line, end_line, register)

		-- Close the input window
		vim.api.nvim_win_close(input_win, true)

		-- Clean up autocommands
		vim.api.nvim_clear_autocmds({ group = augroup })

		-- Clear highlights from target buffer
		clear_highlights(target_bufnr)

		-- Reset window title
		vim.api.nvim_win_set_option(0, "title", false)

		-- Display feedback message
		if yanked > 0 then
			vim.api.nvim_echo({
				{
					string.format("Yanked %d match%s to register '%s'", yanked, yanked == 1 and "" or "es", register),
					"None",
				},
			}, false, {})
		else
			vim.api.nvim_echo({ { "No matches to yank", "WarningMsg" } }, false, {})
		end

		-- Return to normal mode
		vim.cmd("stopinsert")
	end, { buffer = input_bufnr })

	vim.keymap.set({ "i", "n" }, "<Esc>", function()
		-- Close the input window
		vim.api.nvim_win_close(input_win, true)

		-- Clean up autocommands
		vim.api.nvim_clear_autocmds({ group = augroup })

		-- Clear highlights from target buffer
		clear_highlights(target_bufnr)

		-- Reset window title
		vim.api.nvim_win_set_option(0, "title", false)

		-- Display cancel message
		vim.api.nvim_echo({ { "Regex search cancelled", "None" } }, false, {})

		-- Return to normal mode
		vim.cmd("stopinsert")
	end, { buffer = input_bufnr })
end

-- Define a command to launch the interactive regex search
vim.api.nvim_create_user_command("InteractiveRegex", function()
	-- Protect against crashes by wrapping in pcall
	local success, err = pcall(M.interactive_regex_search)
	if not success then
		vim.notify("Error in interactive regex search: " .. tostring(err), vim.log.levels.ERROR)
	end
end, {
	desc = "Interactive regex search with real-time highlighting and yanking",
	range = true,
})

-- Configure a keybinding (optional)
vim.api.nvim_set_keymap(
	"n",
	"<Leader>r",
	":InteractiveRegex<CR>",
	{ noremap = true, silent = true, desc = "Interactive regex search" }
)
vim.api.nvim_set_keymap(
	"v",
	"<Leader>r",
	":InteractiveRegex<CR>",
	{ noremap = true, silent = true, desc = "Interactive regex search on selection" }
)

return M
