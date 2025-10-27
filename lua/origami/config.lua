local M = {}
local warn = require("origami.utils").warn
--------------------------------------------------------------------------------

---@class Origami.config
local defaultConfig = {
	useLspFoldsWithTreesitterFallback = true,
	pauseFoldsOnSearch = true,
	foldtext = {
		enabled = true,
		padding = 3,
		lineCount = {
		   ---@type string | fun():string
			template = "%d lines", -- `%d` is replaced with the number of folded lines
			hlgroup = "Comment",
		},
		---@type boolean | fun():boolean
		diagnosticsCount = true, -- uses hlgroups and icons from `vim.diagnostic.config().signs`
		---@type boolean | fun():boolean
		gitsignsCount = true, -- requires `gitsigns.nvim`
		disableOnFt = { "snacks_picker_input" }, ---@type string[]
	},
	autoFold = {
		enabled = true,
		kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
	},
	foldKeymaps = {
		setup = true, -- modifies `h` and `l`
		hOnlyOpensOnFirstColumn = false,
	},
}
M.config = defaultConfig

--------------------------------------------------------------------------------

---@param userConfig? Origami.config
function M.setup(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})

	-----------------------------------------------------------------------------
	---@diagnostic disable: undefined-field
	-- DEPRECATION (2025-03-30)
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

	-- DEPRECATION (2025-06-19)
	if M.config.foldtextWithLineCount then
		warn(
			"nvim-origami config `foldtextWithLineCount` is outdated. Use `foldtext`, but and note its changes in the README."
		)
	end
	if M.config.keepFoldsAcrossSessions then
		warn(
			"nvim-origami config `keepFoldsAcrossSessions` is deprecated. Pin tag `v1.9` if you want to keep on using it."
		)
	end
	---@diagnostic enable: undefined-field
	-----------------------------------------------------------------------------

	if M.config.pauseFoldsOnSearch then require("origami.features.pause-folds-on-search") end
	if M.config.foldtext.enabled then require("origami.features.foldtext") end
	if M.config.autoFold.enabled then require("origami.features.autofold-comments-imports") end
	if M.config.useLspFoldsWithTreesitterFallback then
		require("origami.features.lsp-and-treesitter-foldexpr")
	end
	if M.config.foldKeymaps.setup then require("origami.features.fold-keymaps").setupKeymaps() end
end

--------------------------------------------------------------------------------
return M
