# Latex Rendering in Markdown Files (markdown-latex-render.nvim)

### Features
Render block latex equations in markdown files by generating a png and displaying using [image.nvim](https://github.com/3rd/image.nvim). Support for automatic rendering when buffer is opened as well as rerendering on write. I intentionally wanted to minimize dependencies such as needing a full blown latex toolchain, and to this end I decided to use `matplotlib.pyplot`. This means that it only supports a *subset* of latex meaning super simple equations without support for `\begin{align}` and the like only math. This is all the functionality that *I* need but if there are requests for full latex support I will look into that as well. 

### Motivation
It's been a couple of years since I graduated from university and in that time I've become a heavy user of Neovim and terminal workflows. I'm returning to school and plan on taking notes in Obsidian, while it's a great app I'm so used to my neovim workflow I've decided to try using the [Obisidian.nvim](https://github.com/epwalsh/obsidian.nvim) plugin. One big thing that was missing for me is rendered latex, as I will be taking courses involving math. This is my attempt to bridge that gap and make the Obsidian experience in Neovim even better.

## Getting Started
### Dependencies
- Treesitter parsers: `markdown`, `markdown_inline`, and `latex`
- Currently it is required that you have the matplotlib package installed for python globally on your system. You can check by running `pip3 list | grep matplotlib`. On linux you should be able to install using `pip3` and on mac you can install using `brew`.
- This plugin also depends on the amazing [image.nvim](https://github.com/3rd/image.nvim) that really handles all of the heavy lifting.
- Your terminal must support Kitty graphics protocol. I recommend that you use Kitty or Ghostty. Wezterm also implements the protocol but in my experience the performance is worse and it suffers more from display issues.

### Installation
##### Lazy.nvim
```lua
return {
    "Prometheus1400/markdown-latex-render.nvim",
    dependencies = { "3rd/image.nvim", "nvim-lua/plenary.nvim" },
    opts = {}
}
```

### Configuration

<details>
<summary>Default Configuration</summary>

```lua
local config = {
    img_dir = "/tmp/markdown-latex-render",
    log_level = "WARN",
    render = {
        appearance = {
            fg = utils.get_fg(),
            bg = nil,
            transparent = true,
            columns_per_inch = 18,
        },
        on_open = true,
        on_write = 'render',
    },
}
```

</details>
