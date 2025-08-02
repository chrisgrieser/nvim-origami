--------------------------------------------------------------------------------
local group = vim.api.nvim_create_augroup("origami.foldexpr", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Origami: Use LSP as folding provider if client supports it",
	group = group,
	callback = function(ctx)
		local client = assert(vim.lsp.get_client_by_id(ctx.data.client_id))
		if client:supports_method("textDocument/foldingRange") then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldmethod = "expr"
			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
			vim.b.origami_folding_provider = "lsp"
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Origami: Use Treesitter as folding provider if there is a parser for it",
	group = group,
	callback = function(ctx)
		if vim.b.origami_folding_provider == "lsp" then return end
		local win = vim.api.nvim_get_current_win()
		local filetype = ctx.match

		local hasParser = false
		-- безопасно обернуть в pcall, чтобы избежать краша
		local ok, _ = pcall(function()
			hasParser = vim.treesitter.query.get(filetype, "folds") ~= nil
		end)

		if ok and hasParser then
			vim.wo[win][0].foldmethod = "expr"
			vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.b.origami_folding_provider = "treesitter"
		else
			vim.wo[win][0].foldmethod = "indent"
			vim.wo[win][0].foldexpr = ""
			vim.b.origami_folding_provider = "indent"
		end
	end,
})
