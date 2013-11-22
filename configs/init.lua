package.path = package.path .. ";/opt/lua/luarocks/share/lua/5.1/?.lua;"
package.cpath = package.cpath .. ";/opt/lua/luarocks/lib/lua/5.1/?.so;"
--require("luarocks.loader")
_ = require("underscore")
function d(t)
    for k, v in pairs(t) do
        print(k,v)
    end
end

