local cjson = require "cjson"
local mysql = require "resty.mysql"
local redis = require "resty.redis"
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
            db:query("select user,host from user")
    db:set_keepalive(0, 100)
    ngx.say("mysql done: ", cjson.encode(res))
end

local function query_memcached()
    local memc = memcached:new()
    local ok, err = memc:connect("127.0.0.1", 11211)
    if ok then
        local res, err = memc:stats()
        ngx.say("memcached done: ", cjson.encode(res))
        memc:close()
    end
end
 
local function query_redis()
    local red = redis:new()    
    red:set_timeout(1000)
    local ok, err = red:connect("127.0.0.1", 6379)
    if ok then
        local res, err = red:info()
        ngx.say("redis done: ", cjson.encode(res))
        red:close()
    end
end

local function query_http()
    local res = ngx.location.capture("/api")
    ngx.say("http done: ", cjson.encode(res))
end

ngx.thread.spawn(query_mysql)
ngx.thread.spawn(query_memcached)
ngx.thread.spawn(query_redis)
ngx.thread.spawn(query_http)