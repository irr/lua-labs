-- query mysql, memcached, and a remote http service at the same time,
-- output the results in the order that they
-- actually return the results.

local json = require "cjson"
local mysql = require "resty.mysql"
local memcached = require "resty.memcached"

local function query_mysql()
    local db = mysql:new()
    db:connect{
                host = "127.0.0.1",
                port = 3306,
                database = "mysql",
                user = "root",
                password = "mysql"
              }
    local res, err, errno, sqlstate =
            db:query("select Host, User from user")
    db:set_keepalive(0, 100)    
    return json.encode(res)
end

local function query_memcached()
    local memc = memcached:new()
    memc:connect("127.0.0.1", 11211)
    memc:set("dog", "luma")
    local res, err = memc:get("dog")
    return res
end

local threads = {
    ngx.thread.spawn(query_mysql),
    ngx.thread.spawn(query_memcached)
}

for i = 1, #threads do
    local ok, res = ngx.thread.wait(threads[i])
    if not ok then
        ngx.say(i, ": failed to run: ", res)
    else
        ngx.say(i, ": res: ", res)
    end
end