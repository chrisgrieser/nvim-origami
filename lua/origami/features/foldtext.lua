if package.loaded["ufo"] then
	require("origami.utils").warn(
		"nvim-origami's `foldtextWithLineCount` cannot be used at the same time as `nvim-ufo`."
	)
	return
end
--------------------------------------------------------------------------------

-- based on https://www.reddit.com/r/neovim/comments/1fzn1zt/custom_fold_text_function_with_treesitter_syntax/
function _G.Origami__FoldtextWithLineCount()
	local start, end_ = vim.v.foldstart, vim.v.foldend
	local foldLine = vim.api.nvim_buf_get_lines(0, start - 1, start, false)[1]

	local result = {}
	local text, hl = "", nil
	for i = 1, #foldLine do
		local char = foldLine:sub(i, i)
		local captures = vim.treesitter.get_captures_at_pos(0, start - 1, i - 1)
		local lastCapture = captures[#captures]
		if lastCapture then
			local newHl = "@" .. lastCapture.capture
			if newHl ~= hl then
				table.insert(result, { text, hl })
				text, hl = "", nil
			end
			hl = newHl
		end
		text = text .. char
	end
	table.insert(result, { text, hl })

	local template = require("origami.config").config.foldtextWithLineCount.template
	local lineCountStr = template:format(end_ - start)
	table.insert(result, { lineCountStr, "Comment" })
	return result
end

--------------------------------------------------------------------------------
vim.opt.foldtext = "v:lua.Origami__FoldtextWithLineCount()"
