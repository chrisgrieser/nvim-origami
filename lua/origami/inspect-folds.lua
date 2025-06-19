local M = {}
local u = require("origami.utils")
--------------------------------------------------------------------------------

---@param type "special"|"all"?
function M.inspectLspFolds(type)
	if not type then type = "all" end
	local bufnr = vim.api.nvim_get_current_buf()

	local foldingLsp =
		vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/foldingRange" })[1]
	if not foldingLsp then
		u.warn("No LSPs with folding support attached.")
		return
	end

	local params = { textDocument = { uri = vim.uri_from_bufnr(bufnr) } }
	foldingLsp:request("textDocument/foldingRange", params, function(err, result, _)
		if err or not result then
			local msg = ("[%s] Failed to get folding ranges. "):format(foldingLsp.name)
			if err then msg = msg .. err.message end
			u.warn(msg)
			return
		end
		local specialFolds = vim.iter(result)
			:filter(function(fold)
				if type == "all" then return true end
				return fold.kind ~= nil and fold.kind ~= "region"
			end)
			:map(function(fold)
				local range = fold.startLine + 1
				if fold.endLine > fold.startLine then range = range .. "-" .. (fold.endLine + 1) end
				return ("- %s %s"):format(range, fold.kind or "")
			end)
			:join("\n")

		if specialFolds == "" then
			u.info(("[%s] No special folds found."):format(foldingLsp.name))
		else
			local header = ("[%s: special folds]"):format(foldingLsp.name)
			u.info(header .. "\n" .. specialFolds)
		end
	end)
end

--------------------------------------------------------------------------------
return M
