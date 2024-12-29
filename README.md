# Latex Rendering in Markdown Files (markdown-latex-render.nvim)

### Features
TODO

### Motivation
It's been a couple of years since I graduated from university and in that time I've become a heavy user of Neovim and terminal workflows. I'm returning to school and plan on taking notes in Obsidian, while it's a great app I'm so used to my neovim workflow I've decided to try using the [Obisidian.nvim](https://github.com/epwalsh/obsidian.nvim) plugin. One big thing that was missing for me is rendered latex, as I will be taking courses involving math. This is my attempt to bridge that gap and make the Obsidian experience in Neovim even better.

## Getting Started
### Dependencies
Currently it is required that you have the matplotlib package installed for python globally on your system. You can check by running `pip3 list | grep matplotlib`. On linux you should be able to install using `pip3` and on mac you can install using `brew`.

### Installation
##### Lazy.nvim
```lua
return {
    dir = "Prometheus1400/markdown-latex-render.nvim",
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
