--[[
nginx -s stop; nginx -c /home/irocha/lua/openresty/sync/nginx.conf
nginx -s stop; nginx -c /home/irocha/lua/openresty/sync/nginx.conf && ab -n 1000 -c 100 http://localhost:8888/ && curl -v http://localhost:8888/ && nginx -s stop && echo "DONE"
curl -v http://localhost:8888/
--]]

local sync = require("sync")

local f = function (d)
    local val, _ = d:get("COUNTER")
    val = (not val and 0) or (val + 1)
    d:set("COUNTER", val)
    return val
end

local ok, val = sync.run(ngx.shared.monitors, f, { ngx.shared.monitors })

ngx.say("COUNTER = " .. (ok and tostring(val)) or "ERROR!")
