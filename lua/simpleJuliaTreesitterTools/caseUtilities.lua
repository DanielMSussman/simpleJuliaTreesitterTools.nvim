local M = {}

-- Why am I writing this instead of just using vim-abolish, or textcase.nvim, or ...
-- ???
-- vim.fn.tolower, etc, used for unicode

function M.split_word(s)
    local separator = '-'

    --s1 through s3 swap or insert the separator for _, before capital letters, and try to respect acronyms
    local s1 = vim.fn.substitute(s, '[_.-]', separator, 'g')
    local s2 = vim.fn.substitute(s1, '\\v(\\l|\\d)@<=(\\u)', separator .. '\\2', 'g')
    local s3 = vim.fn.substitute(s2, '\\v(\\u)@<=(\\u\\l)', separator .. '\\2', 'g')

    return vim.split(s3,separator)
end

function M.lowercase_except_acronyms(word)
    if #word > 1 and word == vim.fn.toupper(word) then
        return word -- Preserve acronyms
    end
    return vim.fn.tolower(word)
end

function M.capitalize(word)
    if not word or #word == 0 then return '' end
    if #word > 1 and word == vim.fn.toupper(word) then
        return word
    end
    local lower_word = vim.fn.tolower(word)
    local first_char = vim.fn.strcharpart(lower_word, 0, 1)
    local rest = vim.fn.strcharpart(lower_word, 1)
    return vim.fn.toupper(first_char) .. rest
end

--all formatters expect `words` to be a table split by the M.split_word function
M.formatters = {
    camelCase = function(words)
        if #words ==0 then return '' end
        local parts = { vim.fn.tolower(words[1]) }
        for i = 2, #words do
            table.insert(parts, M.capitalize(words[i]))
        end
        return table.concat(parts, '')
    end,

    UpperCamelCase = function(words)
        return table.concat(vim.tbl_map(M.capitalize, words), '')
    end,

    lowercase = function(words)
        local lower_words = vim.tbl_map(vim.fn.tolower,words)
        return table.concat(lower_words, '')
    end,

    UPPERCASE = function(words)
        local upper_words = vim.tbl_map(vim.fn.toupper,words)
        return table.concat(upper_words, '')
    end,

    snake_case = function(words)
        local lower_words = vim.tbl_map(vim.fn.tolower,words)
        return table.concat(lower_words, '_')
    end,

    SCREAMING_SNAKE_CASE = function(words)
        local upper_words = vim.tbl_map(vim.fn.toupper,words)
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

--This function converts text to the target case, preserving any leading underscores
function M.convert(text, target_case)
    if not text or text == '' then return '' end

    local formatter = M.formatters[target_case]
    if not formatter then
        vim.notify('Unknown case: ' .. tostring(target_case), vim.log.levels.WARN)
        return text
    end

    --underscore logic: find and strip leading underscores
    local prefix = ''
    local main_text = text
    local _, _, captured_prefix = string.find(main_text, "^(_+)")
    if captured_prefix then
        prefix = captured_prefix
        main_text = string.sub(main_text, #prefix + 1)
    end

    local words = M.split_word(main_text)
    local The_one_Right_trueFormattedTEXT = formatter(words)
    return prefix .. The_one_Right_trueFormattedTEXT
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
