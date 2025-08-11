local H = {}

local config = require("simpleJuliaTreesitterTools.config")
local caseUtilities = require("simpleJuliaTreesitterTools.caseUtilities")

H.violations={}
H.current_violation_index = 0
H.checked = false

--given a name, the kind, and the rules... what should the name be
function H.target_name(name,kind,rules_table)
    local target_case = rules_table[kind]

    -- what is not forbidden is allowed
    if not target_case then
        return nil
    end

    result = caseUtilities.convert(name, target_case)
    vim.notify(target_case.."  "..result)
    return result
end

function H.fix_next_violation()
    local violations = H.violations
    if not violations or #violations == 0 then
        vim.notify("No violations to fix.", vim.log.levels.INFO)
        return
    end

    H.current_violation_index = (H.current_violation_index % #violations) + 1
    local violation = violations[H.current_violation_index]

    vim.api.nvim_win_set_cursor(0, { violation.line, violation.char })
    print(vim.inspect(violation))
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

function H.create_lookup_table(list)
    local lookup = {}
    for _, item in ipairs(list) do
        lookup[item[3]] = true
    end
    return lookup
end

function H.find_all_occurrences_of_query(q,capture_target)

    local query = vim.treesitter.query.get("julia", q)
    local iterCaptures = query:iter_captures(vim.treesitter.get_node():root(),0)


    local query_names = {}
    for id, node, _, _ in iterCaptures do
        local capture_name = query.captures[id]
        if capture_name == capture_target then
            local nodeStartingRow, nodeStartingCol = node:start() -- TS is zero-indexed, neovim lines are 1-indexed
            table.insert(query_names,{nodeStartingRow+1,nodeStartingCol})
        end
    end
    return query_names
end

function H.find_first_occurrence_of_query(q,capture_target,reject_table)

    local query = vim.treesitter.query.get("julia", q)
    local iterCaptures = query:iter_captures(vim.treesitter.get_node():root(),0)


    local query_names = {}
    local seen_names = {}

    for id, node, _, _ in iterCaptures do
        local capture_name = query.captures[id]
        local node_text = vim.treesitter.get_node_text(node, 0)
        if capture_name == capture_target then
            if not seen_names[node_text] and not reject_table[node_text] then
                seen_names[node_text] = true
                local row, col = node:start()
                table.insert(query_names,{row+1,col,node_text})
            end
        end
    end
    return query_names
end

function H.cycleCursor(targets,condition_fn)
    local currentCursorLine = vim.api.nvim_win_get_cursor(0)[1]
    local valid_targets = {}
    for _, target in ipairs(targets) do
        if condition_fn(target[3]) then
            table.insert(valid_targets, target)
        end
    end
    if #valid_targets == 0 then
        return
    end
    local target
    if currentCursorLine < valid_targets[1][1] then
        target = {valid_targets[1][1],valid_targets[1][2]}
    elseif currentCursorLine > valid_targets[#valid_targets][1] then
        target = {valid_targets[#valid_targets][1],valid_targets[#valid_targets][2]}
    else
        local foundCurrent = nil
        for i = 1, #valid_targets do
            if foundCurrent and valid_targets[i][1]~= currentCursorLine then
                target = {valid_targets[i][1],valid_targets[i][2]}
                break
            end

            if valid_targets[i][1] >= currentCursorLine then
                foundCurrent = true
            end
        end
        if not target and foundCurrent and valid_targets[1][1] ~= currentCursorLine then
            target = {valid_targets[1][1],valid_targets[1][2]}
        end

    end
    if target then
        vim.api.nvim_win_set_cursor(0, target)
    end
end


function H.check_document_symbols()
    H.current_violation_index = 0
    H.violations = {}
    -- the simpler local params = vim.lsp.util.make_text_document_params() didn't work?
    local params = { textDocument = { uri = vim.uri_from_bufnr(0), }, }

    local handler = function(err, symbols)
        if err or not symbols then
            vim.notify("LSP request failed: " .. vim.inspect(err), vim.log.levels.ERROR)
            return
        end

        for _,symbol in ipairs(symbols) do
            local kind_str = vim.lsp.protocol.SymbolKind[symbol.kind]
            local targetName = H.target_name(symbol.name,kind_str,config.options.rules)

            if targetName and symbol.name ~= targetName then
                table.insert(H.violations, {
                    name = symbol.name,
                    suggestedName = targetName,
                    kind = kind_str,
                    line = symbol.range.start.line+1, -- treesitter is zero-indexed, but neovim lines are 1-indexed
                    char = symbol.range.start.character
                })
            end
        end

        H.checked = true

        if #H.violations > 0 then
            vim.notify(#H.violations.." violation(s) found")
            -- print(vim.inspect(H.violations[1]))
            H.fix_next_violation()
        end
    end

    vim.lsp.buf_request(0, 'textDocument/documentSymbol', params, handler)
end

return H
