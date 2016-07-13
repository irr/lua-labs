--[[

redis-server
redis-server --port 6380 --slaveof 127.0.0.1 6379
redis-server --port 6381 --slaveof 127.0.0.1 6379

# default
redis-cli set default 127.0.0.1:8000

# server-01
redis-cli set uol 127.0.0.1:8001

# server-02
redis-cli set irr 127.0.0.1:8002

export REDIS_SERVICE_HOST=127.0.0.1
export REDIS_SERVICE_PORT=6379

curl -v http://localhost:8080?id=uol
curl -v http://localhost:8080?id=irr

curl -s -H "Content-Type: application/json" -X POST -d '{"id":"uol"}' http://localhost:8080|head -10

--]]

function get_target(key)
    local redis = require "resty.redis"
    local red = redis:new()
    local ok, err = red:connect(os.getenv("REDIS_SERVICE_HOST"), os.getenv("REDIS_SERVICE_PORT"))
    if not ok then
        ngx.log(ngx.ERR, "redis (connection error): ", err)
        ok, err = nil, 503
    else
        local res, err = red:get(key)
        if not res then
            ngx.log(ngx.ERR, "redis (bad response): ", err)
            ok, err = nil, 503
        else
            if res == ngx.null then
                ngx.log(ngx.ERR, "redis (not found): ", key)
                ok, err = nil, nil
            else
                ok, err = res, nil
            end
        end
        red:close()
    end
    return ok, err
end

local cjson = require "cjson"

local ok, keys = nil, nil

if ngx.req.get_method() == "GET" or ngx.req.get_method() == "HEAD" then
    keys = ngx.req.get_uri_args()
elseif ngx.req.get_method() == "POST" then
    ngx.req.read_body()
    ok, keys = pcall(cjson.decode, ngx.req.get_body_data())
    if not ok then
        ngx.log(ngx.ERR, "bad request: id could not be extracted")
        ngx.exit(400)
    end
end

local key = keys["id"]

local route, err = ngx.shared.routes:get(key)
if route then
    ngx.var.target = route
else
    local target, err = get_target(key)
    if not err then
        if not target then
            target, err = get_target(ngx.var.default)
        end
    end
    if not err then
        if tonumber(ngx.var.throttle) > 0 then
            ngx.shared.routes:set(key, target, tonumber(ngx.var.throttle))
        end
        ngx.var.target = target
    else
        ngx.exit(err)
    end
end
