---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field

local assert = require("luassert")
local mock = require("luassert.mock")

local image_cache = require("markdown-latex-render.image_cache")


--- @param id integer
--- @return markdown-latex-render.ImageInterface
local test_image_instance = function(id)
    local image = { id = id }
    return image
end

describe("markdown-latex-render.image_cache", function()
    it("test registering images", function()
        local buf = 1000
        local key = "key"
        local image = test_image_instance(1)

        local success = pcall(image_cache.register_image, buf, key, image)
        assert.are.same(true, success)
        success = pcall(image_cache.register_image, buf, key, image)
        assert.are.same(false, success)
    end)
    it("test getting registered images", function()
        local buf = 1001
        local key1 = "key1"
        local key2 = "key2"
        local image1 = test_image_instance(1)
        local image2 = test_image_instance(2)
        local image3 = test_image_instance(3)
        local image4 = test_image_instance(4)
        pcall(image_cache.register_image, buf, key1, image1)
        pcall(image_cache.register_image, buf, key1, image3)
        pcall(image_cache.register_image, buf, key2, image2)
        pcall(image_cache.register_image, buf, key2, image4)

        local stored_images = image_cache.get_registered_images(buf)
        eq({
            key1 = image1,
            key2 = image2
        }, stored_images)
    end)
    it("test clearing images", function()
        image_cache._clear_registered_image(1001, "key2")
        image_cache._clear_registered_image(1001, "key4")
        assert.are.same({
            key1 = { id = 1 },
        }, image_cache.get_registered_images(1001))
        image_cache._clear_registered_images(1000)
        image_cache._clear_registered_images(1001)
        assert.are.same({}, image_cache.get_registered_images(1000))
        assert.are.same({}, image_cache.get_registered_images(1001))
    end)
end)
