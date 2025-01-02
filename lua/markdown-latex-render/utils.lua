M = {}

M.get_fg = function()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
  if not normal or not normal.fg then
    return nil
  end
  return string.format("#%06x", normal.fg)
end

return M
