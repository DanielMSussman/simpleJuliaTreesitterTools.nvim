-- Dear https://github.com/nvim-neorocks/nvim-best-practices,
-- I'm trying my best. Kind of.
local M = {}

local helpers
local modules
local types
local variables
local functions


function M.process_queries()
    if not helpers then
        helpers = require("simpleJuliaTreesitterTools.helperFunctions")
    end
    modules = helpers.find_first_occurrence_of_query("modules","module.name",{})

    types = helpers.find_first_occurrence_of_query("types","type.name",{})
    local typeLookup = helpers.create_lookup_table(types)
    functions = helpers.find_first_occurrence_of_query("functions","function.usage",typeLookup)
    variables = helpers.find_first_occurrence_of_query("variables","variable.usage",typeLookup)
end

function M.reset()
    modules = {}
    types = {}
    variables = {}
    functions = {}
    M.process_queries()
end

function M.find_type_names()
    if not types then
        M.process_queries()
    end
    helpers.cycleCursor(types,helpers.is_not_upper_camel_case)
end
function M.find_module_names()
    if not modules then
        M.process_queries()
    end
    helpers.cycleCursor(modules,helpers.is_not_upper_camel_case)
end

function M.find_variables_names()
    if not variables then
        M.process_queries()
    end
    helpers.cycleCursor(variables,helpers.is_not_snake_case)
end
function M.find_function_names()
    if not functions then
        M.process_queries()
    end
    helpers.cycleCursor(functions,helpers.is_not_snake_case)
end

function M.test_lsp()
    if not helpers then
        helpers = require("simpleJuliaTreesitterTools.helperFunctions")
    end
    helpers.check_document_symbols()
end

function M.fix_next_violation()
    if not helpers then
        helpers = require("simpleJuliaTreesitterTools.helperFunctions")
    end
    if not helpers.checked then
        helpers.check_document_symbols()
    end

    helpers.fix_next_violation()
end

return M
