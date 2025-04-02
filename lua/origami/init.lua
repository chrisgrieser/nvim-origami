local M = {}
--------------------------------------------------------------------------------

---@param userConfig? Origami.config
function M.setup(userConfig) require("origami.config").setup(userConfig) end

-- make keymaps accessible from `require("origami")` for easier remapping
function M.l() require("origami.features.fold-keymaps").l() end
function M.h() require("origami.features.fold-keymaps").h() end

---@param type "special"|"all"?
function M.inspectLspFolds(type) require("origami.features.inspect-folds").inspectLspFolds(type) end

--------------------------------------------------------------------------------
return M
