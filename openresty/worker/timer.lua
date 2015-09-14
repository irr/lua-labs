local delay = 1
local handler
handler = function (premature, ...)
    local n = select('#', ...)
    print(string.format("entering thread (premature=[%s]/nparams=%d)...", tostring(premature), n))
    local t, v = ...
    if premature then
        return
    end
    print(t)
    print(v)
end

local ok, err = ngx.timer.at(delay, handler, "test1", 10, { name='ivan'})
if not ok then
    ngx.log(ngx.ERR, "failed to create the timer: ", err)
    return
end

print("waiting 2 secs...")
ngx.sleep(2)
print("exiting...")

