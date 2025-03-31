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
		hlgroupForCount = "Comment",
	},

	foldKeymaps = {
		setup = true, -- modifies `h` and `l`
		hOnlyOpensOnFirstColumn = false,
	},

	-- redundant with `nvim-ufo`
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

	if M.config.keepFoldsAcrossSessions then require("origami.features.remember-folds") end
	if M.config.pauseFoldsOnSearch then require("origami.features.pause-folds-on-search") end
	if M.config.foldtextWithLineCount.enabled then require("origami.features.foldtext") end
	if M.config.autoFold.enabled then require("origami.features.autofold-comments-imports") end

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
			function() require("origami.features.fold-keymaps").h() end,
			{ desc = "Origami h" }
		)
		vim.keymap.set(
			"n",
			"l",
			function() require("origami.features.fold-keymaps").l() end,
			{ desc = "Origami l" }
		)
	end
end

--------------------------------------------------------------------------------
return M
