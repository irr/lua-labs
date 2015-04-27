local client = require "resty.websocket.client"
local wb, err = client:new()
local uri = "ws://127.0.0.1:8000"
local ok, err = wb:connect(uri)
if not ok then
    ngx.say("failed to connect: " .. err)
    return
end

local data = "test ok!"

local bytes, err = wb:send_text("copy: " .. data)
if not bytes then
    ngx.say("failed to send frame: ", err)
    return
end

local data, typ, err = wb:recv_frame()
if not data then
    ngx.say("failed to receive the frame: ", err)
    return
end

ngx.say(string.format("received: [%s] typ(%s) err(%s)", data, typ, err))

local bytes, err = wb:send_close()
if not bytes then
    ngx.say("failed to send frame: ", err)
    return
end

