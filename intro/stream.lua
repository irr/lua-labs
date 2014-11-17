function split(s, delimiter)
    if not delimiter or delimiter == "" then
        return s
    end
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

local line, t = nil, nil

repeat
    line = io.stdin:read("*line")
    if line then
        t = split(line, "\t")
        if next(t) and #t > 1 then 
            print(string.format("%s (%d)", line, #t))
        end
    end
until not line
