local http = require "socket.http"
local https = require "ssl.https"
http.TIMEOUT = 1
b, c, h = https.request({
        url = "https://www.google.fr/",
        sink = ltn12.sink.table(resp),
        protocol = "tlsv1",
        verify = "none"})
print(b, c, h)
for k, v in pairs(h) do
    print(k, v)
end