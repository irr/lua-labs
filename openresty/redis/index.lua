--[[
redis-server
curl -v "http://localhost:8080?n=10"
curl -v "http://localhost:8080?n=10&p=1"
redis-cli get n
--]]

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
local n = tonumber(keys["n"])
local p = keys["p"]

ngx.header.content_type = 'plain/text';

if p then
    red:init_pipeline()
    ngx.say("pipeline")
else
    local ok, err = red:multi()
    if not ok then
        ngx.say("failed to run multi: ", err)
        return
    end
    ngx.say("multi")
end

red:set("n", "0")
for i = 1, n do
    red:incr("n")
end

local results, err

if p then
    results, err = red:commit_pipeline()
else
    results, err = red:exec()
end

for i, res in ipairs(results) do
    if type(res) == "table" then
        if not res[1] then
            ngx.say("failed to run command ", i, ": ", res[2])
        else
            ngx.say(tostring(i)..": "..json.encode(res))
        end
    else
        ngx.say(tostring(i)..": "..json.encode(res))
    end
end

local ok, err = red:set_keepalive(0, 100)
if not ok then
    ngx.say(json.encode(tostring(err)))
end
