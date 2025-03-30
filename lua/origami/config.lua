local M = {}
--------------------------------------------------------------------------------

---@class Origami.config
local defaultConfig = {
	keepFoldsAcrossSessions = true,
	pauseFoldsOnSearch = true,
	foldtextWithLineCount = {
		enabled = false,
		template = "   %s lines", -- `%s` gets the number of folded lines
	},
	foldKeymaps = {
		setup = true, -- modifies `h` and `l`
		hOnlyOpensOnFirstColumn = false,
	},
}
M.config = defaultConfig

local function warn(msg)
	vim.notify(msg, vim.log.levels.WARN, { title = "nvim-origami", ft = "markdown" })
end

--------------------------------------------------------------------------------

---@param userConfig? Origami.config
function M.setup(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})

	if M.config.keepFoldsAcrossSessions then
		if not package.loaded["ufo"] then
			warn("nvim-origami's `keepFoldsAcrossSessions` requires `nvim-ufo`.")
			return
		end
		require("origami.keepFoldsAcrossSessions")
	end
	if M.config.pauseFoldsOnSearch then require("origami.pause-folds-on-search") end
	if M.config.foldtextWithLineCount.enabled then
		if package.loaded["ufo"] then
			warn(
				"nvim-origami's `foldtextWithLineCount` is not cannot be used at the same time as `nvim-ufo`."
			)
			return
		end
		require("origami.foldtext-with-linecount")
	end

	-- DEPRECATION (2025-03-30)
	---@diagnostic disable: undefined-field
	if M.config.setupFoldKeymaps then
		warn("nvim-origami config `setupFoldKeymaps` was moved to `foldKeymaps.setup`.")
		M.config.foldKeymaps.setup = M.config.setupFoldKeymaps
	end
	if M.config.hOnlyOpensOnFirstColumn then
		warn(
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
