#!/usr/bin/env lua

function trim(s)
    return s:match '^%s*(.-)%s*$'
end

function split(s, delimiter)
    if not delimiter or delimiter == "" then
        return s
    end
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return unpack(result)
end

local current_word = nil
local current_count = 0
local word = nil
local count = nil

repeat
    local line = io.read("*line")
    if line then
        word, count = split(trim(line), "\t")
        count = tonumber(count)
        if word and count then
            if current_word == word then
                current_count = current_count + count
            else
                if current_word then
                    print(string.format("%s\t%s", current_word, current_count))
                end
                current_count = count
                current_word = word
            end
        end
    end
until not line

if current_word == word then
    print(string.format("%s\t%s", current_word, current_count))
end

    

        
