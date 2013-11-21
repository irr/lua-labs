#!/usr/bin/env luajit

local posix = require "posix"
local http = require "socket.http"

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

function abort(tmp, err)
    print("luangx error: " .. err)
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
    abort(tmp, "could not create nginx environment") 
end

local port = tostring(math.random(60000, 65500))

local f, err = io.open(ngxf, "w+")
if err then abort(tmp, err) end
local txt = nginx:gsub('%$(%w+)', { ["luaf"] = luaf, ["port"] = port })
f:write(txt)
f:close()

local f, err = io.open(file, "r")
if err then abort(tmp, err) end
local code = f:read("*a")
f:close()

local f, err = io.open(luaf, "w+")
if err then abort(tmp, err) end
f:write(code)
f:close()

local r = os.execute("nginx -c " .. ngxf .. " -p " .. tmp)

if not r then
    abort(tmp, "could not start nginx (" .. tostring(r) .. ")") 
end

local f, err = io.open(pidf, "r")
if err then abort(tmp, err) end
local pid = f:read("*a")
f:close()

local body, err = http.request("http://localhost:" .. port .. "/lua")
if not body then abort(tmp, err) end
print(body)

local ok, err = posix.kill(tonumber(pid))

if not ok then
    print("luangx error: " .. err)
    os.exit(1)
end

os.execute("rm -rf " .. tmp)

