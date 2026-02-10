# nvim-origami 🐦📄 <!-- rumdl-disable-line MD063 -->
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-origami">
<img alt="badge" src="https://dotfyle.com/plugins/chrisgrieser/nvim-origami/shield"/></a>

Fold with relentless elegance. A collection of quality-of-life features related
to folding.

<img alt="Showcase" width=75% src="https://github.com/user-attachments/assets/64da0d38-c220-44e3-ac50-20f9df835c8a">

## Features
- Use the **LSP to provide folds**, with Treesitter as fallback if the LSP does
  not provide folding information. (And indent-based folding if neither is
  available.)
- **Fold-text decorations**: Display the number of lines, diagnostics, and git
  changes in the fold, while preserving syntax highlighting. (Displaying git
  changes requires [gitsigns.nvim](http://github.com/lewis6991/gitsigns.nvim).)
- **Overload `h`, `l`, `^`, and `$` as fold keymaps**:
    - `h` folds a line when used on the first non-blank character or before and
      behaves as regular `h` otherwise.
    - `l` unfolds the cursorline when used on a folded line and behaves as
      regular `l` otherwise.
    - `^` and `$` work the same as `h` and `l`, except that they fold/unfold
      *recursively*.
    - This allows you to ditch `zc`, `zo`, `za`, `zC`, and `zO`, since you only
      need `h`, `l`, `^`, `$`.
- **Auto-fold**: Automatically fold comments and/or imports when opening a file.
  (Requires that the folding information is provided by an LSP.)
- **Pause folds while searching**, restore them when done.
  (Normally, folds are opened when you search for text inside them and stay open
  afterward.)

All features are independent of each other, so you can freely choose to only
enable the ones you want.

`nvim-origami` replaces most features of `nvim-ufo` in a much more lightweight
manner and adds some features of its own.

## Table of contents

<!-- toc -->

- [Installation](#installation)
- [Configuration](#configuration)
- [FAQ](#faq)
    - [Error when opening a file](#error-when-opening-a-file)
    - [Folds are opened after running a formatter](#folds-are-opened-after-running-a-formatter)
    - [Debug folding issues](#debug-folding-issues)
- [Credits](#credits)
- [About the developer](#about-the-developer)

<!-- tocstop -->

## Installation
**Requirements** <!-- rumdl-disable MD033 -->
- nvim 0.11+
- **not** using `nvim-ufo`, since `nvim-origami` is incompatible with it

```lua
-- lazy.nvim
{
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	opts = {}, -- required even when using default config

	-- recommended: disable vim's auto-folding
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
	end,
},
```

## Configuration
The `.setup` call is required.

```lua
-- default settings
require("origami").setup {
	useLspFoldsWithTreesitterFallback = {
		enabled = true,
		foldmethodIfNeitherIsAvailable = "indent", ---@type string|fun(bufnr: number): string
	},
	pauseFoldsOnSearch = true,
	foldtext = {
		enabled = true,
		padding = 3,
		lineCount = {
			template = "%d lines", -- `%d` is replaced with the number of folded lines
			hlgroup = "Comment",
		},
		diagnosticsCount = true, -- uses hlgroups and icons from `vim.diagnostic.config().signs`
		gitsignsCount = true, -- requires `gitsigns.nvim`
		disableOnFt = { "snacks_picker_input" }, ---@type string[]
	},
	autoFold = {
		enabled = true,
		kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
	},
	foldKeymaps = {
		setup = true, -- modifies `h`, `l`, `^`, and `$`
		closeOnlyOnFirstColumn = false, -- `h` and `^` only fold in the 1st column
		scrollLeftOnCaret = false, -- `^` should scroll left (basically mapped to `0^`)
	},
}
```

If you use other keys than `h`, `l`, `^`, and `$` for horizontal movement, set
`opts.foldKeymaps.setup = false` and map them yourself:

```lua
vim.keymap.set("n", "<Left>", function() require("origami").h() end)
vim.keymap.set("n", "<Right>", function() require("origami").l() end)
vim.keymap.set("n", "<Home>", function() require("origami").caret() end)
vim.keymap.set("n", "<End>", function() require("origami").dollar() end)
```

## FAQ

### Error when opening a file

```txt
Error executing vim.schedule lua callback: 
...0.11.2/share/nvim/runtime/lua/vim/lsp/_folding_range.lua:311: attempt to index a nil value
```

This error occasionally occurs with `autoFold` enabled. It is, however, not
caused by `nvim-origami` but by a bug with `vim.lsp.foldclose()` in nvim core.
A future version of nvim will hopefully fix this.

### Folds are opened after running a formatter
[This is a known issue of many formatting
plugins](https://www.reddit.com/r/neovim/comments/164gg5v/preserve_folds_when_formatting/)
and not related to `nvim-origami`.

The only two tools I am aware of that are able to preserve folds are the
[efm-language-server](https://github.com/mattn/efm-langserver) and
[conform.nvim](https://github.com/stevearc/conform.nvim).

### Debug folding issues
Debug issues with folds provided by the LSP:

```lua
require("origami").inspectLspFolds("special") -- comments & imports only
require("origami").inspectLspFolds("all")
```

## Credits
- [u/marjrohn](https://www.reddit.com/r/neovim/comments/1le6l6x/add_decoration_to_the_folded_lines/)
  for the decorator approach to styling foldtext.

## About the developer
In my day job, I am a sociologist studying the social mechanisms underlying the
digital economy. For my PhD project, I investigate the governance of the app
economy and how software ecosystems manage the tension between innovation and
compatibility. If you are interested in this subject, feel free to get in touch.

- [Website](https://chris-grieser.de/)
- [Mastodon](https://pkm.social/@pseudometa)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

If you find this project helpful, you can support me via [🩷 GitHub
Sponsors](https://github.com/sponsors/chrisgrieser?frequency=one-time).
