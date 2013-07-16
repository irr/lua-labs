local json = require 'cjson'

function get_value_from_json(value)
    if value then
        local t = json.decode(value)
        if t["server"] then
            ngx.var.target = t["server"]
            return ngx.var.target
        end

        ngx.log(ngx.ERR, 
                string.format("get_value_from_json:[%s]", 
                json.encode{json = value}))            
    end
    return nil
end

function get_from_shm(key)
    local value, _ = ngx.shared.maps:get(key)

    if value then
        ngx.var.target = value
        return ngx.var.target
    end

    return nil
end

function get_from_memcached(key)
    local res = ngx.location.capture(
        "/mem", { args = { key = key } }
    )

    if res.status == 200 and res.body then
        return get_value_from_json(res.body)
    end

    return nil
end

function get_from_server(args)
    res = ngx.location.capture(
        "/map", { args = args }
    )

    if res.status == 200 and res.body then
        return get_value_from_json(res.body)
    end
    
    return nil
end

function shm(f, a, k)
    k = (not k) and a or k
    local v = f(a)
    if v then
        local _, e, w = ngx.shared.maps:set(k, v, ngx.var.exptime)
        if e then
            ngx.log(ngx.EMERG, 
                    string.format("shm:[%s]", e)) 
            ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        elseif w then
            ngx.log(ngx.WARN, 
                    "shm:[valid items have been removed forcibly]")
        end     
    end
    return v
end

local args = ngx.req.get_uri_args()
local key = string.format("%s:%s", args["u"], args["c"])

if shm(get_from_shm, key) 
    or shm(get_from_memcached, key) 
    or shm(get_from_server, args, key) then
    return
end

ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
