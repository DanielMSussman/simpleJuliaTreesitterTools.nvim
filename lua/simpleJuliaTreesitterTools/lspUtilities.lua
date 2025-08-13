local M = {}

-- This modules attempts to use the LSP to both identify symbols and 
-- rename them across the workspace. I find both to work only inconsistently
-- so far. Skill issue.
--
M.current_violation_index = 0
M.violations = {}

local caseUtilities = require("simpleJuliaTreesitterTools.caseUtilities")


function M.fix_next_violation(violations,current_violation)
    if not violations or #violations == 0 then
        vim.notify("No violations to fix.", vim.log.levels.INFO)
        return
    end

    local current_violation_index = (current_violation % #violations) + 1
    local violation = violations[current_violation_index]

    vim.api.nvim_win_set_cursor(0, { violation.line, violation.char })
    -- print(vim.inspect(violation))
    local suggested_name = violation.suggestedName

    vim.ui.input({
        prompt = "Rename (quit to cancel)'" .. violation.name .. "' to:",
        default = suggested_name,
    }, function(new_name)
            if not new_name or new_name == "" then
                vim.notify("Rename cancelled.", vim.log.levels.INFO)
                return
            end

            vim.lsp.buf.rename(new_name) -- inconsistent
        end)
end

function M.check_document_symbols(options,state)
    M.config = options
    M.current_violation_index = 0
    M.violations = {}
    -- the simpler local params = vim.lsp.util.make_text_document_params() didn't work?
    local params = { textDocument = { uri = vim.uri_from_bufnr(0), }, }

    local handler = function(err, symbols)
        if err or not symbols then
            vim.notify("LSP request failed: " .. vim.inspect(err), vim.log.levels.ERROR)
            return
        end

        for _,symbol in ipairs(symbols) do
            local kind_str = vim.lsp.protocol.SymbolKind[symbol.kind]
            local targetName = caseUtilities.target_name(symbol.name,kind_str,options.rules)

            if targetName and symbol.name ~= targetName then
                table.insert(M.violations, {
                    name = symbol.name,
                    suggestedName = targetName,
                    kind = kind_str,
                    line = symbol.range.start.line+1, -- treesitter is zero-indexed, but neovim lines are 1-indexed
                    char = symbol.range.start.character
                })
            end
        end

        if #M.violations > 0 then
            vim.notify(#M.violations.." violation(s) found")
            -- print(vim.inspect(M.violations[1]))
            M.current_violation_index = 0
            M.fix_next_violation(M.violations,M.current_violation_index)
        end
    end

    vim.lsp.buf_request(0, 'textDocument/documentSymbol', params, handler)
end

return M
