local M = {}
--------------------------------------------------------------------------------

---@param msg string
local function warn(msg)
	vim.notify(msg, vim.log.levels.WARN, { title = "nvim-origami", ft = "markdown" })
end

--------------------------------------------------------------------------------
return M
