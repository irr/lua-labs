local json = require 'json'
ngx.header.content_type = 'application/json';
ngx.say(json.encode{server="ss"..tostring(math.random(1,3)), mode="RW"})
