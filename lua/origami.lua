local M = {}

local fn = vim.fn
local cmd = vim.cmd
local bo = vim.bo

local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

--------------------------------------------------------------------------------
-- KEYMAPS

-- `h` closes folds when at the beginning of a line (similar to how `l` opens
-- with `vim.opt.foldopen="hor"`). Works well with `vim.opt.startofline = true`
function M.h()
	-- `virtcol` accounts for tab indentation
	local onIndentOrFirstNonBlank = fn.virtcol(".") <= fn.indent(".") + 1 ---@diagnostic disable-line: param-type-mismatch
	if onIndentOrFirstNonBlank then 
		local wasFolded = pcall(normal, "zc")
		if wasFolded then return end
	end
	normal("h")
end

-- ensure that `l` does not move to the right when opening a fold, otherwise
-- this is the same behavior as with foldopen="hor" already
function M.l()
	local isOnFold = fn.foldclosed(".") > -1 ---@diagnostic disable-line: param-type-mismatch
	if isOnFold then
		pcall(normal, "zo")
	else
		normal("l")
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
local function pauseFoldOnSearch(forwardSearchKey, backwardSearchKey)
	-- disable auto-open when searching, since the following snippet does that better
	vim.opt.foldopen:remove { "search" }

	vim.keymap.set("n", forwardSearchKey, "zn/", { desc = "Origami /" })
	vim.keymap.set("n", backwardSearchKey, "zn?", { desc = "Origami ?" })

	vim.on_key(function(char)
		if vim.g.scrollview_refreshing then return end -- FIX https://github.com/dstein64/nvim-scrollview/issues/88#issuecomment-1570400161
		local key = fn.keytrans(char)
		local searchKeys = { "n", "N", "*", "#", "/", "?" }
		local searchConfirmed = (key == "<CR>" and fn.getcmdtype():find("[/?]") ~= nil)
		if not (searchConfirmed or fn.mode() == "n") then return end
		local searchKeyUsed = searchConfirmed or (vim.tbl_contains(searchKeys, key))

		local pauseFold = vim.opt.foldenable:get() and searchKeyUsed
		local unpauseFold = not (vim.opt.foldenable:get()) and not searchKeyUsed
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
		pauseFoldsOnSearch = {
			enabled = true,
			forwardKey = "/",
			backwardKey = "?",
		},
	}
	local config = vim.tbl_deep_extend("keep", userConfig, defaultConfig)

	if config.pauseFoldsOnSearch.enabled then
		local forwardKey = config.pauseFoldsOnSearch.forwardKey
		local backwardKey = config.pauseFoldsOnSearch.backwardKey
		pauseFoldOnSearch(forwardKey, backwardKey)
	end
	if config.keepFoldsAcrossSessions then keepFoldsAcrossSessions() end
end

--------------------------------------------------------------------------------

return M
