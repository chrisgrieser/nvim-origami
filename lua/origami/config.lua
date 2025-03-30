local M = {}
--------------------------------------------------------------------------------

---@class Origami.config
local defaultConfig = {
	keepFoldsAcrossSessions = true,
	pauseFoldsOnSearch = true,
	setupFoldKeymaps = true,

	-- `h` key opens on first column, not at first non-blank character or before
	hOnlyOpensOnFirstColumn = false,

	foldtextWithLineCount = {
		enabled = false,
		template = "   %s lines", -- `%s` gets the number of folded lines
	},
}
M.config = defaultConfig

---@param userConfig? Origami.config
function M.setup(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})

	if M.config.pauseFoldsOnSearch then require("origami.pause-folds-on-search") end
	if M.config.keepFoldsAcrossSessions then require("origami.keep-folds-across-sessions") end
	if M.config.foldtextWithLineCount.enabled then require("origami.foldtext-with-linecount") end

	if M.config.setupFoldKeymaps then
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
