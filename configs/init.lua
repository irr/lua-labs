package.path = package.path .. ";/opt/lua/luarocks/share/lua/5.1/?.lua;"
package.cpath = package.cpath .. ";/opt/lua/luarocks/lib/lua/5.1/?.so;"

function d(o)
    if type(o) == "table" then
        for k, v in pairs(o) do
            print(k,v)
        end
    else 
        print(o)
    end
end

function os.capture(cmd, raw)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

function split(str, sep)
    local s = str..sep
    return s:match((s:gsub('[^'..sep..']*'..sep, '([^'..sep..']*)'..sep)))
end

function trim(s)
    return s:match '^%s*(.-)%s*$'
end

function expand(s)
    return (string.gsub(s, "$(%w+)", function(n)
                return tostring(_G[n])
            end))
end
