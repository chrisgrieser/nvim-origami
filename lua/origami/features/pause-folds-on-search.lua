-- Disabling search in foldopen has the disadvantage of making search nearly
-- unusable. Enabling search in foldopen has the disadvantage of constantly
-- opening all your folds as soon as you search. This snippet fixes this by
-- pausing folds while searching, but restoring them when you are done
-- searching.
--------------------------------------------------------------------------------

-- disable auto-open when searching, since we take care of that in a better way
vim.opt.foldopen:remove { "search" }

local ns = vim.api.nvim_create_namespace("origami.autoPauseFolds")

vim.on_key(function(char)
	if vim.g.scrollview_refreshing then return end -- FIX https://github.com/dstein64/nvim-scrollview/issues/88#issuecomment-1570400161

	local key = vim.fn.keytrans(char)
	local isCmdlineSearch = vim.fn.getcmdtype():find("[/?]") ~= nil
	local isNormalMode = vim.api.nvim_get_mode().mode == "n"

	local searchStarted = (key == "/" or key == "?") and isNormalMode
	local searchConfirmed = (key == "<CR>" and isCmdlineSearch)
	if not (searchStarted or searchConfirmed or isNormalMode) then return end
	local foldsArePaused = not (vim.opt.foldenable:get())
	-- works for RHS, therefore no need to consider remaps
	local searchMovement = vim.tbl_contains({ "n", "N", "*", "#" }, key)
	local searchActivity = searchMovement or searchConfirmed or searchStarted

	if searchActivity and not foldsArePaused then
		vim.opt_local.foldenable = false
	elseif foldsArePaused and not searchActivity then
		vim.opt_local.foldenable = true
		pcall(vim.cmd.foldopen, { bang = true }) -- after closing folds, keep the *current* fold open
	end
end, ns)
