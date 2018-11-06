--[[

mkdir -p /tmp/logs; openresty -c /home/irocha/git/lua-labs/openresty/jwt/nginx.conf -p /tmp
sudo /usr/local/openresty/bin/opm get SkyLothar/lua-resty-jwt

http -v localhost:8080/ X-ZAPIER-TOKEN:eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE1NDE1MzY5MTgsImV4cCI6MTU0MTU0MDUxOH0.BO0Wexb3gFMGNa5NqKbwWuZqnEItMduT7KcYAZoFl6o payload=test test=irrlab

--]]

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local cjson = require "cjson"
local jwt = require "resty.jwt"

local token = ngx.req.get_headers()["X-ZAPIER-TOKEN"];

if token == nil then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(cjson.encode({ status = status }))
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local jwt_obj = jwt:verify(ngx.var.secret, token)

if not jwt_obj["verified"] then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(cjson.encode({ status = status }))
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end
