<!-- LTeX: enabled=false -->
# nvim-origami 🐦📄
<!-- LTeX: enabled=true -->
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-origami">
<img alt="badge" src="https://dotfyle.com/plugins/chrisgrieser/nvim-origami/shield"/></a>

*Fold with relentless elegance.*

A collection of Quality-of-life features related to folding.

<img alt="Showcase" width=60% src="https://github.com/user-attachments/assets/bb13ee0f-7485-4e3f-b303-880b9d4d656e">

## Features
1. Remember folds across sessions (and as a side effect, also the cursor
   position). Requires `nvim-ufo`.
2. Pause folds while searching, restore folds when done with searching.
   (Normally, folds are opened when you search for some text inside a fold, and
   *stay* open afterward.)
3. Add line count to the `foldtext`, while preserving the syntax highlighting of
   the line (requires Treesitter parser for the language). Not compatible with
   `nvim-ufo`.
4. Use `h` at the first non-blank character of a line (or before) to fold. Use
   `l` anywhere on a folded line to unfold it.[^1] This allows you to ditch
   `zc`, `zo`, and `za`: you can just use `h` and `l` to work with folds. (`h`
   still moves left if not at the beginning of a line, and `l` still moves right
   when on an unfolded line—this plugin basically "overloads" those keys.)

> [!NOTE]
> This plugin does **not** provide a `foldmethod`. For this plugin to work, you
> either need [to set one of on your
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
	},

	foldKeymaps = {
		setup = true, -- modifies `h` and `l`
		hOnlyOpensOnFirstColumn = false,
	},
}
```

> [!TIP]
> By setting
> [vim.opt.startofline](https://neovim.io/doc/user/options.html#'startofline')
> to `true`, bigger movements move you to the start of the line, which works
> well with this plugin's `h` key.

If you use other keys than `h` and `l` for vertical movement, set
`setupFoldKeymaps = false` and map the keys yourself:

```lua
vim.keymap.set("n", "<Left>", function() require("origami").h() end)
vim.keymap.set("n", "<Right>", function() require("origami").l() end)
```

## Limitations
[Many formatting plugins open all your
folds](https://www.reddit.com/r/neovim/comments/164gg5v/preserve_folds_when_formatting/)
and unfortunately, there is nothing this plugin can do about it. The only two
tools that are able to preserve folds are the
[efm-language-server](https://github.com/mattn/efm-langserver) and
[conform.nvim](https://github.com/stevearc/conform.nvim).

## Other useful folding plugins
- [fold-cycle.nvim](https://github.com/jghauser/fold-cycle.nvim)
- [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)

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
