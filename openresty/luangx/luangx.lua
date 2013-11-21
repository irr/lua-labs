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

function abort(tmp, err)
    if err then
        print("luangx error: " .. tostring(err))
    end
    os.execute("rm -rf " .. tmp)
    os.exit(1)
end

function show(flag, file)
    if flag then
        print("--[[" .. file)
        os.execute("cat " .. file)
        print("--]]\n")
    end
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
    access_log         logs/access.log combined;
    sendfile           on;
    keepalive_timeout  10;

    lua_package_path   '$lpath;/usr/local/openresty/lualib/?.lua;;';
    lua_package_cpath  '$cpath;;';

    server {
        listen         $port;
        server_name    localhost;

        location / {
            content_by_lua_file "$luaf";
        }
    }
}
]]

local file = nil
local lpath = ""
local cpath = ""
local log = false
local cfg = false

for i = 1, #arg do
    if arg[i]:find("-log") == 1 then
        log = true
    elseif arg[i]:find("-cfg") == 1 then
        cfg = true
    elseif arg[i]:find("-lp") == 1 and #arg[i] > 2 then
        lpath = arg[i]:sub(5)
    elseif arg[i]:find("-cp") == 1 and #arg[i] > 2 then
        cpath = arg[i]:sub(5)
    else
        file = arg[i]
    end
end

if not file then
    print("usage: luangx [-log] [-cfg] <lua file>")
    print("               -log: show error log content")
    print("               -cfg: show nginx config")
    os.exit(1)
end

local tmp = os.capture("mktemp -d")

local logs = tmp .. "/logs"
local conf = tmp .. "/conf"
local ngxf = conf .. "/nginx.conf"
local pidf = logs .. "/nginx.pid"
local luaf = tmp .. "/main.lua"

if os.execute("mkdir -p " .. logs) ~=0 or os.execute("mkdir -p " .. conf) ~= 0 then 
    abort(tmp, "could not create nginx environment") 
end

local port = tostring(math.random(60000, 65500))

local f, err = io.open(ngxf, "w+")
if err then abort(tmp, "could not write nginx configuration") end
local txt = nginx:gsub('%$(%w+)', { ["luaf"]  = luaf, 
                                    ["port"]  = port,
                                    ["lpath"] = lpath,
                                    ["cpath"] = cpath})
f:write(txt)
f:close()

local f, err = io.open(file, "r")
if err then abort(tmp, "could not read lua file") end
local code = f:read("*a")
f:close()

local f, err = io.open(luaf, "w+")
if err then abort(tmp, "could not write lua file") end
f:write(code)
f:close()

if os.execute("nginx -c " .. ngxf .. " -p " .. tmp) ~= 0 then 
    abort(tmp, "could not start nginx")
end

local f, err = io.open(pidf, "r")
if err then abort(tmp) end
local pid = f:read("*a")
f:close()

print(os.capture("curl localhost:" .. port .. "/ 2>/dev/null", true))

show(log, logs .. "/error.log")
show(cfg, conf .. "/nginx.conf")

os.execute("kill " .. pid)
os.execute("rm -rf " .. tmp)


