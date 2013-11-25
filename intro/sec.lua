local http = require "socket.http"
local https = require "ssl.https"
http.TIMEOUT = 1
b, c, h = https.request("https://www.google.fr/")
print(c, b:sub(1, 20) .. "...")
if h then
    for k, v in pairs(h) do
        print(k, v)
    end
end