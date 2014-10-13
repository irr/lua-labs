--------------------------------
-- TEST
--------------------------------
--[=[
curl -v --data "name=ivan" "http://localhost:3000/test"
curl -v "http://localhost:3000/test?name=alessandra"
lua get.lua
lua post.lua
--]=]

--------------------------------
-- LIBRARIES
--------------------------------

local json = require "cjson" 

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
        ngx.say(msg)
    end

    ngx.exit(ngx.HTTP_OK)
end

function exit(status, msg)
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
local flags = ngx.shared.flags1 or ngx.shared.flags2
local timer = flags:get("timer")

ngx.log(ngx.WARN, "TIMER="..tostring(timer))

if not timer then
  local delay = 5
  local handler
  handler = function (premature)
      if premature then
          return
      end
      ngx.log(ngx.WARN, "TIMER HANDLER OK!")
      local ok, err = ngx.timer.at(delay, handler)
      if not ok then
          ngx.log(ngx.ERR, "failed to create the timer: ", err)
          return
      end
  end

  local ok, err = ngx.timer.at(delay, handler)
  if not ok then
      ngx.log(ngx.ERR, "failed to create the timer: ", err)
      return
  else
    flags:set("timer", true)
  end
end

-------------
-- MAIN
-------------

ngx.header.content_type = 'application/json';

local keys = {}

if ngx.req.get_method() == "POST" then
    ngx.req.read_body()
    -- data = ngx.req.get_body_data() -> string
    keys = ngx.req.get_post_args()
elseif ngx.req.get_method() == "GET" then
    keys = ngx.req.get_uri_args()
end

if keys["name"] then
    keys["args"] = ngx.var.args
    keys["arg_name"] = ngx.var.arg_name
    ngx.say(json.encode(keys))
    exit()
end

exit(ngx.HTTP_METHOD_NOT_IMPLEMENTED)
