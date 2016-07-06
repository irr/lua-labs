--[[
redis-server
redis-server --port 6380 --slaveof 127.0.0.1 6379
redis-server --port 6381 --slaveof 127.0.0.1 6379
redis-cli set uol uol.com.br && echo -e "upstream uol.com.br {\n\tserver uol.com.br;\n}" > upstreams/uol.conf && nginx -s reload
redis-cli set irr irrlab.com && echo -e "upstream irrlab.com {\n\tserver irrlab.com;\n}" > upstreams/irr.conf && nginx -s reload
curl -v http://localhost:8080?id=uol
curl -v http://localhost:8080?id=irr
curl -s -H "Content-Type: application/json" -X POST -d '{"id":"uol"}' http://localhost:8080|head -10
--]]

local keys = nil

if ngx.req.get_method() == "GET" or ngx.req.get_method() == "HEAD" then
    keys = ngx.req.get_uri_args()
elseif ngx.req.get_method() == "POST" then
    ngx.req.read_body()
    local json = require "cjson"
    local ok, data = pcall(json.decode, ngx.req.get_body_data())
    if ok then
        keys = data
    end
end

if not keys then
    ngx.log(ngx.ERR, "id could not be extracted")
    ngx.exit(400)
end

local key = keys["id"]

local cache, err = ngx.shared.routes:get_stale(key)
local route, err = ngx.shared.routes:get(key)

if route then
    ngx.var.target = route
else
    local res = ngx.location.capture(
        "/redis", { args = { key = key } }
    )

    if res.status ~= 200 then
        if res.status == 502 and cache then
            ngx.shared.routes:set(key, cache, ngx.var.throttle)
            ngx.var.target = cache
            ngx.log(ngx.ERR, "target (shared.routes stale value): ", ngx.var.target)
            return
        end
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

ngx.log(ngx.NOTICE, "target=" .. ngx.var.target)
