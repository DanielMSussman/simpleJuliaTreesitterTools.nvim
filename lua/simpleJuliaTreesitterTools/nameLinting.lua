local M = {}

local config = require("simpleJuliaTreesitterTools").get_options()
local lspUtilities = require("simpleJuliaTreesitterTools.lspUtilities")
local treesitterUtilities = require("simpleJuliaTreesitterTools.treesitterUtilities")


function M.find_buffer_violations()
    if config.defaultApproach == "lsp" and #(vim.lsp.get_clients()) >0 then
        vim.notify("The LSP approach is not really working yet. Sorry")
        lspUtilities.check_document_symbols()
    else
        treesitterUtilities.lint_buffer()
    end
end

function M.find_project_violations()
    if config.defaultApproach == "lsp" and #(vim.lsp.get_clients()) >0 then
        vim.notify("The LSP approach is not really working yet. Sorry")
        lspUtilities.check_document_symbols()
    else
        treesitterUtilities.lint_project()
    end
end

return M
