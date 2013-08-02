#!/usr/bin/env luajit

require("luarocks.loader")

local posix = require('posix')

if #arg == 0 then
    print("Usage: wgo [OPTIONS] <file or url (http/https)>")
    print("       -t<n> = timeout in seconds")
    print("       -s<n> = retry interval in seconds")
    os.exit(1)
end

function main(arg)
    local t, s, f = 5, 5, nil

    for i = 1, #arg do
        if arg[i]:find("-t") == 1 and #arg[i] > 3 then
            t = tonumber(arg[i]:sub(3))
        elseif arg[i]:find("-s") == 1 and #arg[i] > 3 then
            s = tonumber(arg[i]:sub(3))
        else
            f = arg[i]
        end
    end

    local cmd = string.format("wget -c --timeout=%d ", t)

    if f:find("http://") then
        cmd = cmd .. f
    elseif f:find("https://") then
        cmd = cmd .. string.format("--no-check-certificate %s", f)
    else
        cmd = cmd .. string.format("--no-check-certificate --user=%s --password=%s https://ocean:8080/%s", os.getenv("U"), os.getenv("P"), f)
    end

    print(string.format("wlua: downloading [%s]...", f))

    local status = nil

    repeat
        _, status = pcall(os.execute, cmd)
        if status ~= 0 then
            print(string.format("wlua: waiting for %d seconds [%s]...", s, f))
            pcall(os.execute, "sleep " .. tonumber(s))
        end
    until (status == 0)

    print(string.format("wlua: [%s] finished ok.", f))
end

function go(fn,...)
    local cpid = posix.fork()
    if cpid == 0 then
        local res = fn(...)
        posix._exit(res or 0)
    else
        return cpid
    end
end

local cpid = go(function() main(arg) end)

posix.signal(posix.SIGINT, function()
    posix.kill(cpid)
end)

posix.wait(cpid)
