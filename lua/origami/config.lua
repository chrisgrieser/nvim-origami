local M = {}
--------------------------------------------------------------------------------

---@class Origami.config
local defaultConfig = {
	-- requires with `nvim-ufo`
	keepFoldsAcrossSessions = package.loaded["ufo"] ~= nil,

	pauseFoldsOnSearch = true,

	-- incompatible with `nvim-ufo`
	foldtextWithLineCount = {
		enabled = package.loaded["ufo"] == nil,
		template = "   %s lines", -- `%s` gets the number of folded lines
	},

	foldKeymaps = {
		setup = true, -- modifies `h` and `l`
		hOnlyOpensOnFirstColumn = false,
	},

	-- incompatible with `nvim-ufo`
	autoFold = {
		enabled = false,
		kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
	},
}
M.config = defaultConfig

--------------------------------------------------------------------------------

---@param userConfig? Origami.config
function M.setup(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})

	if M.config.keepFoldsAcrossSessions then require("origami.keepFoldsAcrossSessions") end
	if M.config.pauseFoldsOnSearch then require("origami.pause-folds-on-search") end
	if M.config.foldtextWithLineCount.enabled then require("origami.foldtext-with-linecount") end
	if M.config.autoFold.enabled then require("origami.autofold-comments-imports") end

	-- DEPRECATION (2025-03-30)
	---@diagnostic disable: undefined-field
	local u = require("origami.utils")
	if M.config.setupFoldKeymaps then
		u.warn("nvim-origami config `setupFoldKeymaps` was moved to `foldKeymaps.setup`.")
		M.config.foldKeymaps.setup = M.config.setupFoldKeymaps
	end
	if M.config.hOnlyOpensOnFirstColumn then
		u.warn(
			"nvim-origami config `hOnlyOpensOnFirstColumn` was moved to `foldKeymaps.hOnlyOpensOnFirstColumn`."
		)
		M.config.foldKeymaps.hOnlyOpensOnFirstColumn = M.config.hOnlyOpensOnFirstColumn
	end
	---@diagnostic enable: undefined-field

	if M.config.foldKeymaps.setup then
		vim.keymap.set(
			"n",
			"h",
			function() require("origami.fold-keymaps").h() end,
			{ desc = "Origami h" }
		)
		vim.keymap.set(
			"n",
			"l",
			function() require("origami.fold-keymaps").l() end,
			{ desc = "Origami l" }
		)
	end
end

--------------------------------------------------------------------------------
return M
