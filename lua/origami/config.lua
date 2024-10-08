local M = {}
--------------------------------------------------------------------------------

---@class Origami.config
local defaultConfig = {
	keepFoldsAcrossSessions = true,
	pauseFoldsOnSearch = true,
	setupFoldKeymaps = true,
	hOnlyOpensOnFirstColumn = false,
}
M.config = defaultConfig

---@param userConfig? Origami.config
function M.setup(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})

	if M.config.pauseFoldsOnSearch then require("origami.pause-folds-on-search") end
	if M.config.keepFoldsAcrossSessions then require("origami.keep-folds-across-sessions") end

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
