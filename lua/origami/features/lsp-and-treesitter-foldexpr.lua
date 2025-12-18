local group = vim.api.nvim_create_augroup("origami.foldexpr", { clear = true })
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Origami: Use LSP as folding provider if client supports it",
	group = group,
	callback = function(ctx)
		local win = vim.api.nvim_get_current_win()
		if vim.wo[win].diff then return end -- not in diff mode, see #30

		local client = vim.lsp.get_clients({ bufnr = ctx.buf, id = ctx.data.client_id })[1]
		if not (client and client:supports_method("textDocument/foldingRange")) then return end
		vim.wo[win][0].foldmethod = "expr"
		vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		vim.b[ctx.buf].origami_folding_provider = "lsp"
	end,
})

--------------------------------------------------------------------------------

---@param filetype? string
---@param bufnr? number
local function checkForTreesitter(filetype, bufnr)
	if not bufnr then bufnr = 0 end
	if not filetype then filetype = vim.bo[bufnr].filetype end

	if vim.b[bufnr].origami_folding_provider == "lsp" then return end

	local win = vim.api.nvim_get_current_win()
	if vim.wo[win].diff then return end -- not in diff mode, see #30

	local ok, hasParser = pcall(vim.treesitter.query.get, filetype, "folds")
	if ok and hasParser then
		vim.wo[win][0].foldmethod = "expr"
		vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.b[bufnr].origami_folding_provider = "treesitter"
	else
		vim.wo[win][0].foldmethod = "indent"
		vim.wo[win][0].foldexpr = ""
		vim.b[bufnr].origami_folding_provider = "indent"
	end
end

vim.api.nvim_create_autocmd("FileType", {
	desc = "Origami: Use Treesitter as folding provider if there is a parser for it",
	group = group,
	callback = function(ctx) checkForTreesitter(ctx.match, ctx.buf) end,
})
checkForTreesitter() -- initialize in case of lazy-loading
