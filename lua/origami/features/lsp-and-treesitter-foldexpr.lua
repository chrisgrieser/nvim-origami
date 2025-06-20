vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- fallback

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Origami: Set LSP folding if client supports it",
	group = vim.api.nvim_create_augroup("origami.setupLspFolding", { clear = true }),
	callback = function(ctx)
		local client = assert(vim.lsp.get_client_by_id(ctx.data.client_id))
		if client:supports_method("textDocument/foldingRange") then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		end
	end,
})
