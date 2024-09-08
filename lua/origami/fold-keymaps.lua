local M = {}
--------------------------------------------------------------------------------

local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

-- `h` closes folds when at the beginning of a line (similar to how `l` opens
-- with `vim.opt.foldopen="hor"`). Works well with `vim.opt.startofline = true`
function M.h()
	local config = require("origami.config").config
	local count = vim.v.count1 -- count needs to be saved due to `normal` affecting it
	for _ = 1, count, 1 do
		local col = vim.api.nvim_win_get_cursor(0)[2]
		local textBeforeCursor = vim.api.nvim_get_current_line():sub(1, col)
		local onIndentOrFirstNonBlank = textBeforeCursor:match("^%s*$")
			and not config.hOnlyOpensOnFirstColumn
		local firstChar = col == 0 and config.hOnlyOpensOnFirstColumn
		if onIndentOrFirstNonBlank or firstChar then
			local wasFolded = pcall(normal, "zc")
			if not wasFolded then normal("h") end
		else
			normal("h")
		end
	end
end

-- ensure that `l` does not move to the right when opening a fold, otherwise
-- this is the same behavior as with foldopen="hor" already
function M.l()
	local count = vim.v.count1 -- count needs to be saved due to `normal` affecting it
	for _ = 1, count, 1 do
		local isOnFold = vim.fn.foldclosed(".") > -1 ---@diagnostic disable-line: param-type-mismatch
		local action = isOnFold and "zo" or "l"
		pcall(normal, action)
	end
end

--------------------------------------------------------------------------------
return M
