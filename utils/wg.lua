#!/usr/bin/env luajit

function run(l, t, s, f)
    local cmd, status = string.format("wget -c --timeout=%d ", t), nil

    if #l > 0 then
        cmd = cmd .. string.format("--limit-rate=%s ", l)
    end

    if f:find("http://") then
        cmd = cmd .. f
    elseif f:find("https://") then
        cmd = cmd .. string.format("--no-check-certificate %s", f)
    else
        cmd = cmd .. string.format("--no-check-certificate --user=%s --password=%s \"https://enderseed.shell.seedhost.eu/enderseed/downloads/irr/%s\"", 
              os.getenv("U"), os.getenv("P"), f)
    end

    repeat
        _, status = pcall(os.execute, cmd)
        if status ~= 0 then
            print(string.format("wg: waiting for %d seconds [%s]...", s, f))
            if status ~= 2 then
                pcall(os.execute, "sleep " .. tonumber(s))
            end
        end
    until (status == 0) or (status == 2)

    if status == 0 then
        print(string.format("wg: [%s] finished ok.", f))
    else
        print(string.format("wg: [%s] was interrupted.", f))
    end
end

local l, t, s, f = "", 5, 5, nil

for i = 1, #arg do
    if arg[i]:find("-t") == 1 and #arg[i] > 2 then
        t = tonumber(arg[i]:sub(3))
    elseif arg[i]:find("-s") == 1 and #arg[i] > 2 then
        s = tonumber(arg[i]:sub(3))
    elseif arg[i]:find("-l") == 1 and #arg[i] > 2 then
        l = arg[i]:sub(3)
    else
        f = arg[i]
    end
end

if f == nil then
    print("Usage: wg [OPTIONS] <file or url (http/https)>")
    print("       -l<s> = limit rate")
    print("       -t<n> = timeout in seconds")
    print("       -s<n> = retry interval in seconds")
    os.exit(1)
end

print(string.format("wg: downloading [%s] with timeout=[%d] and retry=[%d]...", f, t, s))

run(l, t, s, f)
