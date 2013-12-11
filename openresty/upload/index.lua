--------------------------------
-- LIBRARIES
--------------------------------

local crypt = require "crypto" 
local json = require "cjson" 
local mysql = require "resty.mysql"
local redis = require "resty.redis"
local upload = require "resty.upload"
local resty_sha1 = require "resty.sha1"
local str = require "resty.string"

--------------------------------
-- CONSTs
--------------------------------

local key = "c6bef73b51e2f696"
local iv  = "aa90025f918a9696"

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

function exit(db, rd, status, msg)
    if db then
        db:set_keepalive(tonumber(ngx.var.db_max_idle_timeout), 
                         tonumber(ngx.var.db_pool_size))
    end

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
    exit(nil, rd, ngx.HTTP_INTERNAL_SERVER_ERROR, 
         "failed to instantiate redis")
end

local db, err = mysql:new()

if not db then
    exit(nil, rd, ngx.HTTP_INTERNAL_SERVER_ERROR, 
         "failed to instantiate mysql: " .. tostring(err))
end

db:set_timeout(ngx.var.db_timeout) 

local ok, err, errno, sqlstate = db:connect{
    host = ngx.var.db_host,
    port = ngx.var.db_port,
    database = ngx.var.db_database,
    user = ngx.var.db_user,
    password = ngx.var.db_pass or crypt.decrypt(key, iv, ngx.var.db_crypt),
    max_packet_size = tonumber(ngx.var.db_max_packet_size) }

if not ok then
    exit(db, rd, ngx.HTTP_INTERNAL_SERVER_ERROR, 
         string.format("failed to connect: %s: %s %s", 
                       tostring(err), tostring(errno), tostring(sqlstate)))
end

local ok, err = rd:connect(ngx.var.rd_host, ngx.var.rd_port)

if not ok then
    exit(db, rd, ngx.HTTP_INTERNAL_SERVER_ERROR, 
         string.format("failed to connect to redis: %s", 
                       tostring(err)))
end

if ngx.req.get_method() == "POST" then
    local file, sha1, field, save, meta = nil, nil, nil, false, ""
    
    local form, err = upload:new(tonumber(ngx.var.upload_chunksize))

    if not form then
        exit(db, rd, ngx.HTTP_INTERNAL_SERVER_ERROR, 
            string.format("failed to new upload: %s",  tostring(err)))
    end

    form:set_timeout(tonumber(ngx.var.upload_timeout))

    while true do
        local typ, res, err = form:read()
        if not typ or err then
            if file then file:close() end
            exit(db, rd, ngx.HTTP_INTERNAL_SERVER_ERROR, 
                string.format("failed to read: %s",  tostring(err)))
        end
        if typ == "header" then
            for k, v in pairs(res) do
                if v:find("name=\"data\"") then
                    field = "data"
                    break
                elseif v:find("name=\"meta\"") then
                    field = "meta"
                    break
                end
            end
        elseif typ == "body" and field == "data" then
            if not file then exit(db, rd, ngx.HTTP_BAD_REQUEST) end
            if not sha1:update(res) then exit(db, rd, ngx.HTTP_INTERNAL_SERVER_ERROR) end
            if not file:write(res) then exit(db, rd, ngx.HTTP_INTERNAL_SERVER_ERROR) end
        elseif typ == "body" and field == "meta" then
            meta = meta .. res
        elseif typ == "part_end" and field == "meta" then
            ok, meta = pcall(json.decode, meta)
            if not ok then exit(db, rd, ngx.HTTP_BAD_REQUEST) end
            sha1 = resty_sha1:new()
            file = io.open(string.format("%s/%s", ngx.var.upload_dir, meta["name"]), "wb+")
            if not file then exit(db, rd, ngx.HTTP_BAD_REQUEST) end
            field = nil
        elseif typ == "part_end" and type(meta) == "table" and field == "data" then
            if not file then exit(db, rd, ngx.HTTP_BAD_REQUEST) end
            if not file:close() then exit(db, rd, ngx.HTTP_INTERNAL_SERVER_ERROR) end
            save = true
        elseif typ == "eof" then
            break
        end
    end

    if save then
        ngx.say(json.encode({ ["meta"] = meta, ["sha1"] = str.to_hex(sha1:final()) }))
        exit(db, rd)
    end

    exit(db, rd, ngx.HTTP_INTERNAL_SERVER_ERROR)
end

exit(db, rd, ngx.HTTP_METHOD_NOT_IMPLEMENTED)
