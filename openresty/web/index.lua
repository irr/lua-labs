--[[
curl -v -X POST --header 'Content-Type: application/json' http://localhost:8000/ -d "{\"encrypt\":\"mysql\"}"
curl -v -X POST --header 'Content-Type: application/json' http://localhost:8000/ -d "{\"decrypt\":\"c6f2200c6d95066c711ce4874b773ee3\"}"
curl -v -X POST --header 'Content-Type: application/json' http://localhost:8000/ -d "{\"method\":\"insert\", \"name\":\"irr\"}"
curl -v -X DELETE http://localhost:8000/?id=2
curl -v http://localhost:8000/?id=1
--]]

--------------------------------
-- LIBRARIES
--------------------------------

local _ = require "underscore"

local crypt = require "crypto" 
local json = require "cjson" 
local mysql = require "resty.mysql"
local redis = require "resty.redis"

--------------------------------
-- CONSTs
--------------------------------

local key = "c6bef73b51e2f696"
local iv  = "aa90025f918a9696"

--------------------------------
-- SQLs
--------------------------------
-- mysql -u root -p < db/db.sql

local INSERT = [[
SET @@AUTOCOMMIT=0;
START TRANSACTION;
SELECT @I:=users.id, @N:=users.name FROM users ORDER BY users.id DESC LIMIT 1 FOR UPDATE;
INSERT INTO users VALUES (@I + 1, %s);
SELECT * FROM users WHERE users.id = @I + 1;
COMMIT;
]]

local SELECT = [[
SELECT users.id, users.name FROM users WHERE users.id = %s;
]]

local DELETE = [[
SET @@AUTOCOMMIT=0;
START TRANSACTION;
DELETE FROM users WHERE users.id = %s;
COMMIT;
]]

--------------------------------
-- FUNCTIONS
--------------------------------

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

function cache_get(rd, n)
    if tonumber(n) then
        local k = "ID:" .. tostring(n)
        local cache, err = rd:get(k)
        if cache == ngx.null then
            return k, nil, err
        end    
        return k, cache, err
    end
    return nil, nil, nil
end

function cache_set(rd, n, cache)
    k = "ID:" .. tostring(n)
    local ok, err = rd:set(k, cache)        
    if err then
        ngx.log(ngx.ERR, "cache set error: " .. tostring(err))
    end  
    return ok, err         
end

function results(db, rd, n, sql, del)
    local k, cache, err = cache_get(rd, n)
    if del and k then
        local _, err = rd:del(k)
        if err then       
            ngx.log(ngx.ERR, "cache del error: " .. tostring(err))
        end 
    end
    local bytes, err = db:send_query(sql)
    if err then
        exit(db, rd, ngx.HTTP_INTERNAL_SERVER_ERROR, 
                        string.format("results error: %s", 
                            tostring(err)))
    end
    local body, res, err, errno, sqlstate = {}
    repeat
        res, err, errno, sqlstate = db:read_result()                
        if errno then
            if errno == 1048 then
                exit(db, rd, ngx.HTTP_NOT_FOUND)
            end
                exit(db, rd, ngx.HTTP_INTERNAL_SERVER_ERROR, 
                        string.format("results error: %s: %s %s", 
                            tostring(err), tostring(errno), tostring(sqlstate)))
        end
        if type(res) == "table" and type(res[1]) == "table" then
            body = res[1]
        end
    until err ~= "again"
    if not del then
        cache_set(rd, body["id"], json.encode({["redis"] = body}))
    end
    return json.encode({["mysql"] = body})
end

function check(db, rd, id)
    local k, cache, err = cache_get(rd, id)
    if cache then
        return cache
    end
    
    local res, err, errno, sqlstate = db:query(string.format(SELECT, ngx.quote_sql_str(id)))    
    if errno then
         exit(db, rd, ngx.HTTP_INTERNAL_SERVER_ERROR, 
                string.format("check error: %s: %s %s", 
                    tostring(err), tostring(errno), tostring(sqlstate)))
    end

    if not res or #res == 0 then
        exit(db, rd, ngx.HTTP_NOT_FOUND)
    end
    
    cache_set(rd, res[1]["id"], json.encode({["redis"] =  res[1]}) )
    return json.encode({["mysql"] =  res[1]}) 
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

    ngx.req.read_body()

    if ngx.req.get_headers().content_type:lower() ~= "application/json" then
        exit(db, rd, ngx.HTTP_BAD_REQUEST)
    end

    local ok, data = pcall(json.decode, ngx.req.get_body_data())

    if not ok then
        exit(db, rd, ngx.HTTP_BAD_REQUEST)
    end

    local fn = (data["encrypt"] and {"encrypt", ngx.unescape_uri(data["encrypt"])}) or 
               (data["decrypt"] and {"decrypt", ngx.unescape_uri(data["decrypt"])})

    if fn then
        local ok, cr = pcall(crypt[fn[1]], key, iv, fn[2])
        if ok then
            ngx.say("\""..cr.."\"")
            exit(db, rd)
        else
            exit(db, rd, ngx.HTTP_BAD_REQUEST)   
        end
    end

    local method = ngx.var['arg_method'] or data["method"]

    if method == "insert" then

        local n = ngx.quote_sql_str(data["name"])
        ngx.say(results(db, rd, n, string.format(INSERT, n)))
        
        exit(db, rd)
    end

    exit(db, rd, ngx.HTTP_METHOD_NOT_IMPLEMENTED)

elseif ngx.req.get_method() == "DELETE" then

    if not ngx.var['arg_id'] then
        exit(db, rd, ngx.HTTP_BAD_REQUEST)
    end

    local id = ngx.unescape_uri(ngx.var['arg_id'])

    if tonumber(id) <= 1 then
        exit(db, rd, ngx.HTTP_FORBIDDEN)
    end

    check(db, rd, id)

    ngx.say(results(db, rd, id, string.format(DELETE, id), true))
    exit(db, rd)

elseif ngx.req.get_method() == "GET" then
    
    local id = ngx.var['arg_id']

    if not id then
        exit(db, rd, ngx.HTTP_BAD_REQUEST)
    end

    ngx.say(check(db, rd, ngx.unescape_uri(id)))
    exit(db, rd)

else
    exit(db, rd, ngx.HTTP_BAD_REQUEST)
end
