local config = require("markdown-latex-render.config")
local render = require("markdown-latex-render.render")
local image_api = require("markdown-latex-render.image_api")

M = {}

--- @param opts? markdown-latex-render.Config
M.setup = function(opts)
    -- inject images api
    ---@diagnostic disable-next-line
    image_api._setup(require("image"))

    local default_img_dir = config.img_dir
    print(default_img_dir)
    config.merge_with(opts)
    local selected_img_dir = config.img_dir
    if selected_img_dir == default_img_dir then
        if vim.fn.isdirectory(selected_img_dir) == 0 then
            vim.fn.mkdir(selected_img_dir)
        end
    end

    render._setup_auto_commands()
    render._setup_user_commands()
end

return M
