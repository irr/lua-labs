-- mkdir -p /tmp/logs; openresty -c /home/irocha/git/lua-labs/openresty/jwt/nginx.conf -p /tmp
-- sudo /usr/local/openresty/bin/opm get SkyLothar/lua-resty-jwt
-- http://jwtbuilder.jamiekurtz.com/
-- http -v localhost:8888/ X-AUTH-TOKEN:eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJPbmxpbmUgSldUIEJ1aWxkZXIiLCJpYXQiOjE1NDE0NjcyNTAsImV4cCI6MTU3MzAwMzI1MCwiYXVkIjoid3d3LmV4YW1wbGUuY29tIiwic3ViIjoianJvY2tldEBleGFtcGxlLmNvbSIsImRhdGEiOiJteSBmaXJzdCB0ZXN0In0.u9ObjpX4OsxQoRqTvfonJxlk56oRBx_sKTr_0A_JSPk

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

local token = ngx.req.get_headers()["X-AUTH-TOKEN"];
ngx.log(ngx.ERR, "token: " .. (token or ""));
if token == nil then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(cjson.encode({ status = status }))
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local jwt_obj = jwt:verify("secret", token)
ngx.log(ngx.ERR, "jwt: " .. dump(jwt_obj));

if not jwt_obj["verified"] then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(cjson.encode({ status = status }))
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

ngx.log(ngx.ERR, "data: " .. jwt_obj.payload.data)
