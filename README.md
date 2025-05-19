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
<!-- LTeX: enabled=false -->

| opts                                 | description                                                                                                                                                                                                                                                             | requirements                                                                                                              |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `.useLspFoldsWithTreesitterFallback` | Use the LSP to provide folds, with Treesitter as fallback if the LSP does not provide folding info.                                                                                                                                                                     | 1. *not* using `nvim-ufo` (feature is redundant with `nvim-ufo`)<br>2. Nvim 0.11                                          |
| `.foldKeymaps`                       | Overload the `h` key which will fold a line when used one the first non-blank character of (or before). And overload the `l` key, which will unfold a line when used on a folded line.[^1] This allows you to ditch `zc`, `zo`, and `za`, `h` and `l` are all you need. | —                                                                                                                         |
| `.autoFold`                          | Automatically fold comments and/or imports when opening a file.                                                                                                                                                                                                         | 1. *not* using `nvim-ufo` (feature is redundant with `nvim-ufo`)<br>2. nvim 0.11<br>3. LSP that provides fold information |
| `.foldtextWithLineCount`             | Add line count to the `foldtext`, preserving the syntax highlighting of the line.                                                                                                                                                                                       | 1. *not* using `nvim-ufo` (feature is redundant with `nvim-ufo`)<br>2. Treesitter parser for the language.                |
| `.pauseFoldsOnSearch`                | Pause folds while searching, restore folds when done with searching. (Normally, folds are opened when you search for text inside them, and *stay* open afterward.)                                                                                                      | —                                                                                                                         |
| `.keepFoldsAcrossSessions`           | Remember folds across sessions.                                                                                                                                                                                                                                         | `nvim-ufo`                                                                                                                |

<!-- LTeX: enabled=true -->

The requirements may look detailed, but the plugin works mostly out-of-the-box.
If you are on nvim 0.11+ and do not have `nvim-ufo` installed, all features
except `autoFold` and `keepFoldsAcrossSessions` are enabled by default and work
without any need for additional configuration.

With nvim 0.11+, `nvim-origami` is able to replace most of `nvim-ufo`'s feature
set in a much more lightweight way.

## Installation

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
	-- features incompatible with `nvim-ufo`
	useLspFoldsWithTreesitterFallback = not package.loaded["ufo"],
	autoFold = {
		enabled = false,
		kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
	},
	foldtextWithLineCount = {
		enabled = not package.loaded["ufo"],
		template = "   %s lines", -- `%s` gets the number of folded lines
		hlgroupForCount = "Comment",
	},

	-- can be used with or without `nvim-ufo`
	pauseFoldsOnSearch = true,
	foldKeymaps = {
		setup = true, -- modifies `h` and `l`
		hOnlyOpensOnFirstColumn = false,
	},

	-- features requiring `nvim-ufo`
	keepFoldsAcrossSessions = package.loaded["ufo"],
}
```

If you use other keys than `h` and `l` for vertical movement, set
`opts.foldKeymaps.setup = false` and map the keys yourself:

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
  for the more performant implementation of fold text with highlighting.

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

[^1]: Technically, unfolding with `l` is already a built-in vim feature when
	`vim.opt.foldopen` includes `hor`. However, this plugin still sets up a `l`
	key replicating that behavior, since the built-in version still moves you to
	one character to the side, which can be considered a bit counterintuitive.
