local config = require("markdown-latex-render.config")
local render = require("markdown-latex-render.render")

M = {}


--- @param opts? markdown-latex-render.Config
M.setup = function(opts)
    local default_img_dir = config.img_dir
    config.merge_with(opts)
    local selected_img_dir = config.img_dir
    if selected_img_dir == default_img_dir then
        if vim.fn.isdirectory(selected_img_dir) == 0 then
            vim.fn.mkdir(selected_img_dir)
        end
    end

    render._setup_autocommands()
end

return M
