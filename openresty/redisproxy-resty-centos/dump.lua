--[[
curl -v -H "Content-Type: application/json" -X POST -d '{"id":"none", "data": {"name": "luma"}}' http://localhost:8080
]]

local json = require "cjson"

local data = nil

if ngx.req.get_method() == "GET" or ngx.req.get_method() == "HEAD" then
    data = ngx.req.get_uri_args()
elseif ngx.req.get_method() == "POST" then
    ngx.req.read_body()
    data = json.decode(ngx.req.get_body_data())
end

data["server"] = ngx.var.server

ngx.header.content_type = 'application/json';
ngx.say(json.encode(data))
