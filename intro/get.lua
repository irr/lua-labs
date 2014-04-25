local http = require("socket.http")
local ltn12 = require("ltn12")

http.TIMEOUT = 1

local response_body = {}

local res, code, response_headers = http.request
{
    url = "http://localhost:3000/test?name=alessandra";
    method = "GET";
    sink = ltn12.sink.table(response_body);
}

print(res, code, response_headers, response_body)

d(response_headers)
d(response_body)
