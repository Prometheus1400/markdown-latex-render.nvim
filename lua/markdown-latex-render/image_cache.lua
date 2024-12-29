M = {}

-- TODO: the key being the latex is not good enough because the same latex expressions can be used multiple
-- times throughout the same buffer

--- map of buffer to image list
--- @type table<integer, table<string, markdown-latex-render.ImageInterface>>
local buf_images = {}

--- @param buf integer
--- @param key string
--- @param image markdown-latex-render.ImageInterface
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
--- @return markdown-latex-render.ImageInterface[]
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
--- @return markdown-latex-render.ImageInterface | nil
M._get_image_at_location = function(buf, y)
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
--- @param results TSQueryResults[]
M._delete_unused_by_location = function(buf, results)
    if not buf_images[buf] then
        return
    end
    for key, image in pairs(buf_images[buf]) do
        local used = false
        for _, query_result in ipairs(results) do
            if image.geometry.y == query_result.pos.r_end then
                used = true
                break
            end
        end
        if not used then
            _clear_registered_image(buf, key)
        end
    end
end

return M
