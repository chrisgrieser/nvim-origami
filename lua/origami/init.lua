local M = {}
--------------------------------------------------------------------------------

---@param userConfig? Origami.config
function M.setup(userConfig) require("origami.config").setup(userConfig) end

-- make keymaps accessible from `require("origami")` for easier remapping
function M.l() require("origami.features.fold-keymaps").l() end
function M.h() require("origami.features.fold-keymaps").h() end

--------------------------------------------------------------------------------
return M
