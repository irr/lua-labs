-- curl -v http://127.0.0.1:1984/test 

package.path = package.path .. ";/home/irocha/lua/openresty/resty-http/?.lua;;"

local json = require "cjson" 
local keys = {}

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

if ngx.req.get_method() == "POST" then
    
    ngx.req.read_body()
    keys = ngx.req.get_post_args()
    keys.home = os.getenv("HOME")
    ngx.say(json.encode(keys))

elseif ngx.req.get_method() == "GET" then

    local http = require "resty.http"
    local httpc = http.new()
    local res, err = httpc:request_uri("http://127.0.0.1:1984/test", {
      method = "POST",
      body = "a=1&b=2",
      headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
      }
    })

    if res == nil then
        exit(ngx.HTTP_INTERNAL_SERVER_ERROR, tostring(err))
    end

    ngx.status = res.status

    ngx.say(res.body)

end
