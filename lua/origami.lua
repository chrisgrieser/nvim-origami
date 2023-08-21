local M = {}

local fn = vim.fn
local cmd = vim.cmd
local bo = vim.bo
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

--------------------------------------------------------------------------------
-- KEYMAPS

-- `h` closes folds when at the beginning of a line (similar to how `l` opens
-- with `vim.opt.foldopen="hor"`). Works well with `vim.opt.startofline = true`
function M.h()
	local count = vim.v.count1 -- count needs to be saved due to `normal` affecting it
	for _ = 1, count, 1 do
		local onIndentOrFirstNonBlank = fn.virtcol(".") <= fn.indent(".") + 1 ---@diagnostic disable-line: param-type-mismatch
		if onIndentOrFirstNonBlank then
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
		local isOnFold = fn.foldclosed(".") > -1 ---@diagnostic disable-line: param-type-mismatch
		if isOnFold then
			pcall(normal, "zo")
		else
			normal("l")
		end
	end
end

--------------------------------------------------------------------------------

-- REMEMBER FOLDS (AND CURSOR LOCATION)
local function remember(mode)
	-- stylua: ignore
	local ignoredFts = { "TelescopePrompt", "DressingSelect", "DressingInput", "toggleterm", "gitcommit", "replacer", "harpoon", "help", "qf" }
	if vim.tbl_contains(ignoredFts, bo.filetype) or bo.buftype ~= "" or not bo.modifiable then return end
	if mode == "save" then
		cmd.mkview(1)
	else
		pcall(function() cmd.loadview(1) end) -- pcall, since new files have no view yet
	end
end

local function keepFoldsAcrossSessions()
	augroup("origami-keep-folds", {})
	autocmd("BufWinLeave", {
		pattern = "?*",
		callback = function() remember("save") end,
		group = "origami-keep-folds",
	})
	autocmd("BufWinEnter", {
		pattern = "?*",
		callback = function() remember("load") end,
		group = "origami-keep-folds",
	})
end

--------------------------------------------------------------------------------
-- PAUSE FOLDS WHILE SEARCHING
-- Disabling search in foldopen has the disadvantage of making search nearly
-- unusable. Enabling search in foldopen has the disadvantage of constantly
-- opening all your folds as soon as you search. This snippet fixes this by
-- pausing folds while searching, but restoring them when you are done
-- searching.

local function pauseFoldOnSearch()
	-- disable auto-open when searching, since we take care of that in a better way
	vim.opt.foldopen:remove { "search" }

	vim.on_key(function(char)
		if vim.g.scrollview_refreshing then return end -- FIX https://github.com/dstein64/nvim-scrollview/issues/88#issuecomment-1570400161
		local key = fn.keytrans(char)
		local isCmdlineSearch = fn.getcmdtype():find("[/?]") ~= nil
		local searchMvKeys = { "n", "N", "*", "#" } -- works for RHS, therefore no need to consider remaps

		local searchStarted = (key == "/" or key == "?" and isCmdlineSearch)
		local searchConfirmed = (key == "<CR>" and isCmdlineSearch)
		local searchCancelled = (key == "<Esc>" and isCmdlineSearch)
		if not (searchStarted or searchConfirmed or searchCancelled or fn.mode() == "n") then return end
		local foldsArePaused = not (vim.opt.foldenable:get())
		local searchMovement = vim.tbl_contains(searchMvKeys, key)

		local pauseFold = (searchConfirmed or searchStarted or searchMovement) and not foldsArePaused
		local unpauseFold = (searchCancelled or not searchMovement)
			and foldsArePaused
			and not searchConfirmed

		if pauseFold then
			vim.opt.foldenable = false
		elseif unpauseFold then
			vim.opt.foldenable = true
			normal("zv") -- after closing folds, keep the *current* fold open
		end
	end, vim.api.nvim_create_namespace("auto_pause_folds"))
end

function M.setup(userConfig)
	local defaultConfig = {
		keepFoldsAcrossSessions = true,
		pauseFoldsOnSearch = true,
		setupFoldKeymaps = true,
	}
	local config = vim.tbl_deep_extend("keep", userConfig, defaultConfig)

	if config.pauseFoldsOnSearch then pauseFoldOnSearch() end
	if config.keepFoldsAcrossSessions then keepFoldsAcrossSessions() end
	if config.setupFoldKeymaps then
		vim.keymap.set("n", "h", M.h, { desc = "Origami h" })
		vim.keymap.set("n", "l", M.l, { desc = "Origami l" })
	end
end

--------------------------------------------------------------------------------

return M
