<!-- LTeX: enabled=false -->
# nvim-origami <!-- LTeX: enabled=true -->
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-origami"><img src="https://dotfyle.com/plugins/chrisgrieser/nvim-origami/shield" /></a>

Fold with relentless elegance.

## Features
- Use `h` at the first non-blank character of a line (or before) to fold. Use `l` anywhere on a folded line to unfold it.[^1] This allows you to ditch `zc`, `zo`, and `za` – you can just use `h` and `l` to work with folds. (`h` still moves left if not at the beginning of a line, and `l` still moves right when on an unfolded line – this plugin basically "overloads" those keys.)
- Pause folds while searching, restore folds when done with searching. (Normally, folds are opened when you search for some text inside a fold, and *stay* open afterwards.)
- Remember folds across sessions.

## Installation

```lua
-- lazy.nvim
{
	"chrisgrieser/nvim-origami",
	event = "BufReadPost", -- later or on keypress would prevent saving folds
	opts = true, -- needed even when using default config
},

-- packer
use {
	"chrisgrieser/nvim-origami",
	config = function () 
		require("origami").setup ({}) -- setup call needed
	end,
}
```

The `.setup()` call or `lazy`'s `opts` is required. Otherwise the plugin works out of the box without any necessary further configuration.

## Configuration

```lua
-- default values
require("origami").setup ({
	keepFoldsAcrossSessions = true,
	pauseFoldsOnSearch = true,
	setupFoldKeymaps = true,
})
```

*Recommendation:* By setting ['startofline'](https://neovim.io/doc/user/options.html#'startofline') to `true`, bigger movements move you to the start of the line, which works well with this plugin's `h` key.

If you use other keys than `h` and `l` for vertical movement, set `setupFoldKeymaps` to false and map the keys yourself:

```lua
require("origami").h()
require("origami").l()
```

## Limitations
[Using formatting plugins will still open all your folds](https://www.reddit.com/r/neovim/comments/164gg5v/preserve_folds_when_formatting/) and unfortunately, there is nothing this plugin can do about it. Using [lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()) preserves folds, so you should consider switching to [the efm LSP](https://github.com/mattn/efm-langserver), if you want your folds to resist formatting.

## Other Folding Plugins
- [fold-cycle.nvim](https://github.com/jghauser/fold-cycle.nvim)
- [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)

## Credits
<!-- vale Google.FirstPerson = NO -->
__About Me__  
In my day job, I am a sociologist studying the social mechanisms underlying the digital economy. For my PhD project, I investigate the governance of the app economy and how software ecosystems manage the tension between innovation and compatibility. If you are interested in this subject, feel free to get in touch.

__Blog__  
I also occasionally blog about vim: [Nano Tips for Vim](https://nanotipsforvim.prose.sh)

__Profiles__  
- [reddit](https://www.reddit.com/user/pseudometapseudo)
- [Discord](https://discordapp.com/users/462774483044794368/)
- [Academic Website](https://chris-grieser.de/)
- [Twitter](https://twitter.com/pseudo_meta)
- [Mastodon](https://pkm.social/@pseudometa)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

__Buy Me a Coffee__  
<br>
<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

[^1]: Technically, unfolding with `l` is already a built-in vim feature when `foldopen` includes `hor`. However, this plugin still sets up an `l` key replicating that behavior, since the built-in version still moves you to one character to the side, which can be considered a bit counterintuitive.
