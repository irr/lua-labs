--------------------------------
-- TEST
--------------------------------
--[=[
curl -v "http://localhost:8080/?size=1000
--]=]

ngx.header.content_type = 'text/plain';

local DEFAULT_SIZE = 100
local keys = ngx.req.get_uri_args()
local size = tonumber((keys and keys["size"]) or DEFAULT_SIZE)

if size < DEFAULT_SIZE then
  size = DEFAULT_SIZE
end

ngx.say(string.rep("X", size - 1))
