local version = vim.version()
if version.major == 0 and version.minor < 11 then
	vim.notify("`nvim-origami` requires at least nvim 0.11.", vim.log.levels.ERROR)
	return
end
if package.loaded["ufo"] then
	local msg = "v2.0 of `nvim-origami` is no longer compatible with `nvim-ufo`. "
		.. "Pin `nvim-origami` to tag `v1.9` if you want to keep using it with `nvim-ufo`."
	vim.notify(msg, vim.log.levels.ERROR)
	return
end
--------------------------------------------------------------------------------

local M = {}

---@param userConfig? Origami.config
function M.setup(userConfig) require("origami.config").setup(userConfig) end

--------------------------------------------------------------------------------

-- make these functions accessible from `require("origami")` for easier remapping
function M.h() require("origami.features.fold-keymaps").h() end
function M.l() require("origami.features.fold-keymaps").l() end
function M.dollar() require("origami.features.fold-keymaps").dollar() end

function M.inspectLspFolds(type) ---@param type "special"|"all"?
	require("origami.inspect-folds").inspectLspFolds(type)
end

--------------------------------------------------------------------------------
return M
