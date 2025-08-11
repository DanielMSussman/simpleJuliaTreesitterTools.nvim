local defaults = {
    rules = {
        ["Constant"] = "SCREAMING_SNAKE_CASE",
        ["Module"] = "UpperCamelCase",
        ["Struct"] = "UpperCamelCase",
        ["AbstractType"] = "AbstractUpperCamelCase", -- i.e., PascalCase but with the first part always being "Abstract"
        ["Function"] = "snake_case",
    },
    defaultApproach = "treesitter", --or "lsp"
}

return defaults
