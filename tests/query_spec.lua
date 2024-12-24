---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field

local query = require("markdown-latex-render.query")

local eq = assert.are.same
local ts = vim.treesitter

-- TODO: instead of testing the query AND treesitter
-- instead build at least part of a treesitter AST to test the query
-- isolated testing!

local empty_buffer = function()
    local bufno = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value('filetype', 'markdown', { buf = bufno })
    -- Get the parser for the buffer
    return bufno
end

local buffer_with_latex = function()
    local bufno = empty_buffer()
    local lines = {
        "# title",
        "",
        "paragraph content",
        "",
        "#####list",
        "- item1",
        "- item2",
        "",
        "$$",
        "\frac{1}{2} = 0.5",
        "$$",
        "",
        "$$",
        "log_2(4) = 2",
        "$$",
        "]]",
    }
    vim.api.nvim_buf_set_lines(bufno, 0, -1, false, lines)
    local markdown_parser = ts.get_parser(bufno, "markdown", {
        injections = { enabled = true }
    })
    markdown_parser:parse()
    return bufno
end

describe("markdown-latex-render.query", function()
    -- TODO: fix this test. For some reason injected grammar parsers aren't
    -- working on this mocked buffer
    it("markdown buffer with no latex should return empty table", function()
        eq({}, query._query_latex_in_buf(empty_buffer()))
    end)

    -- it("markdown buffer with 2 equation blocks should return them", function()
    --     eq({}, query._query_latex_in_buf(buffer_with_latex()))
    -- end)
end)
