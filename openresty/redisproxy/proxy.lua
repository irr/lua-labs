--[[
redis-server
redis-cli set uol uol.com.br && echo -e "upstream uol.com.br {\n\tserver uol.com.br;\n}" > upstreams/uol.conf && nginx -s reload
redis-cli set irr irrlab.com && echo -e "upstream irrlab.com {\n\tserver irrlab.com;\n}" > upstreams/irr.conf && nginx -s reload
http http://localhost:8080?id=uol
http http://localhost:8080?id=irr
--]]

local keys = ngx.req.get_uri_args()
local key = keys["id"]

local route, err = ngx.shared.routes:get(key)

if route then
    ngx.var.target = route
else
    local res = ngx.location.capture(
        "/redis", { args = { key = key } }
    )

    if res.status ~= 200 then
        ngx.log(ngx.ERR, "redis server returned bad status: ", res.status)
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
        ngx.exit(501)
    else
        ngx.shared.routes:set(key, server, ngx.var.throttle)
        ngx.var.target = server
    end
end

ngx.log(ngx.ERR, "target=" .. ngx.var.target)
