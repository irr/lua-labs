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

function unescape(s)
    s = string.gsub(s, "+", " ")
    s = string.gsub(s, "%%(%x%x)", function (h)
            return string.char(tonumber(h, 16))
        end)
    return s
end

function escape(s)
    s = string.gsub(s, "[&=+%%%c]", function (c)
            return string.format("%%%02X", string.byte(c))
        end)
    s = string.gsub(s, " ", "+")
    return s
end

function decode(s)
    local cgi = {}
    for name, value in string.gmatch(s, "([^&=]+)=([^&=]+)") do
        name = unescape(name)
        value = unescape(value)
        cgi[name] = value
    end
    return cgi
end

function encode (t)
    local b = {}
    for k,v in pairs(t) do
        b[#b + 1] = (escape(k) .. "=" .. escape(v))
    end
    return table.concat(b, "&")
end
