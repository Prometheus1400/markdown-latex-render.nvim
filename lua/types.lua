-- The idea behind the ImageApiInterface and ImageInterface is to make the code more generic to be able to hook up with other plugins but mainly for easier testing as getting a plugin
-- dependency available for tests does not seem that straightforward and with this I can more easily mock
--- @class markdown-latex-render.ImageApiInterface interface for the image api mainly the from_file method
--- @field from_file fun(path: string, opts?:table):markdown-latex-render.ImageInterface generates an ImageInterface type from an image file

--- @class markdown-latex-render.ImageInterface
--- @field render fun(self: markdown-latex-render.ImageInterface, geometry?: markdown-latex-render.ImageGeometry)
--- @field id string
--- @field path string
--- @field geometry markdown-latex-render.ImageGeometry
--- @field clear fun(self: markdown-latex-render.ImageInterface, shallow?: boolean)
--- @class markdown-latex-render.ImageGeometry
--- @field x integer
--- @field y integer

--- @class TSQueryResults
--- @field text string query result node text
--- @field line_start integer row location where the query result starts
--- @field line_end integer row location where the query result stops
