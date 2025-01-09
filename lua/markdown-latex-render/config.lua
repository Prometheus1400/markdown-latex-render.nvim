--- @class  markdown-latex-render.Config
--- @field img_dir? string if you want generated images to be stored somewhere other than the default location in /tmp/markdown-latex-render
--- @field log_level? "DEBUG" | "INFO" | "WARN" | "ERROR" log level
--- @field render? markdown-latex-render.ConfigRender if you want generated images to be stored somewhere other than the default location in /tmp

--- @class markdown-latex-render.ConfigRender
---- @field display_error? boolean instead of just not rendering the latex it will display an image with error message
--- @field appearance? markdown-latex-render.ConfigRenderAppearance
--- @field on_open? boolean wether to automatically render latex when loading the buffer
--- @field on_text_change? boolean wether to automatically render latex on text change events
--- @field on_write? "render"|"rerender"|nil wether to automatically render/rerender latex when writing the buffer or neither
--- @field usetex? boolean wether to use latex install on your system or subset provided in matplotlib
--- @field tex_preamble? string preamble to use and setup packages when usetex is set to true
--- @field position? "left" placement for generated latex
---
--- @class markdown-latex-render.ConfigRenderAppearance
--- @field bg? string hex background color, nil by default because generating a transparent image to match background
--- @field fg? string hex foreground color
--- @field transparent? boolean wether to make the generated image transparent, bg will override if set
--- @field fontsize? integer font size in latex image
--- @field ppi? integer display's ppi (pixel per inch)

--- @type markdown-latex-render.Config
local config = {
  -- directory where the temporary generated images will be stored
  img_dir = "/tmp/markdown-latex-render",
  -- level for the logger, log file generated in vim log stdpath
  log_level = "WARN",
  render = {
    appearance = {
      fg = "default",
      bg = nil,
      transparent = true,
      fontsize = 18,
      ppi = 224,
    },
    -- when first opening the buffer if the latex should get rendered automatically
    on_open = true,
    -- if you want to trigger some render functionality on write you can supply 'render' or 'rerender' here
    on_write = "render",
    -- wether to use latex install on your system, default false will use mathtex (not require latex on system)
    usetex = false,
    -- used for requiring other packages you want to use
    tex_preamble = [[
    \usepackage{amsmath}
    ]],
    position = "left", -- TODO: allow for centering image
  },
}

--- @type markdown-latex-render.Config
local M = {}

---@diagnostic disable-next-line: inject-field
function M.merge_with(user_config)
  config = vim.tbl_deep_extend("force", config, user_config)
end

return setmetatable(M, {
  __index = function(_, k)
    return config[k]
  end,
})
