local M = {}
--------------------------------------------------------------------------------

---@class Origami.config
local defaultConfig = {
	-- features incompatible with `nvim-ufo`
	useLspFoldsWithTreesitterFallback = not package.loaded["ufo"],
	autoFold = {
		enabled = false,
		kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
	},
	foldtextWithLineCount = {
		enabled = not package.loaded["ufo"],
		template = "   %s lines", -- `%s` gets the number of folded lines
		hlgroupForCount = "Comment",
	},

	-- can be used with or without `nvim-ufo`
	pauseFoldsOnSearch = true,
	foldKeymaps = {
		setup = true, -- modifies `h` and `l`
		hOnlyOpensOnFirstColumn = false,
	},

	-- features requiring `nvim-ufo`
	keepFoldsAcrossSessions = package.loaded["ufo"],
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
	if M.config.useLspFoldsWithTreesitterFallback then
		require("origami.features.lsp-and-treesitter-foldexpr")
	end

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
