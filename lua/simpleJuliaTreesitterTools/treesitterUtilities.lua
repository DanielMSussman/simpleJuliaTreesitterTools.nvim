local M = {}

local config = require("simpleJuliaTreesitterTools").get_options()
local caseUtilities = require("simpleJuliaTreesitterTools.caseUtilities")
local helpers = require("simpleJuliaTreesitterTools.helperFunctions")

function M.find_first_occurrence_of_query(root_node,q,capture_target,reject_table,fileString)

    local query = vim.treesitter.query.get("julia", q)
    local iterCaptures = query:iter_captures(root_node,fileString)


    local query_names = {}
    local seen_names = {}

    for id, node, _, _ in iterCaptures do
        local capture_name = query.captures[id]
        local node_text = vim.treesitter.get_node_text(node, fileString)
        if capture_name == capture_target then
            if not seen_names[node_text] and not reject_table[node_text] then
                seen_names[node_text] = true
                local row, col = node:start()
                table.insert(query_names,{line = row+1,char = col,name = node_text})
            end
        end
    end
    return query_names
end

function M.process_query_over_trees(trees,queryDefinition,captureGroupTarget,rejectList,nameType)
    local allItems = {}
    for _, item in ipairs(trees) do
        local filepath = item[1]
        local root_node = item[2]
        local fileString = 0
        if item[3] ~= nil then
            fileString = item[3]
        end
        local items = M.find_first_occurrence_of_query(root_node,queryDefinition,captureGroupTarget,rejectList,fileString)
        for _, info in ipairs(items) do
            local suggestedName = caseUtilities.convert(info.name,config.rules[nameType])
            table.insert(allItems, {
                filepath = filepath,
                line = info.line,
                char = info.char,
                name = info.name,
                nameType = nameType,
                suggestedName = suggestedName
            })
        end
    end
    return allItems
end

-- in processing a list of {filename, tree roots}, we need to first look for type declarations, then use those to filter out functions
function M.process_trees(trees)
    local all_types = M.process_query_over_trees(trees,"types","type.definition",{},"Struct")
    local all_abstract_types = M.process_query_over_trees(trees,"types","abstracttype.definition",{},"AbstractType")
    for _, item in ipairs(all_abstract_types) do
        table.insert(all_types, item)
    end

    local typeLookup = helpers.create_lookup_table(all_types)

    local primitive_types = {
        "AbstractChar", "AbstractFloat", "AbstractString", "Bool", "Char",
        "ComplexF16", "ComplexF32", "ComplexF64", "Float16", "Float32", "Float64",
        "Int128", "Int16", "Int32", "Int64", "Int8", "Integer","Int", "Number",
        "Real", "Signed", "String", "Symbol", "UInt128", "UInt16", "UInt32",
        "UInt64", "UInt8", "Unsigned", "Nothing", "Missing", "Any"
    }

    for _, type_name in ipairs(primitive_types) do
        typeLookup[type_name] = true
    end

    local all_modules = M.process_query_over_trees(trees,"modules","module.definition",{},"Module")

    local all_functions = M.process_query_over_trees(trees,"functions","function.definition",typeLookup,"Function")

    local all_constants = M.process_query_over_trees(trees,"constants","constant.definition",typeLookup,"Constant")

    return {
        modules = all_modules,
        types = all_types,
        constants = all_constants,
        functions = all_functions
    }
end

function M.lint_buffer()
    local root = vim.treesitter.get_node():root()
    local filename = vim.api.nvim_buf_get_name(0)
    if not root then return {} end

    local results = M.process_trees({{filename,root}})
    local violations = {}
    for _,list in pairs(results) do
        for _,item in ipairs(list) do
            if item.name ~= item.suggestedName then
                table.insert(violations,item)
            end
        end
    end
    helpers.populateQuickfixList(violations)
end

---(eventually) Asynchronously lints all .jl files in the project's `src` directory.
function M.lint_project()
    vim.notify("Starting project-wide lint...", vim.log.levels.INFO)

    local project_toml_path = vim.fs.find({ "Project.toml" }, { upward = true, type = "file" })[1]
    if not project_toml_path then
        vim.notify("No Project.toml found. Aborting lint.", vim.log.levels.WARN)
        return
    end

    local project_root = vim.fs.dirname(project_toml_path)
    local src_path = project_root .. "/src"

    --having problems with cross-platform vim.fs.find? I'm sure this is trivially fixable, but this is fine for now
    local all_files_in_src = vim.fs.find(function() return true end, { path = src_path, type = "file",limit = math.huge })
    local julia_files = {}
    if all_files_in_src then
        for _, filepath in ipairs(all_files_in_src) do
            if filepath:match("%.jl$") then
                table.insert(julia_files, filepath)
            end
        end
    end

    if not julia_files or #julia_files == 0 then
        vim.notify("No Julia files found in the 'src' directory.", vim.log.levels.WARN)
        return
    end

    local trees = {}
    for _, filepath in ipairs(julia_files) do
        local content = vim.fn.readfile(filepath)
        local fileString = table.concat(content,"\n")
        local parser = vim.treesitter.get_string_parser(fileString,"julia")
        local tree = parser:parse()
        if tree then
            table.insert(trees, { filepath, tree[1]:root(),fileString })
        end
    end

    local results = M.process_trees(trees)

    local violations = {}
    for _, list in pairs(results) do
        for _, item in ipairs(list) do
            if item.name ~= item.suggestedName then
                table.insert(violations, item)
            end
        end
    end

    helpers.populateQuickfixList(violations)
    vim.notify( "Project linting complete. Found " .. #violations .. " violations.", vim.log.levels.INFO)
end

return M
