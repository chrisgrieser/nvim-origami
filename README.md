<!-- LTeX: enabled=false -->
# nvim-origami 🐦📄
<!-- LTeX: enabled=true -->
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-origami">
<img alt="badge" src="https://dotfyle.com/plugins/chrisgrieser/nvim-origami/shield"/></a>

*Fold with relentless elegance.*

A collection of Quality-of-life features related to folding.

<img alt="Showcase" width=60% src="https://github.com/user-attachments/assets/bb13ee0f-7485-4e3f-b303-880b9d4d656e">

## Table of Content

<!-- toc -->

- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [FAQ](#faq)
	* [Folds are still opened](#folds-are-still-opened)
	* [Debug folding issues](#debug-folding-issues)
- [Credits](#credits)
- [About the developer](#about-the-developer)

<!-- tocstop -->

## Features
1. Remember folds across sessions. `requires nvim-ufo`
2. Pause folds while searching, restore folds when done with searching.
   (Normally, folds are opened when you search for text inside them, and *stay*
   open afterward.)
3. Add line count to the `foldtext`, preserving the syntax highlighting of the
   line (requires Treesitter parser for the language). `incompatible with
   nvim-ufo`
4. Overload the `h` key which will fold a line when used one the first non-blank
   character of (or before). And overload the `l` key, which will unfold a line
   when used on a folded line.[^1] This allows you to ditch `zc`, `zo`, and
   `za`, `h` and `l` are all you need.
5. Automatically fold comments and/or imports. Requires `vim.lsp.foldexpr` from
   nvim 0.11. `incompatible with nvim-ufo`

> [!NOTE]
> This plugin does **not** provide a `foldmethod`. For this plugin to work, you
> either have to [set one of on your
> own](https://www.reddit.com/r/neovim/comments/1jmqd7t/sorry_ufo_these_7_lines_replaced_you/),
> or use plugin providing folding information, such as
> [nvim-ufo](http://github.com/kevinhwang91/nvim-ufo).

## Installation

```lua
-- lazy.nvim
{
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	opts = {}, -- needed even when using default config
},

-- packer
use {
	"chrisgrieser/nvim-origami",
	config = function() require("origami").setup({}) end, -- setup call needed
}
```

## Configuration

```lua
-- default settings
require("origami").setup {
	-- requires with `nvim-ufo`
	keepFoldsAcrossSessions = package.loaded["ufo"] ~= nil,

	pauseFoldsOnSearch = true,

	-- incompatible with `nvim-ufo`
	foldtextWithLineCount = {
		enabled = package.loaded["ufo"] == nil,
		template = "   %s lines", -- `%s` gets the number of folded lines
		hlgroupForCount = "Comment",
	},

	foldKeymaps = {
		setup = true, -- modifies `h` and `l`
		hOnlyOpensOnFirstColumn = false,
	},

	-- redundant with `nvim-ufo`
	autoFold = {
		enabled = false,
		kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
	},
}
```

If you use other keys than `h` and `l` for vertical movement, set
`setupFoldKeymaps = false` and map the keys yourself:

```lua
vim.keymap.set("n", "<Left>", function() require("origami").h() end)
vim.keymap.set("n", "<Right>", function() require("origami").l() end)
```

## FAQ

### Folds are still opened
[Many formatting plugins open all your
folds](https://www.reddit.com/r/neovim/comments/164gg5v/preserve_folds_when_formatting/)
and unfortunately, there is nothing this plugin can do about it. The only two
tools I am aware of that are able to preserve folds are the
[efm-language-server](https://github.com/mattn/efm-langserver) and
[conform.nvim](https://github.com/stevearc/conform.nvim).

### Debug folding issues

```lua
-- Folds provided by the LSP
require("origami").inspectLspFolds("special") -- comment & import only
require("origami").inspectLspFolds("all")
```

## Credits
- [@magnusriga](https://github.com/neovim/neovim/pull/27217#issuecomment-2631614344)
  for a more performant implementation of fold text with highlighting.

## About the developer
In my day job, I am a sociologist studying the social mechanisms underlying the
digital economy. For my PhD project, I investigate the governance of the app
economy and how software ecosystems manage the tension between innovation and
compatibility. If you are interested in this subject, feel free to get in touch.

I also occasionally blog about vim: [Nano Tips for Vim](https://nanotipsforvim.prose.sh)

- [Website](https://chris-grieser.de/)
- [Mastodon](https://pkm.social/@pseudometa)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img height='36'
style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

[^1]: Technically, unfolding with `l` is already a built-in vim feature when
	`vim.opt.foldopen` includes `hor`. However, this plugin still sets up a `l`
	key replicating that behavior, since the built-in version still moves you to
	one character to the side, which can be considered a bit counterintuitive.
