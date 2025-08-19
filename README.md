# nvim-origami 🐦📄
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-origami">
<img alt="badge" src="https://dotfyle.com/plugins/chrisgrieser/nvim-origami/shield"/></a>

A collection of quality-of-life features related to folding.

<img alt="Showcase" width=75% src="https://github.com/user-attachments/assets/64da0d38-c220-44e3-ac50-20f9df835c8a">

## Features
- Use the **LSP to provide folds**, with Treesitter as fallback if the LSP does
  not provide folding information (and indent-based folding as fallback if
  neither is available).
- **Fold-text decorations**: Displays the number of lines, diagnostics, and
  changes in the fold, while preserving the syntax highlighting of the line
  (displaying git changes requires
  [gitsigns.nvim](http://github.com/lewis6991/gitsigns.nvim)).
- **Overload `h` and `l` as fold keymaps**: the `h` key will fold a line when
  used on the first non-blank character (or before). The `l` key will unfold a
  line when used on a folded line. This allows you to ditch `zc`, `zo`, and
  `za`; `h` and `l` are all you need.
- **Auto-fold**: Automatically fold comments and/or imports when opening a file
  (requires an LSP that provides that information).
- **Pause folds while searching**, and restore folds when done with searching.
  (Normally, folds are opened when you search for text inside them and stay open
  afterward.)

All features are independent, so you can choose to only enable some of them.

`nvim-origami` replaces most features of `nvim-ufo` in a much more lightweight
manner and adds some features that `nvim-ufo` does not provide.

## Table of Content

<!-- toc -->

- [Breaking changes in v2.0](#breaking-changes-in-v20)
- [Installation](#installation)
- [Configuration](#configuration)
- [FAQ](#faq)
	+ [Error when opening or reloading a file](#error-when-opening-or-reloading-a-file)
	+ [Folds are opened after running a formatter](#folds-are-opened-after-running-a-formatter)
	+ [Debug folding issues](#debug-folding-issues)
- [Credits](#credits)
- [About the developer](#about-the-developer)

<!-- tocstop -->

## Breaking changes in v2.0
- nvim 0.11 is now required.
- `nvim-ufo` is ****no longer compatible**** with this plugin (most of its
  features are now offered by `nvim-origami` in a more lightweight way).
- [Saving folds across sessions is no longer supported.](https://github.com/chrisgrieser/nvim-origami/issues/21)
- If you do not like the changes, you can pin `nvim-origami` to the tag `v1.9`.

## Installation
**Requirements**
- nvim 0.11+
- **not** using `nvim-ufo`, since `nvim-origami` is incompatible with it

```lua
-- lazy.nvim
{
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	opts = {}, -- needed even when using default config

	-- recommended: disable vim's auto-folding
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
	end,
},
```

## Configuration

```lua
-- default settings
require("origami").setup {
	useLspFoldsWithTreesitterFallback = true,
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
	},
	autoFold = {
		enabled = true,
		kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
	},
	foldKeymaps = {
		setup = true, -- modifies `h` and `l`
		hOnlyOpensOnFirstColumn = false,
	},
}
```

If you use other keys than `h` and `l` for vertical movement, set
`opts.foldKeymaps.setup = false` and map the keys yourself:

```lua
vim.keymap.set("n", "<Left>", function() require("origami").h() end)
vim.keymap.set("n", "<Right>", function() require("origami").l() end)
```

## FAQ

### Error when opening or reloading a file

```txt
Error executing vim.schedule lua callback: ...0.11.2/share/nvim/runtime/lua/vim/lsp/_folding_range.lua:311: attempt to index a nil value
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
require("origami").inspectLspFolds("special") -- comment & import only
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

<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img height='36'
style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
