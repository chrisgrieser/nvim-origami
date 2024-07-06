local M = {}
local config

local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

--------------------------------------------------------------------------------
-- KEYMAPS

-- `h` closes folds when at the beginning of a line (similar to how `l` opens
-- with `vim.opt.foldopen="hor"`). Works well with `vim.opt.startofline = true`
function M.h()
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
		pcall(normal, isOnFold and "zo" or "l")
	end
end

--------------------------------------------------------------------------------

-- REMEMBER FOLDS (AND CURSOR LOCATION)
local function remember(mode)
	-- stylua: ignore
	local ignoredFts = { "TelescopePrompt", "DressingSelect", "DressingInput", "toggleterm", "gitcommit", "replacer", "harpoon", "help", "qf" }
	if vim.tbl_contains(ignoredFts, vim.bo.ft) or vim.bo.buftype ~= "" or not vim.bo.modifiable then
		return
	end

	if mode == "save" then
		-- only save folds and cursor, do not save options or the cwd, as that
		-- leads to unpredictable behavior
		local viewOptsBefore = vim.opt.viewoptions:get()
		vim.opt.viewoptions = { "cursor", "folds" }
		vim.cmd.mkview(1)
		vim.opt.viewoptions = viewOptsBefore
	else
		pcall(function() vim.cmd.loadview(1) end) -- pcall, since new files have no view yet
	end
end

local function keepFoldsAcrossSessions()
	vim.api.nvim_create_augroup("origami-keep-folds", {})
	vim.api.nvim_create_autocmd("BufWinLeave", {
		pattern = "?*",
		callback = function() remember("save") end,
		group = "origami-keep-folds",
	})
	vim.api.nvim_create_autocmd("BufWinEnter", {
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
		local key = vim.fn.keytrans(char)
		local isCmdlineSearch = vim.fn.getcmdtype():find("[/?]") ~= nil
		local isNormalMode = vim.api.nvim_get_mode().mode == "n"

		local searchStarted = (key == "/" or key == "?") and isNormalMode
		local searchConfirmed = (key == "<CR>" and isCmdlineSearch)
		local searchCancelled = (key == "<Esc>" and isCmdlineSearch)
		if not (searchStarted or searchConfirmed or searchCancelled or isNormalMode) then return end
		local foldsArePaused = not (vim.opt.foldenable:get())
		-- works for RHS, therefore no need to consider remaps
		local searchMovement = vim.tbl_contains({ "n", "N", "*", "#" }, key)

		local pauseFold = (searchConfirmed or searchStarted or searchMovement) and not foldsArePaused
		local unpauseFold = foldsArePaused and (searchCancelled or not searchMovement)
		if pauseFold then
			vim.opt_local.foldenable = false
		elseif unpauseFold then
			vim.opt_local.foldenable = true
			pcall(vim.cmd.foldopen, { bang = true }) -- after closing folds, keep the *current* fold open
		end
	end, vim.api.nvim_create_namespace("auto_pause_folds"))
end

--------------------------------------------------------------------------------

local defaultConfig = {
	keepFoldsAcrossSessions = true,
	pauseFoldsOnSearch = true,
	setupFoldKeymaps = true,
	hOnlyOpensOnFirstColumn = false,
}
config = defaultConfig

function M.setup(userConfig)
	config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})

	if config.pauseFoldsOnSearch then pauseFoldOnSearch() end
	if config.keepFoldsAcrossSessions then keepFoldsAcrossSessions() end
	if config.setupFoldKeymaps then
		vim.keymap.set("n", "h", M.h, { desc = "Origami h" })
		vim.keymap.set("n", "l", M.l, { desc = "Origami l" })
	end
end

--------------------------------------------------------------------------------
return M
