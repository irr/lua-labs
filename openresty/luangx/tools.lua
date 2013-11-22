local _ = require "underscore"
local mysql = require "resty.mysql"

ngx.say("MySQL")

local db, err = mysql:new()                                                      
if not db then                                                                   
    ngx.say("failed to instantiate mysql: ", err)                                
    return                                                                       
end                                                                              
                                                                                     
db:set_timeout(1000) -- 1 sec                                                    
                                                                                 
local ok, err, errno, sqlstate = db:connect{                                     
    host = "127.0.0.1",                                                          
    port = 3306,                                                                 
    database = "mysql",                                                           
    user = "root",                                                              
    password = "mysql",                                                               
    max_packet_size = 1024 * 1024 }                                              
                                                                                     
if not ok then                                                                   
    ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)              
    return                                                                       
end                                                                              
                                                                                 
local res, err, errno, sqlstate =                                                
    db:query("select Host, User from user")                                                 
if not res then                                                                  
    ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")               
    return                                                                       
end                                                                              

if res and #res > 0 then
    _.each(_.values(res), function (x)
        _.each(_.values(x), ngx.say)
    end)
end

ngx.say("\nRedis")

local redis = require "resty.redis"

local red = redis:new()
red:set_timeout(5000)

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

ngx.say(red:info())
