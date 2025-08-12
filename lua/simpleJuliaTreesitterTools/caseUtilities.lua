local M = {}

-- Why am I writing this instead of just using vim-abolish, or textcase.nvim, or ...
-- ???
-- vim.fn.tolower, etc, used for unicode

function M.split_and_lowercase(s)
    local separator = '\0'

    --s1 through s3 swap or insert the separator for _, before capital letters, and try to respect acronyms
    local s1 = vim.fn.substitute(s, '[_.-]', separator, 'g')
    local s2 = vim.fn.substitute(s1, '\\v(\\l|\\d)@<=(\\u)', separator .. '\\2', 'g')
    local s3 = vim.fn.substitute(s2, '\\v(\\u)@<=(\\u\\l)', separator .. '\\2', 'g')

    local words = vim.split(s3,separator)
    return vim.tbl_map(vim.fn.tolower, words)
end

function M.capitalize(word)
    if not word or #word == 0 then return '' end
    if #word > 1 and word == vim.fn.toupper(word) then
        return word -- Preserve acronym like "HTTP"
    end
    local lower_word = vim.fn.tolower(word)
    local first_char = vim.fn.strcharpart(lower_word, 0, 1)
    local rest = vim.fn.strcharpart(lower_word, 1)
    return vim.fn.toupper(first_char) .. rest
end

--all formatters expect `words` to be a table of lowercase symbols
M.formatters = {
    camelCase = function(words)
        local parts = { words[1] }
        for i = 2, #words do
            table.insert(parts, M.capitalize(words[i]))
        end
        return table.concat(parts, '')
    end,

    UpperCamelCase = function(words)
        return table.concat(vim.tbl.map(M.capitalize, words), '')
    end,

    snake_case = function(words)
        return table.concat(words, '_')
    end,

    SCREAMING_SNAKE_CASE = function(words)
        local upper_words = vim.tbl.map(vim.fn.toupper,words)
        return table.concat(upper_words, '_')
    end,

    AbstractUpperCamelCase = function(words)
        local result = M.formatters.UpperCamelCase(words)
        if string.match(result, "^Abstract") then
            return result
        else
            return "Abstract" .. result
        end
    end,

}

function M.convert(text, target_case)
    if not text or text == '' then return '' end

    local formatter = M.formatters[target_case]
    if not formatter then
        vim.notify('Unknown case: ' .. tostring(target_case), vim.log.levels.WARN)
        return text
    end

    local words = M.split_and_lowercase(text)
    local theThe_one_Right_trueFormatting = formatter(words)
    return theThe_one_Right_trueFormatting
end

--given a name, the kind, and the rules... what should the name be
function M.target_name(name,kind,rules_table)
    local target_case = rules_table[kind]

    -- what is not forbidden is allowed
    if not target_case then
        return nil
    end

    local result = M.convert(name, target_case)
    -- vim.notify(target_case.."  "..result)
    return result
end

return M
