local M = {}
--------------------------------------------------------------------------------

---@param userConfig? Origami.config
function M.setup(userConfig) require("origami.config").setup(userConfig) end

-- make keymaps accessible from `require("origami")`
function M.l() require("origami.fold-keymaps").l() end
function M.h() require("origami.fold-keymaps").h() end

--------------------------------------------------------------------------------
return M
