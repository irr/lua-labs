package.path = package.path .. ";/opt/lua/luarocks/share/lua/5.1/?.lua;"
package.cpath = package.cpath .. ";/opt/lua/luarocks/lib/lua/5.1/?.so;"

local function main()
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
end

main()
