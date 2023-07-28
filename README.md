<!-- LTeX: enabled=false -->
# nvim-origami <!-- LTeX: enabled=true -->
Fold with elegance.

<!--toc:start-->
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Limitations](#limitations)
- [Credits](#credits)
<!--toc:end-->

## Features
- Remember folds across sessions.
- Pause folds while searching, restore folds when done with searching.
- Use `h` at the first non-blank character of a line (or before) to fold.
- Use `l` anywhere on a folded line to unfold it.


## Installation

```lua
-- lazy.nvim
{
	"chrisgrieser/nvim-origami",
	event = "BufReadPost", -- later or key would prevent saving folds
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

## Configuration

```lua
-- default values
require("origami").setup ({
	keepFoldsAcrossSessions = true,
	pauseFoldsOnSearch = {
		enabled = true,
		forwardKey = "/",
		backwardKey = "?",
	},
})
```

```lua
vim.keymap.set("n", "h", function() require("origami").h() end, { desc = "Origami h" })
vim.keymap.set("n", "l", function() require("origami").l() end, { desc = "Origami l" })
```

## Limitations
Running a formatter, which changes something inside a fold can result in unintentionally opening that fold. This plugin does not have a feature yet to prevent that.

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
