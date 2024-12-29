--- @type markdown-latex-render.ImageApiInterface
--- @diagnostic disable-next-line
local M = {}

--- @type markdown-latex-render.ImageApiInterface
--- @diagnostic disable-next-line
local image_impl = {}

--- @param image_interface markdown-latex-render.ImageApiInterface
--- @diagnostic disable-next-line
M._setup = function(image_interface)
    image_impl = image_interface
end

return setmetatable(M, {
    __index = function(_, k) return image_impl[k] end,
})
