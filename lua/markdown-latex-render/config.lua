local utils = require("markdown-latex-render.utils")

--- @class  markdown-latex-render.Config
--- @field img_dir? string if you want generated images to be stored somewhere other than the default location in /tmp/markdown-latex-render
--- @field log_level? "DEBUG" | "INFO" | "WARN" | "ERROR" log level
--- @field render? markdown-latex-render.ConfigRender if you want generated images to be stored somewhere other than the default location in /tmp

--- @class markdown-latex-render.ConfigRender
--- @field on_write? boolean wether to live render as you type instead of on write as is the default
---- @field display_error? boolean instead of just not rendering the latex it will display an image with error message
--- @field bg? string hex background color, nil by default because generating a transparent image to match background
--- @field fg? string hex foreground color
--- @field transparent? boolean wether to make the generated image transparent, bg will override if set

--- @type markdown-latex-render.Config
local config = {
    img_dir = "/tmp/markdown-latex-render",
    log_level = "WARN",
    render = {
        on_write = true,
        fg = utils.get_fg(),
        bg = nil,
        transparent = true,
    }
}

local M = {}

function M.merge_with(user_config)
    config = vim.tbl_deep_extend('force', config, user_config)
end

return setmetatable(M, {
    __index = function(_, k) return config[k] end,
})
