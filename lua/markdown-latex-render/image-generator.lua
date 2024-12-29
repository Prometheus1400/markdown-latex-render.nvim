local logger = require("markdown-latex-render.logger")
local job = require("plenary.job")
local config = require("markdown-latex-render.config")

local M = {}

--- @param latex string latex string to convert to image
--- @param image_name string name of generated image
--- @param callback fun(code: integer, img_path: string)
--- @param opts GenerateImageOpts
M._generate_image = function(latex, image_name, callback, opts)
    local img_dir = opts.img_dir or config.img_dir
    local cur_file_dir = debug.getinfo(1).source:match('@?(.*/)')
    local py_script_path = cur_file_dir .. "/image-generator/latex-to-img.py"
    local args = {
        py_script_path,
        latex,
        "-o",
        img_dir .. "/" .. image_name,
    }
    if config.render.bg then
        table.insert(args, "-bg")
        table.insert(args, config.render.appearance.bg)
    end
    if config.render.appearance.fg then
        table.insert(args, "-fg")
        table.insert(args, config.render.appearance.fg)
    end
    if config.render.appearance.transparent then
        table.insert(args, "-t")
    end
    if opts.width then
        table.insert(args, "-w")
        table.insert(args, opts.width)
    end
    local newjob = job:new({
        command = "python3",
        args = args,
        on_stdout = function(_, line)
            logger.debug(line)
        end,
        on_stderr = function(_, line)
            logger.error(line)
        end,
        on_exit = function(_, code)
            if callback then
                callback(code, img_dir .. "/" .. image_name)
            end
        end
    })

    if opts.sync then
        newjob:sync()
    else
        newjob:start()
    end
end

return M
