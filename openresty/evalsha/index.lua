--[[
redis-server
curl -v "http://localhost:8080?m=query&w=tall|poor|rich|dummy|nothing"
--]]

function split(str, sep)
    local s = str..sep
    return s:match((s:gsub("[^"..sep.."]*"..sep, "([^"..sep.."]*)"..sep)))
end

local json = require "cjson"

local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(5000)

--[[
local ok, err = red:connect("unix://tmp/redis.sock")
unixsocket /tmp/redis.sock
unixsocketperm 777
]]

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

local keys = ngx.req.get_uri_args()
local query = {split(ngx.var.query, ":")}

ngx.header.content_type = 'plain/text';

local res, err = red:evalsha(query[1], query[2], query[3], split(keys["w"], "|"))
if err then
    ngx.say(json.encode(tostring(err)))
else
    if type(res) == "table" then
        for k,v in pairs(res) do
            ngx.say(string.format("%s: %s", k, v))
        end
    else
        ngx.say(res)
    end
end

local ok, err = red:set_keepalive(0, 100)
if not ok then
    ngx.say(json.encode(tostring(err)))
end
