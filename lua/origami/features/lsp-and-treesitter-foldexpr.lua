local group = vim.api.nvim_create_augroup("origami.foldexpr", { clear = true })
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Origami: Use LSP as folding provider if client supports it",
	group = group,
	callback = function(ctx)
		if vim.o.diff then return end -- not in diff mode, see #30

		local client = assert(vim.lsp.get_client_by_id(ctx.data.client_id))
		if client:supports_method("textDocument/foldingRange") then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldmethod = "expr"
			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
			vim.b.origami_folding_provider = "lsp"
		end
	end,
})

--------------------------------------------------------------------------------

---@param filetype? string
local function checkForTreesitter(filetype)
	if vim.b.origami_folding_provider == "lsp" then return end
	if vim.o.diff then return end -- not in diff mode, see #30

	if not filetype then filetype = vim.bo.filetype end
	local win = vim.api.nvim_get_current_win()

	local ok, hasParser = pcall(vim.treesitter.query.get, filetype, "folds")

	if ok and hasParser then
		vim.wo[win][0].foldmethod = "expr"
		vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.b.origami_folding_provider = "treesitter"
	else
		vim.wo[win][0].foldmethod = "indent"
		vim.wo[win][0].foldexpr = ""
		vim.b.origami_folding_provider = "indent"
	end
end

vim.api.nvim_create_autocmd("FileType", {
	desc = "Origami: Use Treesitter as folding provider if there is a parser for it",
	group = group,
	callback = function(ctx) checkForTreesitter(ctx.match) end,
})
checkForTreesitter() -- initialize in case of lazy-loading
