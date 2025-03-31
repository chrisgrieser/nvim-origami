local M = {}
--------------------------------------------------------------------------------

---@param msg string
function M.warn(msg)
	vim.notify(msg, vim.log.levels.WARN, { title = "nvim-origami", ft = "markdown" })
end

--------------------------------------------------------------------------------
return M
