---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

local images = require("markdown-latex-render.images")

local eq = assert.are.same

--- @param id integer
local test_image_instance = function(id)
    local image = { id = id }
    return image
end

describe("markdown-latex-render.images", function()
    it("test registering images", function()
        local buf = 1000
        local key = "key"
        local image = test_image_instance(1)

        local success = pcall(images.register_image, buf, key, image)
        eq(true, success)
        success = pcall(images.register_image, buf, key, image)
        eq(false, success)
    end)
    it("test getting registered images", function()
        local buf = 1001
        local key1 = "key1"
        local key2 = "key2"
        local image1 = test_image_instance(1)
        local image2 = test_image_instance(2)
        local image3 = test_image_instance(3)
        local image4 = test_image_instance(4)
        pcall(images.register_image, buf, key1, image1)
        pcall(images.register_image, buf, key1, image3)
        pcall(images.register_image, buf, key2, image2)
        pcall(images.register_image, buf, key2, image4)

        local stored_images = images.get_registered_images(buf)
        eq({
            key1 = image1,
            key2 = image2
        }, stored_images)
    end)
    it("test clearing images", function()
        images._clear_registered_image(1001, "key2")
        images._clear_registered_image(1001, "key4")
        eq({
            key1 = { id = 1 },
        }, images.get_registered_images(1001))
        images._clear_registered_images(1000)
        images._clear_registered_images(1001)
        eq({}, images.get_registered_images(1000))
        eq({}, images.get_registered_images(1001))
    end)
end)
