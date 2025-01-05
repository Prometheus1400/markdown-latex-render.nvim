local ffi = require("ffi")

local M = {}

--- @return string | nil
M.get_fg = function()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
  if not normal or not normal.fg then
    return nil
  end
  return string.format("#%06x", normal.fg)
end

--- @return integer gets the column width in pixels
function M.get_col_width_in_pixels()
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

--- @return integer screen_ppi
function M.get_screen_ppi()
  -- CoreGraphics and CoreFoundation bindings
  ffi.cdef([[
    typedef unsigned int CGDirectDisplayID;
    typedef struct { double width; double height; } CGSize;
    typedef double CGFloat;

    CGDirectDisplayID CGMainDisplayID();
    int CGDisplayPixelsWide(CGDirectDisplayID display);
    int CGDisplayPixelsHigh(CGDirectDisplayID display);
    CGSize CGDisplayScreenSize(CGDirectDisplayID display);

    typedef const void* CFStringRef;
    typedef const void* CFTypeRef;

    CFTypeRef CGDisplayCopyDisplayMode(CGDirectDisplayID display);
    CGFloat CGDisplayModeGetPixelWidth(CFTypeRef mode);
    CGFloat CGDisplayModeGetPixelHeight(CFTypeRef mode);
    void CFRelease(CFTypeRef cf);
]])

  -- Get the main display ID
  local display_id = ffi.C.CGMainDisplayID()

  -- Get the display mode to retrieve the actual pixel resolution (unscaled)
  local display_mode = ffi.C.CGDisplayCopyDisplayMode(display_id)
  local width_px = ffi.C.CGDisplayModeGetPixelWidth(display_mode)
  local height_px = ffi.C.CGDisplayModeGetPixelHeight(display_mode)

  -- Clean up the CoreFoundation object
  ffi.C.CFRelease(display_mode)

  -- Get the physical screen size in millimeters
  local screen_size = ffi.C.CGDisplayScreenSize(display_id)

  -- Convert millimeters to inches
  local width_in = screen_size.width / 25.4
  local height_in = screen_size.height / 25.4

  -- Calculate the diagonal size in pixels and inches
  local diagonal_px = math.sqrt(width_px * width_px + height_px * height_px)
  local diagonal_in = math.sqrt(width_in * width_in + height_in * height_in)

  -- Calculate PPI
  local ppi = diagonal_px / diagonal_in

  -- Output the result
  print(string.format("Width (px): %d", width_px))
  print(string.format("Height (px): %d", height_px))
  print(string.format("PPI: %.2f", ppi))
  -- TODO: linux version of this
  --     pcall(function()
  --         ffi.cdef([[
  --         typedef double CGFloat;
  --         typedef struct CGSize {
  --         CGFloat width;
  --         CGFloat height;
  --         } CGSize;
  --        ]])
  --     end)
  --     ffi.cdef([[
  --     typedef unsigned int uint32_t;
  --     typedef struct {
  --         double origin_x;
  --         double origin_y;
  --         double size_width;
  --         double size_height;
  --     } CGRect;
  --
  --     uint32_t CGMainDisplayID();
  --     size_t CGDisplayPixelsWide(uint32_t display_id);
  --     size_t CGDisplayPixelsHigh(uint32_t display_id);
  --     CGRect CGDisplayBounds(uint32_t display_id);
  --     struct CGSize CGDisplayScreenSize(uint32_t display_id);
  --     struct CGSize CGDisplaySize(uint32_t display);
  -- ]])
  --     -- Get the main display ID
  --     local display_id = ffi.C.CGMainDisplayID()
  --     -- Get the pixel dimensions
  --     local width_px = ffi.C.CGDisplayPixelsWide(display_id)
  --     print(tonumber(width_px))
  --     print(tostring(width_px))
  --     local screen_size = ffi.C.CGDisplayScreenSize(display_id)
  --     local screen_size2 = ffi.C.CGDisplayScreenSize(display_id)
  --     print(screen_size.width)
  --     print(screen_size2.width)
  --     local width_mm = tonumber(screen_size.width)
  --
  --     print("width_px: " .. width_px, " | width_mm: " .. screen_size.width)
  --
  --     local ppi = width_px / (width_mm / 25.4)
  --
  --     return math.floor(ppi)
end

return M
