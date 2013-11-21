#!/usr/bin/env luajit

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

function abort(tmp)
    os.execute("rm -rf " .. tmp)
    os.exit(1)
end

local nginx = [[
worker_processes  1;

error_log  logs/error.log notice;
pid        logs/nginx.pid;

events {
    worker_connections 1024;
}

http {
    default_type       application/octet-stream;
    access_log         logs/access.log  combined;
    sendfile           on;
    keepalive_timeout  65;

    lua_package_path   '/usr/local/openresty/lualib/?.lua;;';
    lua_package_cpath  ';;';

    server {
        listen       $port backlog=512;
        server_name  localhost;

        location /lua {
            content_by_lua_file "$luaf";
        }
    }
}
]]

local file = arg[1]

if not file then
    print("usage: luangx <lua file>")
    os.exit(1)
end

local tmp = os.capture("mktemp -d")

local logs = tmp .. "/logs"
local conf = tmp .. "/conf"
local ngxf = conf .. "/nginx.conf"
local pidf = logs .. "/nginx.pid"
local luaf = tmp .. "/main.lua"

if not os.execute("mkdir -p " .. logs) or not os.execute("mkdir -p " .. conf) then 
    abort(tmp) 
end

local port = tostring(math.random(60000, 65500))

local f, err = io.open(ngxf, "w+")
if err then abort(tmp) end
local txt = nginx:gsub('%$(%w+)', { ["luaf"] = luaf, ["port"] = port })
f:write(txt)
f:close()

local f, err = io.open(file, "r")
if err then abort(tmp) end
local code = f:read("*a")
f:close()

local f, err = io.open(luaf, "w+")
if err then abort(tmp) end
f:write(code)
f:close()

if not os.execute("nginx -c " .. ngxf .. " -p " .. tmp) then abort(tmp) end

local f, err = io.open(pidf, "r")
if err then abort(tmp) end
local pid = f:read("*a")
f:close()

print(os.capture("curl localhost:" .. port .. "/lua 2>/dev/null", true))

os.execute("kill " .. pid)
os.execute("rm -rf " .. tmp)


