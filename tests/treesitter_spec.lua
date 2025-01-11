---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field

local treesitter = require("markdown-latex-render.treesitter")
local eq = assert.are.same
local ts = vim.treesitter

local empty_buffer = function()
  local bufno = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = bufno })
  -- Get the parser for the buffer
  return bufno
end

--- @param filepath string
local get_buffer = function(filepath)
  local lines = vim.fn.readfile(filepath)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  return buf
end

--- @param buf integer
local fully_parse = function(buf)
  local md_parser = ts.get_parser(buf, "markdown")
  md_parser:parse(true)
  local md_inline_parser = md_parser:children().markdown_inline
  md_inline_parser:parse(true)
  local latex_parser = md_inline_parser:children().latex
  latex_parser:parse(true)
end

describe("markdown-latex-render.treesitter", function()
  it("markdown buffer with no latex should return empty table", function()
    local buf = get_buffer("tests/data/test1.md")
    fully_parse(buf)

    local latex_results = treesitter._query_latex_in_buf(buf)
    print(vim.inspect(latex_results))
  end)

  -- it("markdown buffer with 2 equation blocks should return them", function()
  --     eq({}, query._query_latex_in_buf(buffer_with_latex()))
  -- end)
end)
