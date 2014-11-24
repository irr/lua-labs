#!/usr/bin/env lua

function trim(s)
    return s:match '^%s*(.-)%s*$'
end

function split(str)
    if not str then
        return {}
    end
    local t = {}
    local function helper(word) table.insert(t, word) return "" end
    if not str:gsub("%w+", helper):find"%S" then return t end
end

repeat
    local line = io.read("*line")
    if line then
        local words = split(trim(line))
        if words then
            for _, word in pairs(words) do
                print(string.format("%s\t%s", word, 1))
            end
        end
    end
until not line

        
