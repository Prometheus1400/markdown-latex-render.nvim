local utils = require("markdown-latex-render.utils")

--- @class  markdown-latex-render.Config
--- @field img_dir? string if you want generated images to be stored somewhere other than the default location in /tmp/markdown-latex-render
--- @field log_level? "DEBUG" | "INFO" | "WARN" | "ERROR" log level
--- @field render? markdown-latex-render.ConfigRender if you want generated images to be stored somewhere other than the default location in /tmp

--- @class markdown-latex-render.ConfigRender
---- @field display_error? boolean instead of just not rendering the latex it will display an image with error message
--- @field appearance? markdown-latex-render.ConfigRenderAppearance
--- @field on_open? boolean wether to automatically render latex when loading the buffer
--- @field on_write? "render"|"rerender"|nil wether to automatically render/rerender latex when writing the buffer or neither
---
--- @class markdown-latex-render.ConfigRenderAppearance
--- @field bg? string hex background color, nil by default because generating a transparent image to match background
--- @field fg? string hex foreground color
--- @field transparent? boolean wether to make the generated image transparent, bg will override if set
--- @field columns_per_inch? integer number of columns per inch - used for sizing the generated latex png properly (ideally should configure as 18 only is a sensible default on MY system)

--- @type markdown-latex-render.Config
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

--- @type markdown-latex-render.Config
local M = {}

---@diagnostic disable-next-line: inject-field
function M.merge_with(user_config)
    config = vim.tbl_deep_extend('force', config, user_config)
end

return setmetatable(M, {
    __index = function(_, k) return config[k] end,
})
