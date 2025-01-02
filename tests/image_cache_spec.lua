---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field

local assert = require("luassert")
local mock = require("luassert.mock")

local image_cache = require("markdown-latex-render.image_cache")

local setup = function()
  image_cache._clear()
end

--- @param id integer
--- @param y integer
--- @return markdown-latex-render.ImageInterface
local test_image_instance = function(id, y)
  local image = { id = id, geometry = { y = y }, clear = function(_) end }
  return image
end

describe("markdown-latex-render.image_cache", function()
  it("test registering images", function()
    setup()
    local buf = 1000
    local key = "key"
    local image = test_image_instance(1, 0)

    local success = pcall(image_cache.register_image, buf, key, image)
    assert.are.same(true, success)
    success = pcall(image_cache.register_image, buf, key, image)
    assert.are.same(false, success)
  end)
  it("test getting registered images", function()
    setup()
    local buf = 1000
    local key1 = "key1"
    local key2 = "key2"
    local image1 = test_image_instance(1, 0)
    local image2 = test_image_instance(2, 0)
    local image3 = test_image_instance(3, 0)
    local image4 = test_image_instance(4, 0)
    pcall(image_cache.register_image, buf, key1, image1)
    pcall(image_cache.register_image, buf, key1, image3)
    pcall(image_cache.register_image, buf, key2, image2)
    pcall(image_cache.register_image, buf, key2, image4)

    local stored_images = image_cache.get_registered_images(buf)
    assert.are.same(2, #stored_images)
    for _, image in ipairs(stored_images) do
      assert(image)
    end
  end)
  it("test clearing images", function()
    setup()
    image_cache.register_image(1000, "key1", test_image_instance(1, 0))
    image_cache.register_image(1001, "key2", test_image_instance(2, 0))
    image_cache.register_image(1000, "key3", test_image_instance(3, 0))
    image_cache.register_image(1001, "key4", test_image_instance(4, 0))
    assert.are.same(2, #image_cache.get_registered_images(1000))
    assert.are.same(2, #image_cache.get_registered_images(1001))
    image_cache._clear_registered_images(1000)
    assert.are.same(0, #image_cache.get_registered_images(1000))
    assert.are.same(2, #image_cache.get_registered_images(1001))
  end)
  it("test getting images at location", function()
    setup()
    image_cache.register_image(0, "key1", test_image_instance(1, 50))
    image_cache.register_image(0, "key2", test_image_instance(2, 50))

    local images = image_cache._get_images_at_location(0, 50)
    assert.are.same(2, #images)
  end)
end)
