local log = ngx.log
local level = ngx.ERR
local tostring = tostring
local sleep = ngx.sleep
local unpack = unpack
local pcall = pcall

module("sync")

function run(dict, f, t, s)
    local key = "__SYNC__:LOCK"
    repeat
        local _, err, _ = dict:add(key, 0)
        sleep(s or 0.001)
    until not err
    local ok, val = pcall(f, unpack(t))
    dict:delete(key)
    if not ok then
        log(level, "do_sync (" .. key .. ") error ["..tostring(val).."]")
    end
    return ok, val
end
