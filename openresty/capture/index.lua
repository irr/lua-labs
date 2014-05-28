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

function d(o)
    if type(o) == "table" then
        for k, v in pairs(o) do
            ngx.say(k,v)
        end
    else 
        ngx.say(o)
    end
end

ngx.header.content_type = 'application/json';

ngx.req.set_header("Accept", "*/*")
ngx.req.set_header("Accept-Encoding", nil)

ngx.req.set_header("Authorization",  "Basic " .. ngx.encode_base64(ngx.var.userpass))

-- curl -v http://localhost:8888/api/esm
if ngx.req.get_method() == "GET" then
    local res = ngx.location.capture("/proxy" .. ngx.var.uri, { share_all_vars = true })
    ngx.print(res.body)
    exit()

-- curl -v -d "zone=ZE1&vlan=356" http://localhost:8888/api/esm/security-zones
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
    res = ngx.location.capture("/proxy" .. ngx.var.uri, 
        { share_all_vars = true,
          method = ngx.HTTP_POST,
          body = jbody:format(keys.zone, keys.vlan) })
    ngx.say(res.body)
    exit()
-- curl -v http://localhost:8888/api/esm/security-zones
-- curl -v -X DELETE http://localhost:8888/api/esm/security-zones/78156a84-8c2f-4134-accf-8e7a51c1d6f6
elseif ngx.req.get_method() == "DELETE" then
    res = ngx.location.capture("/proxy" .. ngx.var.uri, 
        { share_all_vars = true,
          method = ngx.HTTP_DELETE })
    ngx.say(res.body)
    exit()
else
    exit(ngx.HTTP_METHOD_NOT_IMPLEMENTED)
end
