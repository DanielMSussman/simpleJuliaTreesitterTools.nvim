local M = {}

-- Why am I writing this instead of just using vim-abolish, or textcase.nvim, or ...
-- ???

function M.split_into_words(s)
    local separator = '_'

    --s1 through s3 swap or insert the separator for _, before capital letters, and try to respect acronyms
    local s1 = vim.fn.substitute(s, '[_.-]', separator, 'g')
    local s2 = vim.fn.substitute(s1, '\\v(\\l|\\d)@<=(\\u)', separator .. '\\2', 'g')
    local s3 = vim.fn.substitute(s2, '\\v(\\u)@<=(\\u\\l)', separator .. '\\2', 'g')

    return vim.split(s3, separator)
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

M.formatters = {
    UpperCamelCase = function(words)
        local parts = {}
        for _, word in ipairs(words) do
            table.insert(parts, M.capitalize(word))
        end
        return table.concat(parts, '')
    end,

    camelCase = function(words)
        local parts = { vim.fn.tolower(words[1]) }
        for i = 2, #words do
            table.insert(parts, M.capitalize(words[i]))
        end
        return table.concat(parts, '')
    end,

    snake_case = function(words)
        local parts = {}
        for _, word in ipairs(words) do
            table.insert(parts, vim.fn.tolower(word))
        end
        return table.concat(parts, '_')
    end,

    screaming_snake_case = function(words)
        local parts = {}
        for _, word in ipairs(words) do
            table.insert(parts, vim.fn.toupper(word))
        end
        return table.concat(parts, '_')
    end,
}

function M.convert(text, target_case)
    if not text or text == '' then return '' end

    local formatter = M.formatters[target_case]
    if not formatter then
        vim.notify('Unknown case: ' .. tostring(target_case), vim.log.levels.WARN)
        return text
    end

    local words = M.split_into_words(text)
    local result = formatter(words)
    return result
end

return M

-- Iterations of garbage

-- function H.is_not_snake_case(s)
--   return not s:match("^[a-z][a-z0-9]*(_[a-z][a-z0-9]*)*!?$")
-- end
--
-- function H.is_not_screaming_snake_case(s)
--   return not s:match("^[a-z][a-z0-9]*(_[a-z][a-z0-9]*)*!?$")
-- end
--
-- function H.is_not_upper_camel_case(s)
--   return not s:match("^[a-z][a-za-z0-9]*!?$")
-- end

-- function H.is_not_snake_case(s)
--   local pattern = vim.regex("^[[:lower:]][[:lower:]0-9]*(_[[:lower:]][[:lower:]0-9]*)*!?$")
--   return not pattern:match_str(s)
-- end
--
-- function H.is_not_screaming_snake_case(s)
--   local pattern = vim.regex("^[[:upper:]][[:upper:]0-9]*(_[[:upper:]][[:upper:]0-9]*)*!?$")
--   return not pattern:match_str(s)
-- end
--
-- function H.is_not_upper_camel_case(s)
--   local pattern = vim.regex("^[[:upper:]][[:alnum:]]*!?$")
--   return not pattern:match_str(s)
-- end

-- function H.to_snake_case(s)
--   return s:gsub("(%u)", function(c) return "_" .. c:lower() end)
--           :gsub("^_", "")
-- end
--
-- function H.to_upper_camel_case(s)
--   local str = s:gsub("_([a-z])", function(c) return c:upper() end)
--   return str:sub(1,1):upper() .. str:sub(2)
-- end
--
-- function H.to_screaming_snake_case(s)
--   local snake_cased = s:gsub("(%u)", function(c) return "_" .. c end):gsub("^_", "")
--   return snake_cased:upper()
-- end

