<!-- LTeX: enabled=false -->
# nvim-origami 🐦📄
<!-- LTeX: enabled=true -->
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-origami">
<img alt="badge" src="https://dotfyle.com/plugins/chrisgrieser/nvim-origami/shield"/></a>

*Fold with relentless elegance.* A collection of Quality-of-life features
related to folding.

<img alt="Showcase" width=75% src="https://github.com/user-attachments/assets/bb13ee0f-7485-4e3f-b303-880b9d4d656e">

## Table of Content

<!-- toc -->

- [Breaking changes in v2.0](#breaking-changes-in-v20)
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [FAQ](#faq)
	* [Folds are opened after running a formatter](#folds-are-opened-after-running-a-formatter)
	* [Debug folding issues](#debug-folding-issues)
- [Credits](#credits)
- [About the developer](#about-the-developer)

<!-- tocstop -->

## Breaking changes in v2.0
- nvim 0.11 is now required.
- `nvim-ufo` is now incompatible with this plugin (most of its features are now
offered by `nvim-origami` in a more lightweight way).
- Saving folds across sessions is no longer supported by this plugin.
- If you do not like the changes from v2.0, you can pin `nvim-origami` to `tag =
v1.9`.

## Features
- Use the **LSP to provide folds**, with Treesitter as fallback if the LSP does
not provide folding info.
- **Overload `h` and `l` as fold keymaps**: Overloads the `h` key which will
fold a line when used on the first non-blank character of (or before). And
overloads the `l` key, which will unfold a line when used on a folded line. This
allows you to ditch `zc`, `zo`, and `za`; `h` and `l` are all you need.
- **Auto-fold**: Automatically fold comments and/or imports when opening a file
(when using an LSP as folding provider).
- **Fold-text decorations**: Add line count and diagnostics to the `foldtext`,
preserving the syntax highlighting of the line.
- **Pause folds while searching**, restore folds when done with searching.
(Normally, folds are opened when you search for text inside them, and stay open
afterward.)

Every feature is independent, so you can choose to only use some of them.

`nvim-origami` replaces most features of `nvim-ufo` in a much more lightweight
and adds some features that `nvim-ufo` does not possess.

## Installation
**Requirements**
- nvim 0.11+
- **not** using `nvim-ufo`

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
	useLspFoldsWithTreesitterFallback = true, -- required for `autoFold`
	autoFold = {
		enabled = true,
		kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
	},
	foldtext = {
		enabled = true,
		lineCount = {
			template = "   %d lines", -- `%d` is repalced with the number of folded lines
			hlgroup = "Comment",
		},
		diagnostics = {
			enabled = true,
			-- uses hlgroups and icons from `vim.diagnostic.config().signs`
		},
	},
	pauseFoldsOnSearch = true,
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

### Folds are opened after running a formatter
This is a known issue of many formatting plugins and unrelated to
`nvim-origami`.

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
