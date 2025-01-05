local config = require("markdown-latex-render.config")
local job = require("plenary.job")
local logger = require("markdown-latex-render.logger")
local utils = require("markdown-latex-render.utils")

local M = {}

--- @class markdown-latex-render.GenerateImageOpts
--- @field img_dir? string path to directory where generated images are placed
--- @field sync? boolean execute synchronously or asynchronously
---
--- @param latex string latex string to convert to image
--- @param image_name string name of generated image
--- @param callback fun(code: integer, img_path: string)
--- @param opts markdown-latex-render.GenerateImageOpts
M._generate_image = function(latex, image_name, callback, opts)
  local img_dir = opts.img_dir or config.img_dir
  local cur_file_dir = debug.getinfo(1).source:match("@?(.*/)")
  local venv_py_path = cur_file_dir .. "/image-generator/venv/bin/python"
  local py_script_path = cur_file_dir .. "/image-generator/latex-to-img.py"
  print(config.render.appearance.fontsize)
  local args = {
    py_script_path,
    "--ppi",
    config.render.appearance.ppi,
    "--fontsize",
    config.render.appearance.fontsize,
    "-o",
    img_dir .. "/" .. image_name,
    latex,
  }
  if config.render.appearance.bg then
    table.insert(args, "-bg")
    table.insert(args, config.render.appearance.bg)
  end
  if config.render.appearance.fg then
    table.insert(args, "-fg")
    if config.render.appearance.fg == "default" then
      table.insert(args, utils.get_fg())
    else
      table.insert(args, config.render.appearance.fg)
    end
  end
  if config.render.appearance.transparent then
    table.insert(args, "-t")
  end
  if config.render.usetex then
    table.insert(args, "--usetex")
  end
  if config.render.tex_preamble then
    table.insert(args, "--preamble")
    table.insert(args, config.render.tex_preamble)
  end
  local newjob = job:new({
    command = venv_py_path,
    args = args,
    on_stdout = function(_, line)
      logger.debug("python script sdout {" .. line .. "}")
    end,
    on_stderr = function(_, line)
      logger.error("python script sderr {" .. line .. "}")
    end,
    on_exit = function(_, code)
      if callback then
        callback(code, img_dir .. "/" .. image_name)
      end
    end,
  })

  if opts.sync then
    newjob:sync()
  else
    newjob:start()
  end
end

return M
