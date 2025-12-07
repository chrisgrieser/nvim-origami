local M = {}
--------------------------------------------------------------------------------

local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---@return boolean
local function shouldCloseFold()
	local closeOnlyOn1st = require("origami.config").config.foldKeymaps.closeOnlyOnFirstColumn
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local textBeforeCursor = vim.api.nvim_get_current_line():sub(1, col)
	local onIndentOrFirstNonBlank = textBeforeCursor:match("^%s*$") and not closeOnlyOn1st
	local firstChar = col == 0 and closeOnlyOn1st
	return onIndentOrFirstNonBlank or firstChar
end

-- `h` closes folds when at the beginning of a line.
function M.h()
	local count = vim.v.count1 -- saved as `normal` affects it
	for _ = 1, count, 1 do
		if shouldCloseFold() then
			local wasFolded = pcall(normal, "zc")
			if not wasFolded then normal("h") end
		else
			normal("h")
		end
	end
end

-- `^` closes folds recursively when at the beginning of a line.
function M.caret()
	if shouldCloseFold() then
		local wasFolded = pcall(normal, "zC")
		if not wasFolded then normal("^") end
	else
		normal("^")
	end
end

-- `l` on a folded line opens the fold.
function M.l()
	local count = vim.v.count1 -- saved as `normal` affects it
	for _ = 1, count, 1 do
		local isOnFold = vim.fn.foldclosed(".") > -1
		local action = isOnFold and "zo" or "l"
		pcall(normal, action)
	end
end

-- `$` on a folded line opens the fold recursively.
function M.dollar()
	local isOnFold = vim.fn.foldclosed(".") > -1
	local action = isOnFold and "zO" or "$"
	pcall(normal, action)
end

function M.setupKeymaps()
	vim.keymap.set("n", "h", function() M.h() end, { desc = "Origami h" })
	vim.keymap.set("n", "l", function() M.l() end, { desc = "Origami l" })
	vim.keymap.set("n", "$", function() M.dollar() end, { desc = "Origami $" })
	vim.keymap.set("n", "^", function() M.caret() end, { desc = "Origami ^" })
end

--------------------------------------------------------------------------------
return M
