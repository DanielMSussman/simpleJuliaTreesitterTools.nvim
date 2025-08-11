local C = {}

C.options = {}

local defaults = {
    rules = {
        ["Struct"] = "UpperCamelCase",
        ["Module"] = "UpperCamelCase",
        ["Function"] = "snake_case",
        ["Constant"] = "screaming_snake_case",
    },
}

function C.setup(user_opts)
    C.options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), user_opts or {})
end

C.setup()

return C
