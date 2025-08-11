local H = {}

function H.create_lookup_table(list)
    local lookup = {}
    for _, item in ipairs(list) do
        lookup[item.name] = true
    end
    return lookup
end

function H.populateQuickfixList(violations)
    if not violations or #violations == 0 then
        vim.notify("No naming convention violations found", vim.log.levels.INFO)
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

return H
