local memcached = require "resty.memcached"
local http = require "resty.http"

local function query_memcached()
    local memc = memcached:new()
    memc:connect("127.0.0.1", 11211)
    local res, err = memc:stats()
    ngx.say("memcached done: ", string.gsub(table.concat(res, "; "), "STAT ", ""))
end

local function query_http()
    local httpc = http.new()
    local res, err = httpc:request_uri("http://www.uol.com.br", { method = "GET" })
    ngx.say("http done: ", res.status)
end

local threads = { ngx.thread.spawn(query_memcached), ngx.thread.spawn(query_http) }

for i = 1, #threads do
    ngx.thread.wait(threads[i])
end
