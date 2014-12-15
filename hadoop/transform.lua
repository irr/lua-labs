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

repeat
    local line = io.read("*line")
    if line then
        year, temperature = split(trim(line), "\t")
        if year and temperature then
            if tonumber(year) > 2000 then
                print(string.format("%s\t%s", tostring(year), tostring(tonumber(temperature) + 1000)))
            end
        end
    end
until not line

    

        
