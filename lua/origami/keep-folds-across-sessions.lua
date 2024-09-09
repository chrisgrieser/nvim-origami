local ignoredFts = {
	"TelescopePrompt",
	"DressingSelect",
	"DressingInput",
	"toggleterm",
	"gitcommit",
	"gitrebase",
	"replacer",
	"rip-substitute",
	"harpoon",
	"help",
	"checkhealth",
	"qf",
}
local viewSlot = 1

local function remember(mode)
	if vim.tbl_contains(ignoredFts, vim.bo.ft) or vim.bo.buftype ~= "" or not vim.bo.modifiable then
		return
	end

	if mode == "save" then
		-- only save folds and cursor, do not save options or the cwd, as that
		-- leads to unpredictable behavior
		local viewOptsBefore = vim.opt.viewoptions:get()
		vim.opt.viewoptions = { "cursor", "folds" }
		vim.cmd.mkview(viewSlot)
		vim.opt.viewoptions = viewOptsBefore
	else
		pcall(vim.cmd.loadview, viewSlot) -- pcall, since new files have no viewfile
	end
end

--------------------------------------------------------------------------------

local group = vim.api.nvim_create_augroup("origami-keep-folds", { clear = true })

vim.api.nvim_create_autocmd("BufWinLeave", {
	pattern = "?*",
	callback = function() remember("save") end,
	group = group,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "?*",
	callback = function() remember("load") end,
	group = group,
})
remember("load") -- initialize in current buffer in case of lazy loading
