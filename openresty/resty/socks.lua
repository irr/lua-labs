local json = require "cjson"

function error(err)
    if err == "closed" then
        return
    end
    if err then
        print(">> "..err)
        ngx.exit(1) 
    end
end

local sock = ngx.socket.tcp()
local ok, err = sock:connect("www.uol.com.br", 80)
error(err)

sock:settimeout(1000) 

local packet = {
    "GET / HTTP/1.0\n",
    "\n"
}

local bytes, err = sock:send(packet)
error(err)

local dump = true

repeat
    local line, err, partial = sock:receive()
    if line and dump then
        print(tostring(line))
        if line == "" then
            dump = false
        end
    end
until err

sock:close()
