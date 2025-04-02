local M = {}
--------------------------------------------------------------------------------

---@param msg string
function M.warn(msg) vim.notify(msg, vim.log.levels.WARN, { title = "origami", icon = "" }) end

function M.info(msg) vim.notify(msg, nil, { title = "origami", icon = "" }) end

--------------------------------------------------------------------------------
return M
