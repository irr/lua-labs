package.path = package.path .. ";/opt/lua/luarocks/share/lua/5.1/?.lua;"
package.cpath = package.cpath .. ";/opt/lua/luarocks/lib/lua/5.1/?.so;"

function d(o, g)
    g = g or ''
    if type(o) == "table" then
        for k, v in pairs(o) do
            print(g,k,v)
        end
    else
        print(g,o)
    end
end

local function dd(fn, r, f, ...)
    print(fn)
    print(...)
    res = f(...)
    r(res)
    return res
end

local function main()
  redis = require 'redis'
  client = redis.connect({ host = '127.0.0.1', port = 6379, timeout = 0 })

  geoadd = redis.command('GEOADD', {
        response = function(reply, command, ...)
            return tonumber(reply)
        end})

  geohash = redis.command('GEOHASH')
  georadius = redis.command('GEORADIUS')

  dd('GEOADD', print, geoadd, client, 'Sicily', '13.361389', '38.115556',  'Palermo')
  dd('GEOADD', print, geoadd, client, 'Sicily', '15.087269', '37.502669', 'Catania')

  dd('GEOHASH', d, geohash, client, 'Sicily', 'Palermo', 'Catania')

  dd('GEORADIUS', d, georadius, client, 'Sicily', '15', '37', '200', 'km')

  response = dd('GEORADIUS', d, georadius, client, 'Sicily', '15', '37', '200', 'km', 'WITHDIST')
  d(response[1], '\t')
  d(response[2], '\t')

  response = dd('GEORADIUS', d, georadius, client, 'Sicily', '15', '37', '200', 'km', 'WITHDIST', 'WITHCOORD')
  d(response[1], '\t')
  d(response[1][3], '\t\t')
  d(response[2], '\t')
  d(response[2][3], '\t\t')

end

main()
