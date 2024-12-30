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
    -- directory where the temporary generated images will be stored
    img_dir = "/tmp/markdown-latex-render",
    -- level for the logger, log file generated in vim log stdpath
    log_level = "WARN",
    render = {
        appearance = {
            -- will pick your normal fg text color can be any hex string color though
            fg = "default",
            bg = nil,
            transparent = true,
            -- a bit janky but I need some way of getting the width of the window in some real unit not just columns (image generated with this width)
            columns_per_inch = 18,
        },
        -- when first opening the buffer if the latex should get rendered automatically
        on_open = true,
        -- if you want to trigger some render functionality on write you can supply 'render' or 'rerender' here
        on_write = nil,
    },
}

--- @type markdown-latex-render.Config
local M = {}

---@diagnostic disable-next-line: inject-field
function M.merge_with(user_config)
    config = vim.tbl_deep_extend("force", config, user_config)
end

return setmetatable(M, {
    __index = function(_, k) return config[k] end,
})
