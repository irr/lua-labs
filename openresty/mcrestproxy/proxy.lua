--[=[
http http://localhost:8080/?key=1
--]=]

function error(status, msg, sock)
    if sock then
        sock:close()
    end
    ngx.status = 404
    ngx.say("<<"..msg..">>")
    ngx.exit(ngx.HTTP_OK)    
    --[[
    http://wiki.nginx.org/HttpLuaModule#ngx.exit
    ngx.log(ngx.ERR, msg)
    ngx.exit(status)
    --]]
end

--[[
local uri = ngx.var.uri
print("uri:"..uri)
--]]

local keys = ngx.req.get_uri_args()
local key = keys["key"]

local res = ngx.location.capture(
    "/mc", { args = { key = key } }
)

if res.status ~= 200 or not res.body then
    local sock, err = ngx.socket.connect("127.0.0.1", 8888)

    if not sock then
        error(500, "REST connection refused")
    end

    local bytes, err = sock:send("GET /map?key="..key.." HTTP/1.0\r\n\r\n")

    if not bytes then
        error(500, "REST request error", sock)
    end

    local reader = sock:receiveuntil(":REST")
    local data, err, partial = reader(1024)

    if not data then
        error(500, "REST read error", sock)
    end

    local server = data:match("REST:(.+)")

    if not server then
        error(500, "REST mapping error", sock)
    end

    sock:close()

    ngx.var.target = server
else
    ngx.var.target = res.body
end
