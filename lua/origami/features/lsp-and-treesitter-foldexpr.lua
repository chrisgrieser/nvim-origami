---@param bufnr? number defaults to 0 for the current buffer
---@param clientId? number|nil nil for any
local function checkForLsp(bufnr, clientId)
	if not bufnr then bufnr = 0 end
	local win = vim.api.nvim_get_current_win()
	if vim.wo[win].diff then return end -- not in diff mode, see #30

	local foldingClients =
		vim.lsp.get_clients { bufnr = bufnr, id = clientId, method = "textDocument/foldingRange" }
	if #foldingClients == 0 then return end
	vim.api.nvim_buf_call(bufnr, function()
		vim.wo[win][0].foldmethod = "expr"
		vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		vim.b[bufnr].origami_folding_provider = "lsp"
	end)
end

---@param bufnr? number defaults to 0 for the current buffer
---@param filetype? string
local function checkForTreesitterWithFallback(bufnr, filetype)
	if not bufnr then bufnr = 0 end
	-- always prioritize treesitter parser over LSP for folding
	if vim.b[bufnr].origami_folding_provider == "lsp" then return end
	local win = vim.api.nvim_get_current_win()
	if vim.wo[win].diff then return end -- not in diff mode, see #30

	if not filetype then filetype = vim.bo[bufnr].filetype end
	local ok, hasParser = pcall(vim.treesitter.query.get, filetype, "folds")
	vim.api.nvim_buf_call(bufnr, function()
		if ok and hasParser then
			vim.wo[win][0].foldmethod = "expr"
			vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.b[bufnr].origami_folding_provider = "treesitter"
		else
			local fallback =
				require("origami.config").config.useLspFoldsWithTreesitterFallback.foldmethodIfNeitherIsAvailable
			if type(fallback) == "function" then fallback = fallback(bufnr) end
			vim.wo[win][0].foldmethod = fallback
			vim.wo[win][0].foldexpr = ""
			vim.b[bufnr].origami_folding_provider = fallback
		end
	end)
end

--------------------------------------------------------------------------------

local group = vim.api.nvim_create_augroup("origami.foldexpr", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Origami: Use LSP as folding provider if client supports it",
	group = group,
	callback = function(ctx) checkForLsp(ctx.buf, ctx.data.client_id) end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Origami: Use Treesitter as folding provider if there is a parser for it",
	group = group,
	callback = function(ctx) checkForTreesitterWithFallback(ctx.buf, ctx.match) end,
})

-- initialize on the existing buffer in case of lazy-loading
local listedBufs = vim.fn.getbufinfo { buflisted = 1 }
for _, buf in ipairs(listedBufs) do
	checkForLsp(buf.bufnr)
	checkForTreesitterWithFallback(buf.bufnr)
end
