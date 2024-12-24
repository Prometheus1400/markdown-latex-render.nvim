require("image")

---- @class markdown-latex-render.LatexImage : Image
---- @field latex string


M = {}

--- map of buffer to image list
--- @type table<integer, table<string, Image>>
local buf_images = {}

--- @param buf integer
--- @param key string
--- @param image Image
M.register_image = function(buf, key, image)
    if not buf_images[buf] then
        buf_images[buf] = {}
    end
    if buf_images[buf][key] ~= nil then
        error("Image already registered. You probably meant to rerender.")
    end

    buf_images[buf][key] = image
end

--- @param buf integer
--- @return Image[]
M.get_registered_images = function(buf)
    local images = buf_images[buf]
    if not images then
        return {}
    end
    return buf_images[buf]
end

--- @param buf integer
M._rerender_images_in_buf = function(buf)
    local images = buf_images[buf]
    if not images then return end
    for _, image in pairs(images) do
        image:clear()
        image:render()
    end
end

--- @param buf integer
--- @param key string
--- @return boolean
M._image_already_rendered = function(buf, key)
    if buf_images[buf] == nil or buf_images[buf][key] == nil then
        return false
    end
    return true
end

--- @param buf integer
--- @param y integer
--- @return Image | nil
M._get_image_at_location = function(buf, y)
    -- TODO: this needs to get fixed
    if not buf_images[buf] then
        return nil
    end
    for _, image in pairs(buf_images[buf]) do
        if image.geometry.y == y then
            return image
        end
    end
    return nil
end

--- @param buf integer
--- @param key string
local _clear_registered_image = function(buf, key)
    local image = buf_images[buf][key]
    if image ~= nil then
        image:clear()
        vim.fn.delete(image.path)
        buf_images[buf][key] = nil
    end
end
M._clear_registered_image = _clear_registered_image

--- @param buf integer
M._clear_registered_images = function(buf)
    local images = buf_images[buf]
    if not images then
        return
    end
    for key, _ in pairs(images) do
        _clear_registered_image(buf, key)
    end
    buf_images[buf] = {}
end

--- @param buf integer
M._list_image_geometry = function(buf)
    for _, image in pairs(buf_images[buf]) do
        print(vim.inspect(image.geometry))
    end
end

return M
