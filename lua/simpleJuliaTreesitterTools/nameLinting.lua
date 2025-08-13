local M = {}

local lspUtilities = require("simpleJuliaTreesitterTools.lspUtilities")
local treesitterUtilities = require("simpleJuliaTreesitterTools.treesitterUtilities")


function M.find_buffer_violations(options,state)
    if options.defaultApproach == "lsp" and #(vim.lsp.get_clients()) >0 then
        vim.notify("The LSP approach is not really working yet. Sorry")
        lspUtilities.check_document_symbols(options,state)
    else
        treesitterUtilities.lint_buffer(options,state)
    end
end

function M.find_project_violations(options,state)
    if options.defaultApproach == "lsp" and #(vim.lsp.get_clients()) >0 then
        vim.notify("The LSP approach is not really working yet. Sorry")
        lspUtilities.check_document_symbols(options)
    else
        treesitterUtilities.lint_project(options,state)
    end
end

return M
