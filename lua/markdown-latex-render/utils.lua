M = {}

--- @return string | nil
M.get_fg = function()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
  if not normal or not normal.fg then
    return nil
  end
  return string.format("#%06x", normal.fg)
end

--- @return integer gets the column width in pixels
M.get_col_width_in_pixels = function()
  local ffi = require("ffi")
  ffi.cdef([[
    typedef struct {
      unsigned short row;
      unsigned short col;
      unsigned short xpixel;
      unsigned short ypixel;
    } winsize;
    int ioctl(int, int, ...);
  ]])

  local TIOCGWINSZ = nil
  if vim.fn.has("linux") == 1 then
    TIOCGWINSZ = 0x5413
  elseif vim.fn.has("mac") == 1 then
    TIOCGWINSZ = 0x40087468
  elseif vim.fn.has("bsd") == 1 then
    TIOCGWINSZ = 0x40087468
  end

  ---@type { row: number, col: number, xpixel: number, ypixel: number }
  local sz = ffi.new("winsize")
  assert(ffi.C.ioctl(1, TIOCGWINSZ, sz) == 0, "Failed to get terminal size")
  return math.floor(sz.xpixel / sz.col)
end

return M
