local json = require "cjson" 

function exit_now(status, msg)
    if status ~= ngx.HTTP_OK then
        ngx.status = status
    end

    if msg then
        ngx.say(msg)
    end

    ngx.exit(ngx.HTTP_OK)
end

function exit(status, msg)
    if status then
        exit_now(status, msg)
    end

    exit_now(ngx.HTTP_OK, msg)
end

function split(str, sep)
    local s = str..sep
    return s:match((s:gsub('[^'..sep..']*'..sep, '([^'..sep..']*)'..sep)))
end

function d(o)
    if type(o) == "table" then
        for k, v in pairs(o) do
            ngx.print(k,v)
        end
    else 
        ngx.print(o)
    end
end


ngx.header.content_type = 'application/json';

ngx.req.set_header("Authorization",  "Basic " .. ngx.encode_base64(ngx.var.userpass))

-- curl -v http://localhost:8888/api/esm
if ngx.req.get_method() == "GET" then
    local res = ngx.location.capture("/proxy" .. ngx.var.uri, { share_all_vars = true })
    ngx.print(res.body)
    exit()

-- curl -v -d "zone=ALESSANDRA&vlan=356" http://localhost:8888/api/esm/security-zones
elseif ngx.req.get_method() == "POST" then
    ngx.req.read_body()
    local keys = ngx.req.get_post_args()
    local jbody = [[
        {
            "name": "%s",
            "ipAddressPool":{
                "poolAddress":"10.0.0.3",
                "poolPrefix":"24",
            "prefix":"24"
        },
        "interfacePool":{
            "href":"/interface-pools/default-shared"
        },
            "vlanId":"%d"
        }
    ]]
    ngx.req.set_header("Content-Type", "application/json")
    local res = ngx.location.capture("/proxy" .. ngx.var.uri, 
        { share_all_vars = true,
          method = ngx.HTTP_POST,
          body = jbody:format(keys.zone, keys.vlan) })
    ngx.say(res.body)
    exit()
-- curl -v -X DELETE http://localhost:8888/api/esm/security-zones?zone=ALESSANDRA
elseif ngx.req.get_method() == "DELETE" then
    local keys = ngx.req.get_uri_args()
    local res = ngx.location.capture("/proxy" .. ngx.var.uri, { share_all_vars = true })
    local map = json.decode(res.body)
    for _, entry in pairs(map.entries) do        
        if entry.name == keys.zone then
            local uri = split(ngx.var.uri, "?")
            local id = {split(tostring(entry.links[1].href), "/")}
            local res = ngx.location.capture("/proxy" .. uri .. "/" .. id[#id], 
                { share_all_vars = true,
                  method = ngx.HTTP_DELETE })
            ngx.say(res.body)
            exit()
        end
    end
    exit(ngx.HTTP_NOT_FOUND)
else
    exit(ngx.HTTP_METHOD_NOT_IMPLEMENTED)
end
