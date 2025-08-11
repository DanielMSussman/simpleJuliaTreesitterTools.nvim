-- Dear https://github.com/nvim-neorocks/nvim-best-practices,
-- I'm trying my best. Kind of.
local M = {}

local defaults = require("simpleJuliaTreesitterTools.config")
M.options = vim.deepcopy(defaults)

--optional setup --- only needed to change the default config
function M.setup(user_opts)
  M.options = vim.tbl_deep_extend("force", M.options, user_opts or {})
end


local name_linting

function M.lint_project_names()
    if not name_linting then
        name_linting = require("simpleJuliaTreesitterTools.nameLinting")
    end
    name_linting.find_project_violations()
end

function M.lint_buffer_names()
    if not name_linting then
        name_linting = require("simpleJuliaTreesitterTools.nameLinting")
    end
    name_linting.find_buffer_violations()
end


function M.test_func()
    vim.notify("testing stuff during development")
end

function M.get_options()
  return M.options
end

return M
