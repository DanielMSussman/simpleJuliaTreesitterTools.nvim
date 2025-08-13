local H = {}

function H.create_lookup_table(lists)
    local lookup = {}
    for _,list in pairs(lists) do
        for _, item in ipairs(list) do
            if item.name then
                lookup[item.name] = true
            else
                lookup[item] = true
            end
        end
    end
    return lookup
end

function H.sort_violations(violations)
    table.sort(violations, function(a, b)
        if a.filepath == b.filepath then
            return a.line < b.line
        else
            return a.filepath < b.filepath
        end
    end)
    return violations
end

function H.populateQuickfixList(violations)
    if not violations or #violations == 0 then
        return
    end

    local qf_list = {}
    for _, item in ipairs(violations) do
        local description = string.format("%s '%s' should be '%s'", item.nameType, item.name, item.suggestedName)

        table.insert(qf_list, {
            filename = item.filepath,
            lnum = item.line,
            col = item.char,
            text = description,
        })
    end

    vim.fn.setqflist(qf_list)
    vim.cmd.copen()
end

function H.jump_to_next_violation(state)
    if not state.violations or #state.violations == 0 then
        return
    end
    state.current_violation_index = state.current_violation_index % #state.violations + 1
    local violation = state.violations[state.current_violation_index]

    if vim.fn.expand('%:p') ~= vim.fn.expand(violation.filepath) then
        vim.cmd.edit(vim.fn.expand(violation.filepath))
    end

    vim.api.nvim_win_set_cursor(0, { violation.line, violation.char })

    vim.notify(string.format("Violation %d/%d: %s '%s' should be '%s'",
        state.current_violation_index, #state.violations, violation.nameType, violation.name,violation.suggestedName),
        vim.log.levels.WARN)
end

function H.lint_action(violations,options,state)
    local sorted_violations = H.sort_violations(violations)
    if options.lint_action == "quickfix" then
        H.populateQuickfixList(sorted_violations)
    elseif options.lint_action == "jump" then
        state.violations = sorted_violations
        state.current_violation_index = 0
        H.jump_to_next_violation(state)
    end
end


return H
