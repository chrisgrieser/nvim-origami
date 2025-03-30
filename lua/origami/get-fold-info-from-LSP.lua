-- INFO This is just kept for reference, in case this is used for something in
-- the future
--------------------------------------------------------------------------------

local bufnr = 0

local foldingLsp = vim.lsp.get_clients({ buffer = bufnr, method = "textDocument/foldingRange" })[1]
if not foldingLsp then return end

local params = { textDocument = { uri = vim.uri_from_bufnr(bufnr) } }
foldingLsp:request("textDocument/foldingRange", params, function(err, result, _)
	if err then
		local msg = ("Failed to get folding ranges from %s: %s"):format(foldingLsp.name, err)
		vim.notify(msg, vim.log.levels.ERROR)
		return
	end
	vim.notify(vim.inspect(result))
end)
