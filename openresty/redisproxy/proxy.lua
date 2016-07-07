--[[
redis-server
redis-server --port 6380 --slaveof 127.0.0.1 6379
redis-server --port 6381 --slaveof 127.0.0.1 6379
redis-cli set uol uol.com.br && echo -e "upstream uol.com.br {\n\tserver uol.com.br;\n}" > upstreams/uol.conf && nginx -s reload
redis-cli set irr irrlab.com && echo -e "upstream irrlab.com {\n\tserver irrlab.com;\n}" > upstreams/irr.conf && nginx -s reload
echo -e "upstream www.google.com {\n\tserver www.google.com;\n}" > upstreams/google.conf && nginx -s reload
curl -v http://localhost:8080?id=uol
curl -v http://localhost:8080?id=irr
curl -s -H "Content-Type: application/json" -X POST -d '{"id":"uol"}' http://localhost:8080|head -10
--]]

local ok, keys = nil, nil

if ngx.req.get_method() == "GET" or ngx.req.get_method() == "HEAD" then
    keys = ngx.req.get_uri_args()
elseif ngx.req.get_method() == "POST" then
    ngx.req.read_body()
    local json = require "cjson"
    ok, keys = pcall(json.decode, ngx.req.get_body_data())
    if not ok then
        ngx.log(ngx.ERR, "id could not be extracted")
        ngx.exit(400)
    end
end

local key = keys["id"]
local route, err = ngx.shared.routes:get(key)
if route then
    ngx.var.target = route
else
    local res = ngx.location.capture("/redis", { args = { key = key } })
    if res.status ~= 200 then
        ngx.log(ngx.ERR, "redis bad status: ", res.status)
        ngx.exit(res.status)
    elseif not res.body then
        ngx.log(ngx.ERR, "redis error: empty body")
        ngx.exit(500)
    else
        local parser = require "redis.parser"
        local server, typ = parser.parse_reply(res.body)
        if typ == parser.BULK_REPLY and not server then
            ngx.log(ngx.ERR, "redis not found: default=" .. ngx.var.target)
            ngx.shared.routes:set(key, ngx.var.target, ngx.var.throttle)
        elseif typ ~= parser.BULK_REPLY or not server then
            ngx.log(ngx.ERR, "redis bad response: ", res.body)
            ngx.exit(501)
        else
            ngx.shared.routes:set(key, server, ngx.var.throttle)
            ngx.var.target = server
        end
    end
end

ngx.header["X-Redis-Proxy"] = ngx.var.target;
