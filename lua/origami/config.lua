local M = {}
local warn = require("origami.utils").warn
--------------------------------------------------------------------------------

---@class Origami.config
local defaultConfig = {
	useLspFoldsWithTreesitterFallback = {
		enabled = true,
		foldmethodIfNeitherIsAvailable = "indent", ---@type string|fun(bufnr: number): string
	},
	pauseFoldsOnSearch = true,
	foldtext = {
		enabled = true,
		padding = {
			character = " ",
			width = 3, ---@type number|fun(win: number, foldstart: number, currentVirtualTextLength: number): number
			hlgroup = nil,
		},
		lineCount = {
			template = "%d lines", -- `%d` is replaced with the number of folded lines
			hlgroup = "Comment",
		},
		diagnosticsCount = true, -- uses hlgroups and icons from `vim.diagnostic.config().signs`
		gitsignsCount = true, -- requires `gitsigns.nvim`
		disableOnFt = { "snacks_picker_input" }, ---@type string[]
	},
	autoFold = {
		enabled = true,
		kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
	},
	foldKeymaps = {
		setup = true, -- modifies `h`, `l`, `^`, and `$`
		closeOnlyOnFirstColumn = false, -- `h` and `^` only close in the 1st column
		scrollLeftOnCaret = false, -- `^` should scroll left (basically mapped to `0^`)
	},
}
M.config = defaultConfig

--------------------------------------------------------------------------------

---@param userConfig? Origami.config
function M.setup(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})

	-----------------------------------------------------------------------------
	---@diagnostic disable: undefined-field
	-- DEPRECATION (2025-06-19)
	if M.config.foldtextWithLineCount ~= nil then
		warn(
			"nvim-origami config `foldtextWithLineCount` is outdated. Use `foldtext`, but note its changes in the README."
		)
	end
	if M.config.keepFoldsAcrossSessions ~= nil then
		warn(
			"nvim-origami config `keepFoldsAcrossSessions` is deprecated. Pin tag `v1.9` if you want to keep on using it."
		)
	end

	-- DEPRECATION (2025-12-07)
	if M.config.hOnlyOpensOnFirstColumn ~= nil then
		warn(
			"nvim-origami config `hOnlyOpensOnFirstColumn` was renamed to `foldKeymaps.closeOnlyOnFirstColumn`."
		)
		M.config.foldKeymaps.closeOnlyOnFirstColumn = M.config.hOnlyOpensOnFirstColumn
	end
	if M.config.hOnlyOpensOnFirstColumn ~= nil then
		warn(
			"nvim-origami config `foldKeymaps.hOnlyOpensOnFirstColumn` was renamed to `foldKeymaps.closeOnlyOnFirstColumn`."
		)
		M.config.foldKeymaps.closeOnlyOnFirstColumn = M.config.foldKeymaps.hOnlyOpensOnFirstColumn
	end

	-- DEPRECATION (2025-12-27)
	if type(M.config.useLspFoldsWithTreesitterFallback) == "boolean" then
		warn(
			"nvim-origami config `useLspFoldsWithTreesitterFallback` was renamed to `useLspFoldsWithTreesitterFallback.enabled`."
		)
		M.config.useLspFoldsWithTreesitterFallback.enabled =
			M.config.useLspFoldsWithTreesitterFallback
	end

	-- DEPRECATION (2026-03-06)
	if type(M.config.foldtext.padding) == "number" then
		warn("nvim-origami config `foldtext.padding` was renamed to `foldtext.padding.width`.")
		M.config.foldtext.padding = {
			character = " ",
			width = M.config.foldtext.padding,
			hlgroup = nil,
		}
	end
	---@diagnostic enable: undefined-field
	-----------------------------------------------------------------------------

	if M.config.pauseFoldsOnSearch then require("origami.features.pause-folds-on-search") end
	if M.config.foldtext.enabled then require("origami.features.foldtext") end
	if M.config.autoFold.enabled then require("origami.features.autofold-comments-imports") end
	if M.config.useLspFoldsWithTreesitterFallback.enabled then
		require("origami.features.lsp-and-treesitter-foldexpr")
	end
	if M.config.foldKeymaps.setup then require("origami.features.fold-keymaps").setupKeymaps() end
end

--------------------------------------------------------------------------------
return M
