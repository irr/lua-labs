#!/usr/bin/env luajit

--os.execute("for file in *.mp3 ; do id3v2 -t \"${file%.mp3}\" \"${file}\"; done;")

local files = { split(os.capture("ls *.mp3", true), "\n") }

for k, v in pairs(files) do
    local name = trim(v)
    if v and #v > 0 then
        local n, a, s = split(v, "-")
        s = trim(s)
        if s and #s > 0 then
            sname = s:sub(1, #s-4)
            os.execute("id3v2 -g 17 -t \"" .. sname .. "\" \"" .. name .. "\"")
        end
    end
end
