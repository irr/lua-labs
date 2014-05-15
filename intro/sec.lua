local http = require "socket.http"
local https = require "ssl.https"
local r = {}
http.TIMEOUT = 1
b, c, h = https.request({
        url = "https://www.google.fr/",
        sink = ltn12.sink.table(r),
        protocol = "tlsv1",
        verify = "none"})
print(b, c, h)
for k, v in pairs(h) do
    print(k, v)
end
for k, _ in pairs(r) do
    print("chunk: ", k)
end