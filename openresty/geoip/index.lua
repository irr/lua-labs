local json = require "cjson"

local info = { addr=ngx.var.remote_addr, 
               country_code = ngx.var.geo_country_code,
               country_name = ngx.var.geo_country_name, }

ngx.header.content_type = 'application/json';
ngx.say(json.encode(info))

