local M = {}

M.options = {
    rules = {
        ["Constant"] = "SCREAMING_SNAKE_CASE",
        ["Module"] = "UpperCamelCase",
        ["Struct"] = "UpperCamelCase",
        ["AbstractType"] = "AbstractUpperCamelCase", -- i.e., PascalCase but with the first part always being "Abstract"
        ["Function"] = "snake_case",
    },
    defaultApproach = "treesitter", --or "lsp"
    lint_action = "quickfix", -- or "jump"
    -- projectRootFile: from the current directory, search upwards to find this file
    projectRootFile = "Project.toml",
    -- projectDirectory: from wherever the root file is, descend to this directory (and recurse) to find the location of the project files
    projectDirectory = "/src",
}

return M
