vim.opt.foldtext = "" -- keep syntax highlighting
vim.opt.fillchars:append { fold = " " } -- text after end of foldtext

local ns = vim.api.nvim_create_namespace("origami.foldText")

---@alias Origami.VirtTextChunk {[1]: string, [2]?: string[]}

---@alias Origami.FoldtextComponentProvider fun(buf: number, foldstart: number, foldend: number): Origami.VirtTextChunk[]

--------------------------------------------------------------------------------

---@type Origami.FoldtextComponentProvider
local function getDiagnosticsInFold(buf, foldstart, foldend)
	-- get config from `vim.diagnostic.config`
	local signConfig = vim.diagnostic.config().signs
	local diagIcons = { "E", "W", "I", "H" }
	local diagHls = { "DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint" }
	if type(signConfig) == "table" then
		diagIcons = vim.diagnostic.config().signs.text or diagIcons
		diagHls = vim.diagnostic.config().signs.linehl or diagHls
	end

	-- get count by severity in the folded lines
	local diagCountsInFold = {
		[vim.diagnostic.severity.ERROR] = 0,
		[vim.diagnostic.severity.WARN] = 0,
		[vim.diagnostic.severity.INFO] = 0,
		[vim.diagnostic.severity.HINT] = 0,
	}
	for lnum = foldstart - 1, foldend - 1 do
		local diagCountInLine = vim.diagnostic.count(buf, { lnum = lnum })
		for severity, count in pairs(diagCountInLine) do
			diagCountsInFold[severity] = diagCountsInFold[severity] + count
		end
	end

	-- convert count info into virtual text table for `set_extmark`
	local chunks = {} ---@type Origami.VirtTextChunk[]
	for severity = vim.diagnostic.severity.ERROR, vim.diagnostic.severity.HINT do
		if diagCountsInFold[severity] > 0 then
			table.insert(chunks, { " " }) -- separate, so the padding does not get hlgroup
			local text = diagIcons[severity] .. diagCountsInFold[severity]
			table.insert(chunks, { text, { diagHls[severity] } })
		end
	end
	return chunks
end

---@type Origami.FoldtextComponentProvider
local function getGitHunksInFold(buf, foldstart, foldend)
	local gitsignsInstalled, gitsigns = pcall(require, "gitsigns")
	if not gitsignsInstalled then return {} end

	local typeIcons = { change = "~", delete = "-", add = "+" }
	local typeHls = { change = "GitSignsChange", delete = "GitSignsDelete", add = "GitSignsAdd" }

	-- get count by type in the folded lines
	local hunksInFold = { change = 0, delete = 0, add = 0 }
	for _, h in pairs(gitsigns.get_hunks(buf) or {}) do
		local hunkStart = h.added.start -- SIC even for deletions, the correctly shifted line number is in `.added`
		local hunkEnd = hunkStart - 1 + (h.type == "delete" and h.removed.count or h.added.count)

		local overlapStart = math.max(foldstart + 1, hunkStart) -- +1 since first line of fold still visible
		local overlapEnd = math.min(foldend, hunkEnd)
		local overlapCount = overlapEnd - overlapStart + 1
		if overlapCount > 0 then hunksInFold[h.type] = hunksInFold[h.type] + overlapCount end
	end

	-- convert count info into virtual text table for `set_extmark`
	local chunks = {} ---@type Origami.VirtTextChunk[]
	for _, type in pairs { "add", "change", "delete" } do
		if hunksInFold[type] > 0 then
			table.insert(chunks, { " " }) -- separate, so the padding does not get hlgroup
			local text = typeIcons[type] .. hunksInFold[type]
			table.insert(chunks, { text, { typeHls[type] } })
		end
	end

	return chunks
end

--------------------------------------------------------------------------------

---@param win number
---@param buf number
---@param foldstart number
---@return number foldend
local function renderFoldedSegments(win, buf, foldstart)
	local config = require("origami.config").config
	local foldend = vim.fn.foldclosedend(foldstart)

	-- get virtual text components
	local lineCountText = config.foldtext.lineCount.template:format(foldend - foldstart)
	local virtText = { ---@type Origami.VirtTextChunk[]
		{ (" "):rep(config.foldtext.padding) },
		{ lineCountText, { config.foldtext.lineCount.hlgroup } },
	}
	if config.foldtext.diagnosticsCount then
		local diagnostics = getDiagnosticsInFold(buf, foldstart, foldend)
		if #diagnostics > 0 then table.insert(virtText, { " " }) end
		vim.list_extend(virtText, diagnostics)
	end
	if config.foldtext.gitsignsCount then
		local hunks = getGitHunksInFold(buf, foldstart, foldend)
		if #hunks > 0 then table.insert(virtText, { " " }) end
		vim.list_extend(virtText, hunks)
	end

	-- add text as extmark
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
