--[[
httperf --server localhost --port 8888 --num-calls 10000 --rate 1000 --num-conns 100 && curl -v http://localhost:8888/
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
