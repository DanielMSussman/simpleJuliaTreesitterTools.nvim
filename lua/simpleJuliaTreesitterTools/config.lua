local defaults = {
    rules = {
        ["Constant"] = "screaming_snake_case",
        ["Module"] = "UpperCamelCase",
        ["Struct"] = "UpperCamelCase",
        ["AbstractType"] = "UpperCamelCase", -- eventually implement a rule for this, like "must start with abstract"?
        ["Function"] = "snake_case",
    },
    defaultApproach = "treesitter", --or "lsp"
}

return defaults
