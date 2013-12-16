--------------------------------
-- LIBRARIES
--------------------------------

local json = require "cjson" 
local redis = require "resty.redis"

--------------------------------
-- FUNCTIONS
--------------------------------

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

function exit_now(status, msg)
    if status ~= ngx.HTTP_OK then
        ngx.status = status
    end

    if msg then
        ngx.say(json.encode(msg))
    end

    ngx.exit(ngx.HTTP_OK)
end

function exit(rd, status, msg)
    if rd then
        rd:set_keepalive(tonumber(ngx.var.rd_max_idle_timeout), 
                         tonumber(ngx.var.rd_pool_size))
    end

    if status then
        exit_now(status, msg)
    end

    exit_now(ngx.HTTP_OK, msg)
end

function split(str, sep)
    local s = str..sep
    return s:match((s:gsub('[^'..sep..']*'..sep, '([^'..sep..']*)'..sep)))
end

-------------
-- MAIN
-------------

ngx.header.content_type = 'application/json';

local rd = redis:new()

if not rd then
    exit(rd, ngx.HTTP_INTERNAL_SERVER_ERROR, 
         "failed to instantiate redis")
end

local ok, err = rd:connect(ngx.var.rd_host, ngx.var.rd_port)

if not ok then
    exit(rd, ngx.HTTP_INTERNAL_SERVER_ERROR, 
         string.format("failed to connect to redis: %s", 
                       tostring(err)))
end

if ngx.req.get_method() == "POST" then
    ngx.req.read_body()

    if ngx.req.get_headers().content_type:lower() ~= "application/json" then
        exit(rd, ngx.HTTP_BAD_REQUEST)
    end

    local data = ngx.req.get_body_data()
    local ok, meta = pcall(json.decode, data)

    if not ok then
        exit(rd, ngx.HTTP_BAD_REQUEST)
    end

    ok, err = rd:evalsha(ngx.var.uploader_enqueue, 2, ngx.var.uploader_queue, meta["task"], data)
    if err == nil and ok > 0 then
        ngx.say(data)
        exit(rd)
    elseif err == nil and ok == 0 then
        exit(rd, ngx.HTTP_NOT_ALLOWED)  
    end
end

exit(rd, ngx.HTTP_METHOD_NOT_IMPLEMENTED)
