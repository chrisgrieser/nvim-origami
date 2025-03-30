if not package.loaded["ufo"] then
	require("origami.utils").warn("nvim-origami's `keepFoldsAcrossSessions` requires `nvim-ufo`.")
	return
end
--------------------------------------------------------------------------------

local VIEW_SLOT = 1

local function remember(mode)
	if vim.bo.buftype ~= "" or not vim.bo.modifiable then return end

	if mode == "save" then
		-- only save folds and cursor, do not save options or the cwd, as that
		-- leads to unpredictable behavior
		local viewOptsBefore = vim.opt.viewoptions:get()
		vim.opt.viewoptions = { "cursor", "folds" }
		pcall(vim.cmd.mkview, VIEW_SLOT) -- pcall for edge cases like #11
		vim.opt.viewoptions = viewOptsBefore
	else
		pcall(vim.cmd.loadview, VIEW_SLOT) -- pcall, since new files have no viewfile
	end
end

--------------------------------------------------------------------------------

local group = vim.api.nvim_create_augroup("origami-keep-folds", { clear = true })

vim.api.nvim_create_autocmd("BufWinLeave", {
	pattern = "?*",
	desc = "Origami: save folds",
	callback = function() remember("save") end,
	group = group,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "?*",
	desc = "Origami: load folds",
	callback = function() remember("load") end,
	group = group,
})
remember("load") -- initialize in current buffer in case of lazy loading
