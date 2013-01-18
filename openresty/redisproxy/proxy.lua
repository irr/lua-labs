--[[
redis-server
redis-cli set test www.uol.com.br
http http://localhost:8080?id=test
--]]

local keys = ngx.req.get_uri_args()
local key = keys["id"]
local res = ngx.location.capture(
    "/redis", { args = { key = key } }
)

if res.status ~= 200 then
    ngx.log(ngx.ERR, "redis server returned bad status: ",
        res.status)
    ngx.exit(res.status)
end

if not res.body then
    ngx.log(ngx.ERR, "redis returned empty body")
    ngx.exit(500)
end

local parser = require "redis.parser"
local server, typ = parser.parse_reply(res.body)
if typ ~= parser.BULK_REPLY or not server then
    ngx.log(ngx.ERR, "bad redis response: ", res.body)
    ngx.exit(500)
end

ngx.var.target = server
