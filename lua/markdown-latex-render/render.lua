    local img_api = require("image")
local query = require("markdown-latex-render.query")
local image_generator = require("markdown-latex-render.image-generator")
local images = require("markdown-latex-render.images")

M = {}

--- @param buf integer
--- @param win integer
--- @param key string
--- @param img_path string
--- @param row integer
--- @param old_image? Image
local render_img = function(buf, win, key, img_path, row, old_image)
    local image = img_api.from_file(img_path, {
        id = key,
        window = win,
        buffer = buf,
        with_virtual_padding = true,
        inline = true,

        -- geometry (optional)
        -- TODO: a way to center the image in the window
        -- x = vim.api.nvim_win_get_width(0) / 2,
        y = row,
        width = 50,
        height = 50
    })
    if not image then
        print("failed to render image " .. img_path)
    else
        image:render()
        if old_image then
            print("unrendering old image " .. old_image.id)
            images._clear_registered_image(buf, old_image.id)
        end
        images.register_image(buf, key, image)
    end
end
M.render = render_img


--- @param buf integer
--- @param win integer
--- @param results TSQueryResults[]
local handle_latex_query_results = function(buf, win, results)
    for _, result in ipairs(results) do
        local latex = result.latex
        local key = latex:gsub("%s+", "")
        local name = key .. "-" .. buf .. ".png"
        local row = result.pos.r_end

        -- if image with key already generated then don't need to rerender
        -- key comes from the latex so if it doesn't semantically change it
        -- will be the same
        if images._image_already_rendered(buf, key) then
            goto continue
        end

        -- get the old image we need to unrender
        local old_image = images._get_image_at_location(buf, row)
        -- if not old_image then
        --     print("no old image found")
        -- else
        --     print("image found")
        -- end
        image_generator._generate_image(latex, name, function(code, img_path)
            if code == 0 then
                print("trying to load image!")
                vim.schedule(function()
                    render_img(buf, win, key, img_path, row, old_image)
                end)
            end
        end, {})
        ::continue::
    end
end

--- @param buf? integer
--- @param win? integer
local render_buf = function(buf, win)
    buf = buf or vim.api.nvim_get_current_buf()
    win = win or vim.api.nvim_get_current_win()

    local results = query._query_latex_in_buf(buf)
    handle_latex_query_results(buf, win, results)
end
M.render_buf = render_buf

--- @param buf? integer
--- @param win? integer
local render_at_cursor = function(buf, win)
    buf = buf or vim.api.nvim_get_current_buf()
    win = win or vim.api.nvim_get_current_win()

    local results = query._query_latex_at_cursor(buf, win)
    handle_latex_query_results(buf, win, results)
end
M.render_at_cursor = render_at_cursor

--- @param buf? integer
local rerender_buf = function(buf)
    buf = buf or vim.api.nvim_get_current_buf()

    images._rerender_images_in_buf(buf)
end
M.rerender_buf = rerender_buf


M._setup_autocommands = function()
    vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("MarkdownLatexRenderVimEnter", { clear = true }),
        pattern = "*.md",
        callback = function(event)
            vim.defer_fn(function()
                render_buf(event.buf)
            end, 100)
        end,
    })
    -- TODO: figure out how to render once on opening buffer for the first time
    -- the challenge is it needs to run only after Treesitter has parsed
    vim.api.nvim_create_autocmd("BufNew", {
        group = vim.api.nvim_create_augroup("MarkdownLatexRenderBufNew", { clear = true }),
        pattern = "*.md",
        callback = function(event)
            vim.defer_fn(function()
                render_buf(event.buf)
            end, 100)
        end,
    })
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("MarkdownLatexRenderBufWritePost", { clear = true }),
        pattern = "*.md",
        callback = function()
            render_buf()
        end,
    })

    -- vim.api.nvim_create_autocmd("TextChanged", {
    --     group = vim.api.nvim_create_augroup("MarkdownLatexRenderTextChanged", { clear = true }),
    --     pattern = "*.md",
    --     callback = function(event)
    --         -- if query._in_latex_section(event.buf, vim.api.nvim_get_current_win()) then
    --             render_buf()
    --         -- end
    --     end,
    -- })
    -- vim.api.nvim_create_autocmd("InsertLeave", {
    --     group = vim.api.nvim_create_augroup("MarkdownLatexRenderInsertLeave", { clear = true }),
    --     pattern = "*.md",
    --     callback = function(event)
    --         -- if query._in_latex_section(event.buf, vim.api.nvim_get_current_win()) then
    --             render_buf()
    --         -- end
    --     end,
    -- })

    -- this is for rerendering images when navigating back to a buffer that already has
    -- generated those images (just displaying them again)
    vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("MarkdownLatexRenderBufEnter", { clear = true }),
        pattern = "*.md",
        callback = function()
            rerender_buf()
        end,
    })

    -- clean up images when buffer closes
    vim.api.nvim_create_autocmd("BufUnload", {
        group = vim.api.nvim_create_augroup("MarkdownLatexRenderBufUnload", { clear = true }),
        pattern = "*.md",
        callback = function(event)
            images._clear_registered_images(event.buf)
        end,
    })
end

return M
