--[[
nginx -s stop; nginx -c /home/irocha/lua/openresty/sync/nginx.conf

curl -v http://localhost:8888/
--]]

local sync = require("sync")

local f = function (d)
    local val, err = d:incr("COUNTER", 1)
    if err then
        d:set("COUNTER", 0)
        val = 0
    end
    return val
end

local ok, val = sync.run(ngx.shared.monitors, f, { ngx.shared.monitors })

ngx.say("COUNTER = " .. (ok and tostring(val)) or "ERROR!")
