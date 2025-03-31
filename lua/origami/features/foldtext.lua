if package.loaded["ufo"] then
	require("origami.utils").warn(
		"nvim-origami's `foldtextWithLineCount` cannot be used at the same time as `nvim-ufo`."
	)
	return
end
--------------------------------------------------------------------------------

-- Credits for this function go to @magnusriga ([1], similar: [3]). As opposed
-- to other implementations that iterate every character of a folded line(e.g.,
-- [2]), this approach only iterates captures, making it more performant. (The
-- performance difference is already noticeable as soon as there are many closed
-- folds in a file.)
-- [1]: https://github.com/neovim/neovim/pull/27217#issuecomment-2631614344
-- [2]: https://www.reddit.com/r/neovim/comments/1fzn1zt/custom_fold_text_function_with_treesitter_syntax/
-- [3]: https://github.com/Wansmer/nvim-config/blob/6967fe34695972441d63173d5458a4be74a4ba42/lua/modules/foldtext.lua
---@return { text: string, hlgroup: string }[]|string
local function foldtextWithTreesitterHighlights()
	local foldStart = vim.v.foldstart
	local foldLine = vim.api.nvim_buf_get_lines(0, foldStart - 1, foldStart, false)[1]

	local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
	local parser = vim.treesitter.get_parser(0, lang)
	if not parser then return vim.fn.foldtext() end -- fallback

	-- Get `highlights` query for current buffer parser, as table from file,
	-- which gives information on highlights of tree nodes produced by parser.
	local query = vim.treesitter.query.get(parser:lang(), "highlights")
	if not query then return vim.fn.foldtext() end

	-- Partial TSTree for buffer, including root TSNode, and TSNodes of folded line.
	-- PERF Only parsing needed range, as parsing whole file would be slower.
	local tree = parser:parse({ foldStart - 1, foldStart })[1]

	local result = {}
	local linePos = 0
	local prevRange = { 0, 0 }

	-- Loop through matched "captures", i.e. node-to-capture-group pairs, for
	-- each TSNode in given range. Each TSNode could occur several times in list,
	-- i.e., map to several capture groups, and each capture group could be used
	-- by several TSNodes.
	for id, node, _ in query:iter_captures(tree:root(), 0, foldStart - 1, foldStart) do
		local captureName = query.captures[id]
		local text = vim.treesitter.get_node_text(node, 0)
		local _, startCol, _, endCol = node:range()

		-- include whitespace (part between captured TSNodes) with arbitrary hlgroup
		if startCol > linePos then
			table.insert(result, { foldLine:sub(linePos + 1, startCol), "Folded" })
		end
		-- Move `linePos` to end column of current node, so next loop iteration
		-- includes whitespace between TSNodes.
		linePos = endCol

		if not endCol or not startCol then break end

		-- Save code range current TSNode spans, so current TSNode can be ignored
		-- if next capture is for TSNode covering same section of source code.
		local range = { startCol, endCol }

		-- Use language specific highlight, if it exists.
		local highlight = "@" .. captureName
		local highlightLang = highlight .. "." .. lang
		if vim.fn.hlexists(highlightLang) then highlight = highlightLang end

		-- Accumulate text + hlgroup
		if range[1] == prevRange[1] and range[2] == prevRange[2] then
			-- Overwrite previous capture, as it was for same range from source code.
			result[#result] = { text, highlight }
		else
			-- Insert capture for TSNode covering new range of source code.
			table.insert(result, { text, highlight })
			prevRange = range
		end
	end

	return result
end

function _G.Origami__FoldtextWithLineCount()
	local foldtextChunks = foldtextWithTreesitterHighlights()
	-- GUARD `vim.fn.foldtext()` fallback already has count
	if type(foldtextChunks) == "string" then return foldtextChunks end

	local config = require("origami.config").config.foldtextWithLineCount
	local lineCountText = config.template:format(vim.v.foldend - vim.v.foldstart)

	table.insert(foldtextChunks, { lineCountText, config.hlgroupForCount })
	return foldtextChunks
end

--------------------------------------------------------------------------------
vim.opt.foldtext = "v:lua.Origami__FoldtextWithLineCount()"
vim.opt.fillchars:append { fold = " " } -- text after end of foldtext
