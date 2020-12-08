local cjson = require "cjson"
local http = require "resty.http"
local httpc = http.new()
-- python3 -m http.server 8000
local res, err = httpc:request_uri('http://127.0.0.1:8000/')
if not res then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(cjson.encode({ error = err }))
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    return
end
ngx.say(cjson.encode({ body = res.body}))
