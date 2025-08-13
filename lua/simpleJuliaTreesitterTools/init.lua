-- Dear https://github.com/nvim-neorocks/nvim-best-practices,
-- I'm trying my best. Kind of.
local M = {}

local helpers = require("simpleJuliaTreesitterTools.helperFunctions")
local name_linting = require("simpleJuliaTreesitterTools.nameLinting")
local defaults = require("simpleJuliaTreesitterTools.defaultsAndData")

M.options = vim.deepcopy(defaults.options)
M.state = {
    violations = {},
    current_violation_index = 0
}

--optional setup --- only needed to change the default config
function M.setup(user_opts)
  M.options = vim.tbl_deep_extend("force", M.options, user_opts or {})
end


function M.lint_buffer_names()
    name_linting.find_buffer_violations(M.options,M.state)
end

function M.lint_project_names()
    name_linting.find_project_violations(M.options,M.state)
end

function M.cycle_violations()
    helpers.jump_to_next_violation(M.state) -- only useful if you've opted into "jump" rather than "quickfix"
end


-- used to monkey around during development
function M.test_func()
    vim.notify("testing stuff during development")
end

return M
