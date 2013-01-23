-- https://github.com/bigplum/lua-resty-mongol

local json = require 'cjson'
ngx.header.content_type = 'application/json; charset=utf-8';

local mongol = require "resty.mongol"

local conn = mongol:new()
conn:set_timeout(10000) 

ok, err = conn:connect("127.0.0.1", 27017)
if ok then
    -- conn:set_timeout(10000)
    local db = conn:new_db_handle("stock")
    local col = db:get_col("symbols")
    local r = col:find_one({S="UOLL4"})
    local d = { ["package.path"] = package.path }
    for _, v in pairs({"S", "D", "O", "H", "L", "C", "V"}) do
        d[v] = r[v]
    end
    ngx.say(json.encode(d))
    conn:close()
else
    ngx.say(json.encode({["package.path"]=package.path, error=err}))
end