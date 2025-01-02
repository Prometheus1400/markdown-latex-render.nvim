---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field

local image_generator = require("markdown-latex-render.image-generator")

local eq = assert.are.same

local test_dir = "/tmp/markdown-latex-render-test"

local setup = function()
  local ok, _, _ = vim.loop.fs_stat(test_dir)
  if not ok then
    vim.loop.fs_mkdir(test_dir, 511)
  end
end

local teardown = function()
  for file in vim.fs.dir(test_dir) do
    vim.loop.fs_unlink(test_dir .. "/" .. file)
  end
end

describe("markdown-latex-render.image-generator", function()
  it("should be able to generate an image from latex string", function()
    setup()

    local latex = "\\log_2(x)"
    local image_name = "test.png"
    image_generator._generate_image(latex, image_name, function(code, img_path)
      eq(code, 0)
      local stat = vim.loop.fs_stat(img_path)
      assert.not_nil(stat)
      eq(stat.type, "file")
      teardown()
    end, { image_dir = test_dir, sync = true })
  end)
  it("should be able to generate an image from multiline latex string", function()
    setup()

    local latex = "\\log_2(x)\nx=2"
    local image_name = "test2.png"
    image_generator._generate_image(latex, image_name, function(code, img_path)
      eq(code, 0)
      local stat = vim.loop.fs_stat(img_path)
      assert.not_nil(stat)
      eq(stat.type, "file")
      teardown()
    end, { image_dir = test_dir, sync = true })
  end)
end)
