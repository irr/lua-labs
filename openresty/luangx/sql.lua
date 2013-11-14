local mysql = require "resty.mysql"                                              
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
                                                                                 
ngx.say("connected to mysql.")                                                   
                                                                                 
local res, err, errno, sqlstate =                                                
    db:query("select * from user")                                                 
if not res then                                                                  
    ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")               
    return                                                                       
end                                                                              
                                                                                     
ngx.say(string.format("Got %d rows", #res))
