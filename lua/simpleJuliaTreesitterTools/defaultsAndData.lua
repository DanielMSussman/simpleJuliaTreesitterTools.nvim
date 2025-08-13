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

-- knowing the primitive types lets you cheat a little bit when writing treesitter queries
-- Also, in code if you write something like `function Base.Int(...)` it would otherwise be 
-- picked up. The list below comes from testing the code on a handful of popular repos and 
-- finding spurious violations. These aren't all primitive types; the name isn't great.
M.PrimitiveTypes = {
    "AbstractChar",  "AbstractString", "Any", "Nothing", "Missing",
    "Char", "String", "Symbol", "Number", "Real", "Integer", "Bool",
    "Unsigned",  "UInt8", "UInt16", "UInt32" ,"UInt64","UInt128",
    "Signed",  "Int", "Int8", "Int16", "Int32" ,"Int64","Int128", "BigInt",
    "AbstractFloat", "Float", "Float16", "Float32", "Float64", "BigFloat",
    "Complex", "ComplexF16", "ComplexF32", "ComplexF64",
}

return M
