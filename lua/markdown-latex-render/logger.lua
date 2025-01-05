local config = require("markdown-latex-render.config")
local Logger = {}

local log_level = {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
}

--- @type "DEBUG" | "INFO" | "WARN" | "ERROR"
Logger.level = config.log_level
Logger.log_file = vim.fn.stdpath("log") .. "/markdown-latex-render.log"

--- @param msg string
local write_to_file = function(msg)
  local file, err = io.open(Logger.log_file, "a")
  if not file then
    error("Failed to open log file: " .. (err or "Unknown error"))
  end
  file:write(msg .. "\n")
  file:close()
end

--- @param level string
--- @param msg string
--- @return string
local format_message = function(level, msg)
  return string.format("[%s] %s: %s", os.date("%Y-%m-%d %H:%M:%S"), level, msg)
end

--- @param level "DEBUG" | "INFO" | "WARN" | "ERROR"
--- @param msg string
function Logger.log(level, msg)
  if log_level[level] >= log_level[Logger.level] then
    write_to_file(format_message(level, msg))
  end
end

--- @param msg string
function Logger.debug(msg)
  Logger.log("DEBUG", msg)
end

--- @param msg string
function Logger.info(msg)
  Logger.log("INFO", msg)
end

--- @param msg string
function Logger.warn(msg)
  Logger.log("WARN", msg)
end

--- @param msg string
function Logger.error(msg)
  Logger.log("ERROR", msg)
end

return Logger
