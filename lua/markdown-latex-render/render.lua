local config = require("markdown-latex-render.config")
local image_api = require("markdown-latex-render.image_api")
local image_cache = require("markdown-latex-render.image_cache")
local image_generator = require("markdown-latex-render.image_generator")
local logger = require("markdown-latex-render.logger")
local ts = require("markdown-latex-render.treesitter")

local M = {}

--- @param buf integer
--- @param win integer
--- @param key string
--- @paeam img_path string
--- @param line_num integer
--- @param old_images? markdown-latex-render.ImageInterface[]
function M._render_img(buf, win, key, img_path, line_num, old_images)
  local image = image_api.from_file(img_path, {
    id = key,
    window = win,
    buffer = buf,
    with_virtual_padding = true,
    y = line_num,
    x = 0,
  })
  if not image then
    logger.error("failed to render image " .. key .. " from " .. img_path)
  else
    if old_images then
      for _, old_image in ipairs(old_images) do
        image_cache._clear_registered_image(buf, old_image.id, 0)
      end
    end
    vim.defer_fn(function()
      image:render()
    end, 10)
    image_cache.register_image(buf, key, image)
  end
end

--- @param buf integer
--- @param win integer
--- @param results TSQueryResults[]
local handle_latex_query_results = function(buf, win, results)
  for i, result in ipairs(results) do
    local latex = result.text
    local key = latex:gsub("%s+", "") .. "-" .. buf .. "-" .. i
    local name = key .. ".png"
    local line_num = result.line_end

    -- if image with key already generated then don't need to rerender
    -- key comes from the latex so if it doesn't semantically change it
    -- will be the same
    if image_cache._image_already_registered(buf, key) then
      goto continue
    end

    -- get the old image we need to unrender
    local old_images = image_cache._get_images_at_location(buf, line_num)
    image_generator._generate_image(latex, name, function(code, img_path)
      if code == 0 then
        logger.debug("trying to render image for key " .. key .. " at path " .. img_path)
        vim.schedule(function()
          M._render_img(buf, win, key, img_path, line_num, old_images)
        end)
      end
    end, {})
    ::continue::
  end
end

-- --- @param buf? integer
-- --- @param win? integer
-- function M.render_at_cursor(buf, win)
--     buf = buf or vim.api.nvim_get_current_buf()
--     win = win or vim.api.nvim_get_current_win()
--     local results = query._query_latex_at_cursor(buf, win)
--     handle_latex_query_results(buf, win, results)
-- end

--- @param buf integer
function M._show_images_in_buf(buf)
  image_cache._rerender_images_in_buf(buf)
end

--- renders and rerenders changed expressions in buf
--- @param buf? integer
--- @param win? integer
--- @param only_visible_area? boolean
function M.render_buf(buf, win, only_visible_area)
  buf = buf or vim.api.nvim_get_current_buf()
  win = win or vim.api.nvim_get_current_win()
  only_visible_area = only_visible_area or false

  local results = nil
  if only_visible_area then
    local cur_line = vim.api.nvim_win_get_cursor(win)[1]
    local lower_bound = math.max(cur_line - math.floor(vim.api.nvim_win_get_height(win) / 2), 0)
    local upper_bound = cur_line + math.floor(vim.api.nvim_win_get_height(win) / 2)
    results = ts._query_latex_in_buf(buf, lower_bound, upper_bound)
  else
    results = ts._query_latex_in_buf(buf)
  end

  -- go through all the results and delete any images that are no longer applicable
  handle_latex_query_results(buf, win, results)
  image_cache._delete_unused_by_location(buf, results)
end

--- unrenders the entire buffer
--- @param buf? integer
function M.unrender_buf(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  image_cache._clear_registered_images(buf)
end

--- rerenders the entire buffer
--- @param buf? integer
function M.rerender_buf(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  M.unrender_buf(buf)
  M.render_buf(buf)
end

function M._setup_auto_commands()
  -- VimEnter and BufNew together cover the events for a markdown file getting loaded for the first time
  -- need to defer execution of 'render_buf' here to give treesitter time to parse the file
  if config.render and config.render.on_open then
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("MarkdownLatexRenderVimEnter", { clear = true }),
      pattern = "*.md",
      callback = function(event)
        vim.defer_fn(function()
          M.render_buf(event.buf)
        end, 100)
      end,
    })
    vim.api.nvim_create_autocmd("BufNew", {
      group = vim.api.nvim_create_augroup("MarkdownLatexRenderBufNew", { clear = true }),
      pattern = "*.md",
      callback = function(event)
        vim.defer_fn(function()
          M.render_buf(event.buf)
        end, 100)
      end,
    })
  end

  if config.render and config.render.on_write then
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("MarkdownLatexRenderBufWritePost", { clear = true }),
      pattern = "*.md",
      callback = function(event)
        -- TODO: instead of rendering the entire buffer
        -- should probably render only the visible expressions in that buffer
        if config.render.on_write == "render" then
          M.render_buf(event.buf)
        elseif config.render.on_write == "rerender" then
          M.rerender_buf(event.buf)
        else
          error("invalid option " .. config.render.on_write .. " passed to config.render.on_write")
        end
      end,
    })
  end

  vim.api.nvim_create_autocmd("TextChanged", {
    group = vim.api.nvim_create_augroup("MarkdownLatexRenderTextChanged", { clear = true }),
    pattern = "*.md",
    callback = function(event)
      local win = vim.api.nvim_get_current_win()
      local res = ts._cursor_in_latex(event.buf, win)
      print(res)
      M.render_buf(event.buf, win, true)
    end,
  })
  -- vim.api.nvim_create_autocmd("InsertLeave", {
  --     group = vim.api.nvim_create_augroup("MarkdownLatexRenderInsertLeave", { clear = true }),
  --     pattern = "*.md",
  --     callback = function(event)
  --         local win = vim.api.nvim_get_current_win()
  --         M.render_buf(event.buf, win, true)
  --     end,
  -- })

  -- this is for rerendering images when navigating back to a buffer that already has
  -- generated those images (just displaying them again)
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("MarkdownLatexRenderBufEnter", { clear = true }),
    pattern = "*.md",
    callback = function(event)
      M._show_images_in_buf(event.buf)
    end,
  })

  -- clean up images when buffer closes
  vim.api.nvim_create_autocmd("BufUnload", {
    group = vim.api.nvim_create_augroup("MarkdownLatexRenderBufUnload", { clear = true }),
    pattern = "*.md",
    callback = function(event)
      M.unrender_buf(event.buf)
    end,
  })
end

function M._setup_user_commands()
  vim.api.nvim_create_user_command("MarkdownLatexRender", function(opts)
    local arg = opts.args
    local buf = vim.api.nvim_get_current_buf()
    if arg == "rerender" then
      M.rerender_buf(buf)
    elseif arg == "render" then
      local win = vim.api.nvim_get_current_win()
      M.render_buf(buf)
    elseif arg == "unrender" then
      M.unrender_buf(buf)
    else
      error("invalid argument for 'MarkdownLatexRender'")
    end
  end, {
    nargs = 1,
    complete = function()
      return { "render", "rerender", "unrender" }
    end,
    desc = "render (detect changes and rerender updated expressions), rerender (forcably unrender then render), unrender (stop displaying anything)",
  })
end

return M
