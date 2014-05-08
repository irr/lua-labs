local http = require("socket.http")
local ltn12 = require("ltn12")

http.TIMEOUT = 1

local request_body = [[name=alessandra]]
local response_body = {}

local res, code, response_headers = http.request
{
    url = "http://localhost:3000/test";
    method = "POST";
    headers = 
    {
        ["Content-Type"] = "application/x-www-form-urlencoded";
        ["Content-Length"] = #request_body;
    };
    source = ltn12.source.string(request_body);
    sink = ltn12.sink.table(response_body);
}

d(response_headers)

local body = table.concat(response_body)
print(res, code, body)
