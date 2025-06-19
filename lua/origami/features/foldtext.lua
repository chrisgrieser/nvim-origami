if package.loaded["ufo"] then
	require("origami.utils").warn(
		"nvim-origami's `foldtextWithLineCount` cannot be used at the same time as `nvim-ufo`."
	)
	return
end
--------------------------------------------------------------------------------

vim.opt.foldtext = "" -- keep syntax highlighting
vim.opt.fillchars:append { fold = " " } -- text after end of foldtext

-- decoration approach using solution from https://www.reddit.com/r/neovim/comments/1le6l6x/add_decoration_to_the_folded_lines/
local ns = vim.api.nvim_create_namespace("origami.foldTextNs")

local config = require("origami.config").config

-- get diagnostic config from user
local signConfig = vim.diagnostic.config().signs
local diagIcons = { "E", "W", "I", "H" }
local diagHls = { "DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint" }
if signConfig then
	diagIcons = vim.diagnostic.config().signs.text or diagIcons
	diagHls = vim.diagnostic.config().signs.linehl or diagHls
end

--------------------------------------------------------------------------------

---@param buf number
---@param foldstart number
---@param foldend number
---@return table? chunks
local function getDiagnosticsInFold(buf, foldstart, foldend)
	if not config.foldtext.diagnostics.enabled then return end

	local diagCounts = {}
	for lnum = foldstart - 1, foldend - 1 do
		for severity, value in pairs(vim.diagnostic.count(buf, { lnum = lnum })) do
			diagCounts[severity] = value + (diagCounts[severity] or 0)
		end
	end

	local chunks = {}
	for severity = vim.diagnostic.severity.ERROR, vim.diagnostic.severity.HINT do
		if diagCounts[severity] then
			table.insert(chunks, {
				("%s %d "):format(diagIcons[severity], diagCounts[severity]),
				{ diagHls[severity] },
			})
		end
	end

	return chunks
end

---@param win number
---@param buf number
---@param foldstart number
---@return integer
local function renderFoldedSegments(win, buf, foldstart)
	local foldend = vim.fn.foldclosedend(foldstart)

	local lineCountText = config.foldtext.lineCount.template:format(foldend - foldstart)
	local diagnostics = getDiagnosticsInFold(buf, foldstart, foldend)
	local virtText = {
		{ lineCountText, { config.foldtext.lineCount.hlgroup } },
		{ " " },
		diagnostics and unpack(diagnostics) or nil,
	}

	local line = vim.api.nvim_buf_get_lines(buf, foldstart - 1, foldstart, false)[1]
	local wininfo = vim.fn.getwininfo(win)[1]
	local leftcol = wininfo and wininfo.leftcol or 0 ---@diagnostic disable-line: undefined-field
	local wincol = math.max(0, vim.fn.virtcol { foldstart, line:len() } - leftcol)

	vim.api.nvim_buf_set_extmark(buf, ns, foldstart - 1, 0, {
		virt_text = virtText,
		virt_text_win_col = wincol,
		hl_mode = "combine",
		ephemeral = true, -- only for decorators in a redraw cycle
	})

	return foldend
end

vim.api.nvim_set_decoration_provider(ns, {
	on_win = function(_, win, buf, topline, botline)
		vim.api.nvim_win_call(win, function()
			local line = topline
			while line <= botline do
				local foldstart = vim.fn.foldclosed(line)
				if foldstart > -1 then line = renderFoldedSegments(win, buf, foldstart) end
				line = line + 1
			end
		end)
	end,
})

--------------------------------------------------------------------------------
