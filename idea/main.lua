package.path = (package.path or "") .. ";/home/irocha/.luarocks/share/lua/5.1/?.lua;"
package.cpath = (package.cpath or "") .. ";/home/irocha/.luarocks/lib/lua/5.1/?.so;"

function d(o)
    if type(o) == "table" then
        for k, v in pairs(o) do
            print(k,v)
        end
    else
        print(o)
    end
end

d(_G)

redis = require 'redis'
client = redis.connect({ host = '127.0.0.1', port = 6379, timeout = 0 })
for k,v in pairs(client:info()) do
    print(k .. ' => ' .. tostring(v))
    if type(v) == 'table' then
        for ki,vi in pairs(v) do
            print("\t"..ki .. ' => ' .. tostring(vi))
        end
    end
end
