local json = require "cjson"

function exit(status, msg)
    if status and (status ~= ngx.HTTP_OK) then
        ngx.status = status
    end

    if msg then
        ngx.say(msg)
    end

    ngx.exit(ngx.HTTP_OK)
end

ngx.header.content_type = 'application/json';

-- curl -s -v "http://localhost:8888/?_proxy=google.com"
if ngx.req.get_method() == "GET" then
    local keys = ngx.req.get_uri_args()
    if next(keys) == nil then
        exit(ngx.HTTP_BAD_REQUEST)
    end
    ngx.var.target = keys._proxy
    ngx.req.set_header("Content-Type", "text/html")
    local res = ngx.location.capture("/proxy/", 
        { share_all_vars = true,
          method = ngx.HTTP_GET,
          body = "" })
    exit(res.status, json.encode({body=res.body}))
end
