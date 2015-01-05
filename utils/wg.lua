#!/usr/bin/env lua

USER=os.getenv("U")
PASSWORD=os.getenv("P")

function run(l, n, t, s, f, o)
    local cmd, status = string.format("wget -c --timeout=%d ", t), nil

    if #l > 0 then
        cmd = cmd .. string.format("--limit-rate=%s ", l)
    end

    if #n > 0 then
        cmd = cmd .. string.format("-O \"%s\" ", n)
    end

    if o ~= nil then
        cmd = cmd .. string.format("-O \"%s\" ", o)
    end

    if f:find("http://") then
        cmd = cmd .. f
    elseif f:find("https://") then
        cmd = cmd .. string.format("--no-check-certificate %s", f)
    else
        cmd = cmd .. string.format("--no-check-certificate --user=%s --password=%s 'https://enderseed.buzz.seedhost.eu/enderseed/downloads/%s'", USER, PASSWORD, f)
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

local l, n, t, s, f, o, p, m = "", "", 5, 5, nil, nil, nil, nil

for i = 1, #arg do
    if arg[i]:find("-t") == 1 and #arg[i] > 2 then
        t = tonumber(arg[i]:sub(3))
    elseif arg[i]:find("-s") == 1 and #arg[i] > 2 then
        s = tonumber(arg[i]:sub(3))
    elseif arg[i]:find("-l") == 1 and #arg[i] > 2 then
        l = arg[i]:sub(3)
    elseif arg[i]:find("-n") == 1 and #arg[i] > 2 then
        n = arg[i]:sub(3)
    elseif arg[i]:find("-m") == 1 and #arg[i] > 2 then
        m = tonumber(arg[i]:sub(3))
    else
        if f == nil then
            f = arg[i]
        else
            o = arg[i]
        end
    end
end

if f == nil then
    print("Usage: wg [OPTIONS] <file or url (http/https)> [output-filename]")
    print("       -l<s> = limit rate")
    print("       -t<n> = timeout in seconds")
    print("       -s<n> = retry interval in seconds")
    print("       -n<s> = output-filename")
    print("       -m<n> = multiples-rars")
    os.exit(1)
end

print(string.format("wg: downloading [%s] with timeout=[%d] and retry=[%d]...", f, t, s))

if m and m > 0 then
    run(l, n, t, s, string.format("%s.rar", f))
    for i = 0, m do
        print(string.format("wg: downloading %02d/%02d...", i, m))
        run(l, n, t, s, string.format("%s.r%02d", f, i))
    end
else
    run(l, n, t, s, f, o)
end

