--[[
luarocks --local install luaxml
cd /home/irocha/lua/openresty/xml
cp /home/irocha/.luarocks/lib/lua/5.1/LuaXML_lib.so lib/
cp /home/irocha/.luarocks/share/lua/5.1/LuaXML.lua .

OpenResty Install:
cp lib/LuaXML_lib.so /opt/lua/openresty/lualib/
  or 
cp /home/irocha/.luarocks/lib/lua/5.1/LuaXML_lib.so /opt/lua/openresty/lualib/
--]]

require("LuaXML")
local json = require("cjson")

--------------------------------
-- LIBRARIES
--------------------------------

function exit_now(status, msg)
    if status ~= ngx.HTTP_OK then
        ngx.status = status
    end
    if msg then
        ngx.say(json.encode(msg))
    end

    local request_time = (ngx.now() - ngx.req.start_time())
    ngx.log(ngx.INFO, "request time: " .. tostring(request_time))

    ngx.exit(ngx.HTTP_OK)
end

function exit(db, rd, status, msg)
    if status then
        exit_now(status, msg)
    end
    exit_now(ngx.HTTP_OK, msg)
end

-------------
-- MAIN
-------------

ngx.header.content_type = 'application/json';

local src = [=[
<applicationInfo>
    <string id="author">     ivan.ribeiro@gmail.com  </string>
    <string id="version">    0.0.1                   </string>
    <string id="date">       2015-05-15              </string>
    <string id="shortDescr"> a demonstration application for LuaXML scripting </string>
    <string id="usage">      [ -i(ini.xml) ] </string>
  </applicationInfo>
]=]

-- parse xml -> lua table
local t = xml.eval(src)

-- convert lua table -> xml
local x = xml.str(t)

-- convert lua table -> json
local j = json.encode(t)

local output = { ["json"] = j, ["xml"] = x }

ngx.say(json.encode(output))
exit()

