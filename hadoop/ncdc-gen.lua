#!/usr/bin/env lua

math.randomseed(os.time())

for i = 1, 10 do
    local file = io.open(string.format("sample%02d.data", i), "w")
    for j = 1900, 2014 do
        local t = math.random(100) + 20
        file:write(string.format("%d\t%d\n", j, t))
    end
    file:close()
end
