local ts = vim.treesitter

-- Define the query string
local query_string = [[
  (displayed_equation) @markdown.latex.render
]]

--- @param buf integer
--- @return vim.treesitter.LanguageTree
local get_latex_parser = function(buf)
  local markdown_parser = ts.get_parser(buf, "markdown") -- 0 refers to the current buffer
  if not markdown_parser then
    error("couldn't get markdown parser")
  end
  markdown_parser:parse()
  local markdown_inline_parser = markdown_parser:children().markdown_inline
  if not markdown_inline_parser then
    error("couldn't get markdown inline parser")
  end
  local latex_parser = markdown_inline_parser:children().latex
  if not latex_parser then
    error("couldn't get latex parser")
  end
  return latex_parser
end

local M = {}

--- @param buf? integer
--- @return TSQueryResults[]
M._query_latex_in_buf = function(buf)
  buf = buf or 0
  local ok, parser = pcall(get_latex_parser, buf)
  if not ok then
    return {}
  end

  local results = {}
  local trees = parser:parse()
  for _, tree in ipairs(trees) do
    local query = ts.query.parse("latex", query_string)
    for _, node, _, _ in query:iter_captures(tree:root(), 0) do
      local row1, _, row2, _ = ts.get_node_range(node)
      local text = ts.get_node_text(node, buf)
      local text_lines = vim.split(text, "\n")
      table.remove(text_lines, 1)
      table.remove(text_lines)
      text = table.concat(text_lines, "\n")
      table.insert(results, {
        pos = {
          r_start = row1,
          r_end = row2,
        },
        latex = text,
      })
    end
  end
  return results
end

--- @param buf? integer
--- @param win? integer
--- @return TSQueryResults[]
M._query_latex_at_cursor = function(buf, win)
  buf = buf or 0
  win = win or 0
  local ok, parser = pcall(get_latex_parser, buf)
  if not ok then
    print("couldn't get latex parser")
    return {}
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(win)
  local row, col = cursor_pos[1], cursor_pos[2]

  local results = {}
  local tree = parser:tree_for_range({ row, col, row, col })
  if not tree then
    print("couldn't get tree at cursor_pos")
    return {}
  end
  local query = ts.query.parse("latex", query_string)
  for _, node, _, _ in query:iter_captures(tree:root(), 0) do
    local row1, _, row2, _ = ts.get_node_range(node)
    local text = ts.get_node_text(node, buf)
    local text_lines = vim.split(text, "\n")
    table.remove(text_lines, 1)
    table.remove(text_lines)
    text = table.concat(text_lines, "\n")
    table.insert(results, {
      pos = {
        r_start = row1,
        r_end = row2,
      },
      latex = text,
    })
  end
  return results
end

--- @param buf integer
--- @param win integer
--- @return boolean
M._in_latex_section = function(buf, win)
  buf = buf or 0
  local ok, parser = pcall(get_latex_parser, buf)
  if not ok then
    return false
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(win)
  local row, col = cursor_pos[1], cursor_pos[2]
  local tree = parser:tree_for_range({ row, col, row, col })
  if not tree then
    return false
  end
  return true
end

return M
