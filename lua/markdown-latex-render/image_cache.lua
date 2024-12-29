local M = {}

--- map of buffer to image list
--- @type table<integer, table<string, markdown-latex-render.ImageInterface>>
local buf_images = {}


--- @param buf integer
--- @return table<string, markdown-latex-render.ImageInterface>>
local get_image_table_for_buf = function(buf)
    local images = buf_images[buf]
    if not images then return {} end
    return images
end

--- @param buf integer
--- @param key string
--- @param image markdown-latex-render.ImageInterface
function M.register_image(buf, key, image)
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
function M.get_registered_images(buf)
    local image_table = get_image_table_for_buf(buf)
    local result = {}
    for _, image in pairs(image_table) do
        table.insert(result, image)
    end
    return result
end

--- @param buf integer
function M._rerender_images_in_buf(buf)
    local image_table = get_image_table_for_buf(buf)
    for _, image in pairs(image_table) do
        image:clear()
        image:render()
    end
end

--- @param buf integer
--- @param key string
--- @return boolean
function M._image_already_registered(buf, key)
    if buf_images[buf] == nil or buf_images[buf][key] == nil then
        return false
    end
    return true
end

--- @param buf integer
--- @param y integer
--- @return markdown-latex-render.ImageInterface[]
function M._get_images_at_location(buf, y)
    local image_table = get_image_table_for_buf(buf)
    --- @type markdown-latex-render.ImageInterface[]
    local results = {}
    for _, image in pairs(image_table) do
        if image.geometry.y == y then
            table.insert(results, image)
        end
    end
    return results
end

--- @param buf integer
--- @param key string
--- @param delay? integer
function M._clear_registered_image(buf, key, delay)
    delay = delay or 50
    local image_table = get_image_table_for_buf(buf)
    assert(image_table[key], "trying to clear image " .. key .. " that is not registered")

    local image = image_table[key]
    if image ~= nil then
        vim.defer_fn(function()
            image:clear()
            vim.fn.delete(image.path)
        end, delay)
        buf_images[buf][key] = nil
    end
end

--- @param buf integer
function M._clear_registered_images(buf)
    local image_table = get_image_table_for_buf(buf)
    for key, _ in pairs(image_table) do
        M._clear_registered_image(buf, key)
    end
    buf_images[buf] = nil
end

--- @param buf integer
--- @param results TSQueryResults[]
-- TODO: should not know about TSQueryResults here
function M._delete_unused_by_location(buf, results)
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
            M._clear_registered_image(buf, key)
        end
    end
end

--- clears everything
function M._clear()
    for buf, _ in pairs(buf_images) do
        M._clear_registered_images(buf)
    end
end

return M
