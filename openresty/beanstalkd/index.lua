--[[
http POST http://localhost:8000 name=ivan
--]]

local json = require "cjson"
local beanstalkd = require "resty.beanstalkd"

function exit_now(status, msg)
    if status ~= ngx.HTTP_OK then
        ngx.status = status
    end
    if msg then
        ngx.say(json.encode(msg))
    end

    local request_time = (ngx.now() - ngx.req.start_time())
    ngx.log(ngx.INFO, "request time: " .. tostring(request_time))

    ngx.exit(ngx.HTTP_OK)
end

ngx.header.content_type = 'application/json';

local b = beanstalkd.new()

local ok, err = b:connect()

if not ok then
    exit_now(ngx.HTTP_INTERNAL_SERVER_ERROR, {["error"] = err})
end

if ngx.req.get_method() == "POST" then

    ngx.req.read_body()

    if ngx.req.get_headers().content_type:lower() ~= "application/json" then
        exit_now(ngx.HTTP_BAD_REQUEST, {error="wrong content_type"})
    end

    local ok, data = pcall(json.decode, ngx.req.get_body_data())

    local ok, id, err = b:put(json.encode(data))

    b:close()

else

    local id, data = b:reserve()

    exit_now(ngx.HTTP_OK, {id=id, data=data})

end
