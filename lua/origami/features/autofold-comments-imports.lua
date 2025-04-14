if package.loaded["ufo"] then
	require("origami.utils").warn(
		"nvim-origami's `foldtextWithLineCount` cannot be used at the same time as `nvim-ufo`."
	)
	return
end
if not vim.lsp.foldclose then return end -- only added in nvim 0.11
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("LspNotify", {
	desc = "Origami: Close imports and comments on load",
	group = vim.api.nvim_create_augroup("origami-autofolds", { clear = true }),
	callback = function(ctx)
		if ctx.data.method ~= "textDocument/didOpen" then return end
		-- not using `lsp.get_clients_by_id` to additionally check for the correct
		-- buffer (can change in quick events)
		local client = vim.lsp.get_clients({ bufnr = ctx.buf, id = ctx.data.client_id })[1]
		if not client then return end
		if not client:supports_method("textDocument/foldingRange") then return end

		local kinds = require("origami.config").config.autoFold.kinds
		for _, kind in ipairs(kinds) do
			pcall(vim.lsp.foldclose, kind, vim.fn.bufwinid(ctx.buf))
		end

		-- unfold under cursor
		vim.defer_fn(function() vim.cmd.normal { "zv", bang = true } end, 1)
	end,
})
